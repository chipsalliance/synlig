import argparse
import enum
import logging
import os
import sys
import pprint

from enum import StrEnum
from pathlib import Path
from typing import Any, Callable

from lib.config import Config

pprinter = pprint.PrettyPrinter(indent = 2)
pformat = pprinter.pformat


def add_test_case_id_globs_arg(p: argparse.ArgumentParser) -> argparse.Action:
	return p.add_argument(
		"test_case_id_globs",
		type = str,
		metavar = "test_case_id",
		nargs = "*",
		default = [],
		help = "\n".join([
			"Test case ID (supports glob pattern).",
			"Default: all test cases (same as \"*\")",
		]),
	)


class StatusOutputFormat(StrEnum):
	PLAIN = "plain"
	TTY = "tty"


# TODO(mglb): move to common code directory
def enum_to_argparse_choices(et: enum.EnumType) -> list[str]:
	return [str(i.value) for i in et]  # type: ignore # due to issues with `i.value` detection


class TestHandler:
	class _SubParsersWrapper:
		def __init__(self, sp: argparse._SubParsersAction):
			self.__wrapped__ = sp

		def add_parser(
			self,
			name: str,
			handler: Callable[..., int],
			formatter_class: Any = None,
			**kwargs,
		) -> argparse.ArgumentParser:
			p = self.__wrapped__.add_parser(
				name,
				formatter_class = argparse.RawTextHelpFormatter,
				**kwargs,
			)
			p.set_defaults(command_handler = handler)
			# TODO(mglb): Create an arguments group and and dummy help entries for each command.
			# For consistency with test types list in the main help message of the script.
			return p

	_logger = logging.getLogger("TestHandler")

	name: str
	aliases: list[str] = []
	description: None | str = None

	def __init__(
		self,
		config: Config,
		top_dir: Path,
		out_dir: Path,
		product_dir: Path,
	):
		self.config = config
		self.top_dir = top_dir.absolute()
		self.out_dir = out_dir.absolute()
		self.product_dir = product_dir.absolute()
		assert (self.name)
		self.tests_out_dir = self.out_dir / "tests" / self.name

	def __call__(self, argv: list[str]) -> int:
		args = self._parse_args(argv)

		self._logger.debug("Test handler command line args:")
		for line in pformat(args.__dict__).splitlines():
			self._logger.debug(line)

		command_handler = args.command_handler
		return command_handler(self, **args.__dict__)

	@classmethod
	def _setup_extra_args(
		cls,
		p: argparse.ArgumentParser,
		sp: _SubParsersWrapper,
		run_cmd_p: argparse.ArgumentParser,
		status_cmd_p: argparse.ArgumentParser,
		clean_cmd_p: argparse.ArgumentParser,
	) -> None:
		pass

	def _handle_run_command(
		self,
		test_case_id_globs: list[str],
		**kwargs,
	) -> int:
		self._logger.debug(f"_handle_run_command")
		raise NotImplementedError()

	def _handle_clean_command(
		self,
		test_case_id_globs: list[str],
		**kwargs,
	) -> int:
		self._logger.debug(f"_handle_clean_command")
		raise NotImplementedError()

	def _handle_status_command(
		self,
		format: StatusOutputFormat,
		test_case_id_globs: list[str],
		**kwargs,
	) -> int:
		self._logger.debug(f"_handle_status_command")
		raise NotImplementedError()

	@classmethod
	def _parse_args(cls, argv: list[str]) -> argparse.Namespace:
		p = argparse.ArgumentParser(
			description = cls.description,
			formatter_class = argparse.RawTextHelpFormatter,
			prog = f"{Path(sys.argv[0]).name} {cls.name}",
		)

		sp = TestHandler._SubParsersWrapper(p.add_subparsers(
			dest = "command_name",
			metavar = "command",
		))

		run_cmd_p = sp.add_parser(
			"run",
			handler = cls._handle_run_command,
			help = "Runs test.",
		)

		clean_cmd_p = sp.add_parser(
			"clean",
			handler = cls._handle_clean_command,
			help = "Removes test results and generated files.",
		)

		status_cmd_p = sp.add_parser(
			"status",
			handler = cls._handle_status_command,
			help = "Outputs test results.",
		)
		status_cmd_p.add_argument(
			"--format",
			type = StatusOutputFormat,
			choices = enum_to_argparse_choices(StatusOutputFormat),
			default = StatusOutputFormat.TTY if os.isatty(sys.stdout.fileno()) else StatusOutputFormat.PLAIN,
			help = "\n".join([
				"Output format.",
				"Default: 'tty' if stdout is a TTY, 'plain' otherwise",
			]),
		)

		cls._setup_extra_args(
			p = p,
			sp = sp,
			run_cmd_p = run_cmd_p,
			status_cmd_p = status_cmd_p,
			clean_cmd_p = clean_cmd_p,
		)

		cls._logger.debug(pformat(argv))
		args = p.parse_args(argv[1:])

		return args


