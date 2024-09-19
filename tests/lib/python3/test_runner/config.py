#!/usr/bin/env python3
import dataclasses
import logging
import re

from dataclasses import dataclass
from fnmatch import fnmatch
from pathlib import Path
from pprint import pformat
from typing import Any, Self


@dataclass(slots = True)
class Config:
	@dataclass(slots = True)
	class Collection:
		base_dir: Path = Path.cwd()
		test_name_regexp: None | list[tuple[re.Pattern[str], str]] = None
		include: set[str] = dataclasses.field(default_factory = set)
		exclude: set[str] = dataclasses.field(default_factory = set)

		_tests: dict[str, Path] = dataclasses.field(
			default_factory = dict,
			init = False,
			repr = False,
			hash = False,
			compare = False,
		)

		def _get_test_name(self, test_path: str) -> str:
			if self.test_name_regexp is None:
				return test_path
			name = test_path
			for pat, replacement in self.test_name_regexp:
				name = pat.sub(replacement, name)
			return name.replace("/", "_")

		def get_tests(self) -> dict[str, Path]:
			if self._tests:
				return self._tests

			excluded = {  #
				path
				for pat in self.exclude
				for path in self.base_dir.glob(pat)
			}

			def extract_name_from_path(path: Path, pat: str):
				rel_or_abs_path = path if pat.startswith("/") else path.relative_to(self.base_dir)
				return self._get_test_name(str(rel_or_abs_path))

			self._tests = dict(sorted(
				[
					(extract_name_from_path(path, pat), path)  #
					for pat in self.include
					for path in self.base_dir.glob(pat)
					if path not in excluded
				],
				key = lambda kv: kv[0],
			))

			return self._tests

		@classmethod
		def from_dict(
			cls,
			d: dict[str, Any],
			top_dir: Path,
			loc: str = "<collection>",
		) -> Self:
			test_name_regexp: None | Any = d.get("test_name_regexp", None)
			compiled_tnr: None | list[tuple[re.Pattern[str], str]] = None
			if test_name_regexp is not None:
				try:
					if isinstance(test_name_regexp, str):
						# "pat"
						compiled_tnr = [(re.compile(test_name_regexp), r"\1")]
					elif isinstance(test_name_regexp, (list, tuple)) and len(test_name_regexp) > 0:
						if isinstance(test_name_regexp[0], (list, tuple)):
							# [ ["pat", "replacement"], ["pat", "replacement"], ...]
							compiled: list[tuple[re.Pattern[str], str]] = []
							for entry in test_name_regexp:
								if isinstance(entry, (list, tuple)) and len(entry) == 2:
									compiled += [(re.compile(entry[0]), entry[1])]
								else:
									logging.warning(f"{loc}.test_name_regexp[...]: Expected array with regular expression string and a replacement string. Got:\n{pformat(entry)}")
									logging.info(f"{loc}.test_name_regexp[...]: skipping entry.")
							if compiled:
								compiled_tnr = compiled
							else:
								logging.warning(f"{loc}.test_name_regexp: List does not contain valid entries.")
								logging.info(f"{loc}.test_name_regexp: Assuming empty.")
								compiled_tnr = None
						elif len(test_name_regexp) == 2:
							# ["pat", "replacement"]
							compiled_tnr = [(re.compile(test_name_regexp[0]), test_name_regexp[1])]
					else:
						logging.warning(f"{loc}.test_name_regexp: Expected nothing, string with a regular expression, array or array of arrays with regular expression string and a replacement string. Got:\n{pformat(test_name_regexp)}")
						logging.info(f"{loc}.test_name_regexp: Assuming empty.")
						compiled_tnr = None
				except re.error as e:
					logging.warning(f"{loc}.test_name_regexp: Invalid regular expression: {e.pattern!r}. Details:\n{e!s}")
					logging.info(f"{loc}.test_name_regexp: Assuming empty.")
					compiled_tnr = None

			return Config.Collection(
				base_dir = Path(top_dir, d.get("base_dir", ".")),
				test_name_regexp = compiled_tnr,
				include = d.get("include", []),
				exclude = d.get("exclude", []),
			)

	class TestCaseBasedTest(dict):
		def __init__(
			self,
			*,
			collections: dict[str, "Config.Collection"],
			passlist: set[str],
			skiplist: set[str],
			**kwargs,
		):
			dict.__init__(
				self,
				collections = collections,
				passlist = passlist,
				skiplist = skiplist,
				**kwargs,
			)

		@property
		def collections(self) -> dict[str, "Config.Collection"]:
			return self["collections"]

		@property
		def passlist(self) -> set[str]:
			return self["passlist"]

		@property
		def skiplist(self) -> set[str]:
			return self["skiplist"]

		def get_test_collections(self, filters: None | list[str] = None) -> dict[str, dict[str, Path]]:
			return {
				collection_name: collection.get_tests().copy() if not filters else {
					name: path
					for name, path in collection.get_tests().items()
					if any(fnmatch(f"@{collection_name}/{name}", pat)
						for pat in filters)
				}
				for collection_name, collection in self.collections.items()
			}

		def get_tests(self, filters: None | list[str] = None) -> dict[str, Path]:
			return {
				test_id: path
				for collection_name, collection in self.collections.items()
				for name, path in collection.get_tests().items()
				if (test_id := f"@{collection_name}/{name}")  #
				if not filters or any(fnmatch(test_id, pat) for pat in filters)
			}

		@classmethod
		def from_dict(
			cls,
			d: dict[str, Any],
			all_collections: dict[str, "Config.Collection"],
		) -> Self:
			collections: dict[str, Config.Collection] = {}
			for collection_name in d.pop("collections", []):
				if not isinstance(collection_name, str):
					logging.warning(f"Invalid collection name: {collection_name!r}.")
					continue
				if collection_name in collections:
					logging.warning(f"Repeated collection name: {collection_name}.")
					continue
				if collection_name not in all_collections:
					logging.warning(f"Unknown collection name: {collection_name}.")
					continue
				collections[collection_name] = all_collections[collection_name]

			passlist: set[str] = set()
			for pattern in d.pop("passlist", []):
				if pattern in passlist:
					logging.warning(f"Repeated passlist pattern: {pattern}.")
					continue
				if not isinstance(pattern, str):
					logging.warning(f"Invalid pattern: {pattern!r}.")
					continue
				passlist.add(pattern)

			skiplist: set[str] = set()
			for pattern in d.pop("skiplist", []):
				if pattern in skiplist:
					logging.warning(f"Repeated skiplist pattern: {pattern}.")
					continue
				if not isinstance(pattern, str):
					logging.warning(f"Invalid pattern: {pattern!r}.")
					continue
				skiplist.add(pattern)

			return Config.TestCaseBasedTest(
				collections = collections,
				passlist = passlist,
				skiplist = skiplist,
				**d,
			)

	collections: dict[str, Collection]
	tests: dict[str, TestCaseBasedTest | Any]

	def get_test_collections(self, filters: None | list[str] = None) -> dict[str, dict[str, Path]]:
		return {
			collection_name: collection.get_tests().copy() if not filters else {
				name: path
				for name, path in collection.get_tests().items()
				if any(fnmatch(f"@{collection_name}/{name}", pat)
					for pat in filters)
			}
			for collection_name, collection in self.collections.items()
		}

	def get_tests(self, filters: None | list[str] = None) -> dict[str, Path]:
		return {
			test_id: path
			for collection_name, collection in self.collections.items()
			for name, path in collection.get_tests().items()
			if (test_id := f"@{collection_name}/{name}")  #
			if not filters or any(fnmatch(test_id, pat) for pat in filters)
		}

	@classmethod
	def from_dict(cls, d: dict[str, Any], top_dir: Path) -> Self:
		collections = {
			name: Config.Collection.from_dict(cd, top_dir = top_dir, loc = f"collections.{name}")
			for name, cd in d.get("collections", {}).items()
		}
		# TODO(mglb): handle more test types than TestCaseBasedTest
		tests = {
			name: Config.TestCaseBasedTest.from_dict(td, collections)
			for name, td in d.get("tests", {}).items()
		}
		return Config(
			collections = collections,
			tests = tests,
		)
