#!/usr/bin/env python3
import argparse
import logging
import pprint
import tomllib

from pathlib import Path
from typing import Any

from lib.config import Config
from lib.testhandlers import *

pprinter = pprint.PrettyPrinter(indent = 2)
pformat = pprinter.pformat

_TEST_TYPE_HANDLERS: list[type[TestHandler]] = [
	FormalVerificationTestHandler,
]


def parse_config(config_file: Path, top_dir: Path) -> Config:
	d: dict[str, Any]
	with config_file.open("rb") as f:
		d = tomllib.load(f)
	return Config.from_dict(d, top_dir = top_dir)


def parse_args(argv: list[str], top_dir: Path) -> argparse.Namespace:
	LOGLEVEL_MAP = {
		"debug": logging.DEBUG,
		"info": logging.INFO,
		"warning": logging.WARNING,
		"error": logging.ERROR,
		"critical": logging.CRITICAL,
		"none": 999,
	}

	NAME_TO_TEST_TYPE_HANDLER_MAP: dict[str, type[TestHandler]] = {
		n: tt
		for tt in _TEST_TYPE_HANDLERS
		for n in (tt.name, *tt.aliases)
	}

	p = argparse.ArgumentParser(
		description = "Synlig test runner.",
		formatter_class = argparse.RawTextHelpFormatter,
	)
	p.add_argument(
		"--loglevel",
		choices = LOGLEVEL_MAP.keys(),
		default = "warning",
		metavar = f"{{{','.join(LOGLEVEL_MAP.keys())}}}",
		dest = "loglevel_str",
		help = "Set logging level.",
	)
	p.add_argument(
		"--out-dir",
		type = Path,
		default = top_dir / "out" / "current",
		help = "Build and tests output directory (AKA 'CFG_OUT_DIR').",
	)
	p.add_argument(
		"--product-dir",
		type = Path,
		default = None,
		help = "Binary package root where project binaries will be looked for.\nDefault: $OUT_DIR/product",
	)
	p.add_argument(
		"test_type_argv",
		choices = NAME_TO_TEST_TYPE_HANDLER_MAP.keys(),
		nargs = argparse.PARSER,
		metavar = "TEST_TYPE",
		help = "Test type. See below for the list of available test types.",
	)

	# Action that does nothing, but provides a help entry.
	class DummyAction(argparse.Action):
		def __init__(self, **kwargs):
			kwargs["default"] = argparse.SUPPRESS
			kwargs["nargs"] = 0
			super().__init__(**kwargs)

		def __call__(self, *args, **kwargs):
			pass

	# Add dummy arguments for printing the list of test types in help message.
	tthelp = p.add_argument_group("test types")
	for tt in _TEST_TYPE_HANDLERS:
		help_parts: list[str] = [tt.description or ""]
		if tt.aliases: help_parts.append("Aliases: " + ", ".join(tt.aliases))

		tthelp.add_argument(
			tt.name,
			help = "\n".join(help_parts) if help_parts else None,
			action = DummyAction,
		)

	args = p.parse_args(argv[1:])

	# Translate `loglevel_arg` argument to logging module's log level
	assert (args.loglevel_str in LOGLEVEL_MAP)
	args.loglevel = LOGLEVEL_MAP[args.loglevel_str]

	# Set cross-referencing defaults.
	if not args.product_dir:
		args.product_dir = args.out_dir / "product"

	# Translate test type name to a class implementing it.
	assert (len(args.test_type_argv) >= 1)
	args.test_type_cls = NAME_TO_TEST_TYPE_HANDLER_MAP[args.test_type_argv[0]]

	return args


def main(argv: list[str], top_dir: Path, config_file: Path) -> int:
	logging.basicConfig(
		# Allow level control at logger-level
		level = logging.NOTSET,
		format = "%(asctime)s.%(msecs)03d %(levelname).1s|%(name)-32s| %(message)s",
		datefmt = "%Y-%m-%d %H:%M:%S",
	)
	logging.getLogger().setLevel(logging.WARNING)

	args = parse_args(argv, top_dir = top_dir)
	logging.getLogger().setLevel(args.loglevel)
	if logging.root.isEnabledFor(logging.DEBUG):
		logging.debug("Command line args:")
		for line in pformat(args.__dict__).splitlines():
			logging.debug(line)

	config = parse_config(config_file, top_dir = top_dir)
	if logging.root.isEnabledFor(logging.DEBUG):
		logging.debug("Config:")
		for line in pformat(config.__dir__).splitlines():
			logging.debug(line)

	test_handler = args.test_type_cls(
		config = config,
		top_dir = top_dir,
		out_dir = args.out_dir,
		product_dir = args.product_dir,
	)
	return test_handler(args.test_type_argv)