class TestWithTestCasesHandler(TestHandler):
	@classmethod
	def _setup_extra_args(
		cls,
		p: argparse.ArgumentParser,
		sp: TestHandler._SubParsersWrapper,
		run_cmd_p: argparse.ArgumentParser,
		status_cmd_p: argparse.ArgumentParser,
		clean_cmd_p: argparse.ArgumentParser,
	) -> None:
		run_cmd_p.add_argument(
			"--jobs",
			"-j",
			type = int,
			default = 0,
			help = "\n".join([
				"How many parallel jobs to use. When set to 0, jobs count is equal to cpu core count.",
				"Default: 0",
			]),
		)
		# TODO(mglb): Add support for `--force` and uncomment following code.
		# run_cmd_p.add_argument(
		# 	"--force",
		# 	"-f",
		# 	type = bool,
		# 	action = argparse.BooleanOptionalAction,
		# 	default = False,
		# 	help = "\n".join([
		# 		"Force run - removes existing test result if there are any.",
		# 		"Default: false",
		# 	]),
		# )
		add_test_case_id_globs_arg(run_cmd_p)
		add_test_case_id_globs_arg(status_cmd_p)
		add_test_case_id_globs_arg(clean_cmd_p)

		# TODO(mglb): allow subclass to adjust list_cmd_p
		list_cmd_p = sp.add_parser(
			"list",
			handler = cls._handle_list_command,
			help = "Outputs list of available test cases.",
		)
		list_cmd_p.add_argument(
			"--verbose",
			"-v",
			type = bool,
			action = argparse.BooleanOptionalAction,
			default = False,
			help = "\n".join([
				"Print additional information for every test case.",
				"Default: false",
			]),
		)
		add_test_case_id_globs_arg(list_cmd_p)

	def _handle_run_command(
		self,
		jobs: int,
		test_case_id_globs: list[str],
		**kwargs,
	) -> int:
		self._logger.debug(f"_handle_run_command")
		raise NotImplementedError()

	def _handle_clean_command(
		self,
		test_case_id_globs: list[str],
		**kwargs,
	) -> int:
		self._logger.debug(f"_handle_clean_command")
		raise NotImplementedError()

	def _handle_status_command(
		self,
		format: StatusOutputFormat,
		test_case_id_globs: list[str],
		**kwargs,
	) -> int:
		self._logger.debug(f"_handle_status_command")
		raise NotImplementedError()

	# Returns mapping of test case IDs to their respective descriptions.
	# Description should contain path to the test case or similar information.
	def _get_test_case_list(
		self,
		test_case_id_globs: list[str],
	) -> dict[str, str]:
		self._logger.debug(f"_get_test_case_list")
		raise NotImplementedError()

	def _handle_list_command(
		self,
		verbose: bool,
		test_case_id_globs: list[str],
		**kwargs,
	) -> int:
		test_cases = self._get_test_case_list(test_case_id_globs)

		if not test_cases:
			return 0

		if verbose:
			name_max_len = max([len(n) for n in test_cases.keys()])
			for n, p in test_cases.items():
				print(f"{n:<{name_max_len}}\t{p}")
		else:
			for n in test_cases.keys():
				print(n)

		return 0
