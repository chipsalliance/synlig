import dataclasses
import logging
import os
import pprint
import re
import shlex
import shutil

from dataclasses import dataclass
from pathlib import Path
from textwrap import dedent
from typing import Any, TypeVar, Generator

from lib.testhandlers.testhandler import TestWithTestCasesHandler, StatusOutputFormat
from lib.utils.shcmdtemplate import ShCmdTemplate, ShStrTemplate

# TODO(mglb): move *TestStep to separate module


class TestStep:
	_step_kind_name = ""

	def __init__(
		self,
		name: str,
	):
		self.name = name


class ExpectErrorTestStep(TestStep):
	_step_kind_name = "expect_fail"

	def __init__(
		self,
		child: TestStep,
		*,
		name: str = "",
	):
		TestStep.__init__(self, name)
		self.child = child


class CommandTestStep(TestStep):
	_step_kind_name = "command"

	def __init__(
		self,
		name: str,
		command: str | ShCmdTemplate,
		cwd: str | ShStrTemplate | None = None,
		stdout: str | ShStrTemplate = "/dev/null",
		stderr: str | ShStrTemplate = "/dev/null",
		status_check_script: str | ShCmdTemplate | None = None,
		parameter_substitutions: None | dict[str, str] = None,
	):
		TestStep.__init__(self, name)

		# TODO(mglb): description, vmem limit, runtime limit, oom_score_adj

		ClsT = TypeVar("ClsT", ShCmdTemplate, ShStrTemplate)

		def wrap_if_str_and_subst(
			v: None | str | ClsT,
			cls: type[ClsT],
		) -> ClsT | Any:
			if v is None:
				return None
			if isinstance(v, str):
				v = cls(v)
			if not parameter_substitutions:
				return v
			return v.substitute_parameters(parameter_substitutions, undefined_ok = True)

		self.command: ShCmdTemplate = wrap_if_str_and_subst(command, ShCmdTemplate)
		self.cwd: None | ShStrTemplate = wrap_if_str_and_subst(cwd, ShStrTemplate)
		self.stdout: ShStrTemplate = wrap_if_str_and_subst(stdout, ShStrTemplate)
		self.stderr: ShStrTemplate = wrap_if_str_and_subst(stderr, ShStrTemplate)
		self.status_check_script: None | ShCmdTemplate = wrap_if_str_and_subst(status_check_script, ShCmdTemplate)


class GroupTestStep(TestStep, list):
	_step_kind_name = "group"

	def __init__(
		self,
		steps: list[TestStep],
		*,
		name: str = "",
	):
		TestStep.__init__(self, name)
		list.__init__(self, steps)


class AndTestStep(GroupTestStep):
	_step_kind_name = "and"


class OrTestStep(GroupTestStep):
	_step_kind_name = "or"


class AllTestStep(GroupTestStep):
	_step_kind_name = "all"


class SeqTestStep(GroupTestStep):
	_step_kind_name = "seq"


# TODO(mglb): move BashScriptTaskGenerator move to separate module


class BashScriptTaskGenerator:
	def __init__(
		self,
		task: TestStep,
		test_name: str,
		status_file: Path,
		parameters: dict[str, str] | None = None,
	):
		self._test_name = test_name
		self._status_file = status_file
		self._functions: dict[str, list[str]] = {}
		self._auto_name_counter: int = 0
		self._main_function = self._generate_functions(task, parameters)
		self._script = self._generate_script()

	def _generate_auto_name(self, step: TestStep) -> str:
		name = str(self._auto_name_counter)
		self._auto_name_counter += 1
		if step._step_kind_name:
			name += f"_{step._step_kind_name}"
		return name

	def _generate_functions(
		self,
		step: TestStep,
		parameters: dict[str, str] | None = None,
	) -> str:
		if parameters is None:
			parameters = {}

		INDENT = "\t"

		name = step.name if step.name else self._generate_auto_name(step)
		fname = f"step_{name}"

		if fname in self._functions:
			return fname

		lines: list[str] = []

		match step:
			case ExpectErrorTestStep():
				self._functions[fname] = []
				child = self._generate_functions(step.child, parameters)
				is_cmd = isinstance(step.child, CommandTestStep)
				lines += [
					INDENT + (child if not is_cmd else f"{child} || {{ print_cmd_fail; false; }}"),
					"",
					INDENT + fr"if (( $? == 0 )); then",
					INDENT * 2 + r"printf '\n\x1b[31mExpected error, but the script succeeded.\x1b[0m\n'",
					INDENT * 2 + r"return 1",
					INDENT + fr"else",
					INDENT * 2 + r"printf '\n\x1b[32mExpected error, got error.\x1b[0m\n'",
					INDENT * 2 + r"return 0",
					INDENT + fr"fi",
				]

			case CommandTestStep():
				lines += [INDENT + r"echo"]

				if step.cwd is not None:
					cwd = step.cwd.expand_parameters(parameters, undefined_ok = True) if parameters else step.cwd
					lines += [
						INDENT + fr"""if [[ "$PWD" != {cwd.to_sh_code()} ]]; then""",
						INDENT * 2 + fr"""printf '\x1b[2;34m$ \x1b[22mcd "%s"\x1b[0m\n\n' {cwd.to_sh_code()}""",
						INDENT * 2 + fr"cd {cwd.to_sh_code()}",
						INDENT + r"fi",
					]

				stdout = step.stdout.expand_parameters(parameters, undefined_ok = True) if parameters else step.stdout
				stderr = step.stderr.expand_parameters(parameters, undefined_ok = True) if parameters else step.stderr
				stdout_redir = fr">{stdout.to_sh_code()}"
				stderr_redir = r"2>&1" if stdout == stderr else fr"2>{stderr.to_sh_code()}"

				command = step.command.expand_parameters(parameters, undefined_ok = True) if parameters else step.command
				cmd_as_str = shlex.quote(str(command))

				lines += [
					INDENT + fr"printf '\x1b[34m$ \x1b[94m%s\x1b[0m\n' {cmd_as_str}",
					INDENT + r"{",
					command.indent(INDENT * 2).to_sh_code(),
					INDENT + r"} " + stdout_redir + r" " + stderr_redir,
				]
				if step.status_check_script is not None:
					sts = step.status_check_script.expand_parameters(parameters, undefined_ok = True) if parameters else step.status_check_script
					lines += [
						INDENT + r"(",
						sts.indent(INDENT * 2).to_sh_code(),
						INDENT + r") | sed -e 's|^.*$|\x1b[2;33m┆ \x1b[22m\0\x1b[0m|'",
					]

			case AndTestStep():
				self._functions[fname] = []
				children = [(self._generate_functions(child, parameters), isinstance(child, CommandTestStep)) for child in step]
				if children:
					lines += [INDENT + r" && ".join([name if not is_cmd else f"{{ {name} || {{ print_cmd_fail; false; }}; }}" for name, is_cmd in children])]
				else:
					lines += [INDENT + r"return 0"]

			case OrTestStep():
				self._functions[fname] = []
				children = [(self._generate_functions(child, parameters), isinstance(child, CommandTestStep)) for child in step]
				if children:
					lines += [INDENT + r" || ".join(name for name, _ in children)]
					if children[-1][1]:
						lines += [INDENT + r"(( $? == 0 )) && return 0 || { print_cmd_fail; return 1; }"]
				else:
					lines += [INDENT + r"return 0"]

			case AllTestStep() | SeqTestStep():
				self._functions[fname] = []
				children = [(self._generate_functions(child, parameters), isinstance(child, CommandTestStep)) for child in step]
				if children:
					lines += [INDENT + r"local -i rc=0"]
					lines += [INDENT + (fr"{name} || rc=1;" if not is_cmd else fr"{name} || {{ print_cmd_fail; rc=1; }}") for name, is_cmd in children]
					lines += [INDENT + r"return $rc"]
				else:
					lines += [INDENT + r"return 0"]

			case _:
				raise NotImplementedError(f"Unhandled test step: {step.__class__.__name__}")

		self._functions[fname] = [
			fr"{fname}() {{",
			*lines,
			r"}",
		]
		return fname

	def _generate_script(self, parameters: dict[str, str | ShStrTemplate] | None = None) -> str:
		if parameters is None:
			parameters = {}

		INDENT = "\t"
		TITLE_PREFIX = "TEST CASE: "

		def parse_if_str(v: str | ShStrTemplate) -> ShStrTemplate:
			if isinstance(v, str):
				return ShStrTemplate(v)
			return v

		lines: list[str] = [
			r"#!/usr/bin/env bash",
			"set -u -o pipefail",
			"shopt -s nullglob",
			"shopt -s extglob",
			r"",
			r"printf '\x1b[2;37m%s\x1b[0m\n' " + ShStrTemplate.escape("─" * (2 + len(TITLE_PREFIX + self._test_name))).to_sh_code(),
			r"printf '\x1b[96m%s\x1b[1m%s\x1b[0m\n'" + " \\",
			INDENT + ShStrTemplate.escape(TITLE_PREFIX).to_sh_code() + " \\",
			INDENT + ShStrTemplate.escape(self._test_name).to_sh_code(),
			r"printf '\x1b[2;37m%s\x1b[0m\n' " + ShStrTemplate.escape("─" * (2 + len(TITLE_PREFIX + self._test_name))).to_sh_code(),
		]

		if parameters:
			lines += [""]
			lines += [fr"readonly {k}={parse_if_str(v).to_sh_code()}" for k, v in parameters.items()]

		lines += ["", r"print_cmd_fail() { printf '\x1b[2;31m└ \x1b[22mfailed\x1b[0m\n'; }"]

		for f in self._functions.values():
			lines += [""]
			lines += f

		test_name_sh_str = ShStrTemplate.escape(self._test_name).to_sh_code()
		status_file_sh_str = ShStrTemplate.escape(str(self._status_file)).to_sh_code()

		lines += [
			r"",
			r"status_fail() {",
			INDENT + r"printf '\n\x1b[31;7mFAIL   \x1b[27;91m %s\x1b[0m\n\n' " + test_name_sh_str,
			INDENT + fr"echo 'fail' > {status_file_sh_str}",
			r"}",
			r"",
			r"status_pass() {",
			INDENT + r"printf '\n\x1b[32;7mPASS   \x1b[27;92m %s\x1b[0m\n\n' " + test_name_sh_str,
			INDENT + fr"echo 'pass' > {status_file_sh_str}",
			r"}",
			r"",
			fr"rm -f {status_file_sh_str}",
			r"",
			fr"{self._main_function} && status_pass || status_fail",
		]

		return "\n".join(lines)

	def __str__(self) -> str:
		return self._script


class FormalVerificationTestHandler(TestWithTestCasesHandler):
	_logger = logging.getLogger("FormalVerificationTestHandler")
	_config_test_name = "formal_verification"

	name = "formal-verification"
	aliases = [
		"formal_verification",
		"formalverification",
		"formal",
		"fv",
	]
	description = "Formal Verification."

	def _handle_run_command(self, jobs: int, test_case_id_globs: list[str], **kwargs) -> int:
		self._logger.debug(f"_handle_run_command")

		self._handle_clean_command(test_case_id_globs)
		self._generate_test_scripts(test_case_id_globs)

		tc = self.config.tests[self._config_test_name]
		all_tests = tc.get_tests(test_case_id_globs)

		if not all_tests:
			return 0

		makefile_file = self.tests_out_dir / "Makefile"

		target_args_str = " ".join([shlex.quote(n) for n in all_tests.keys()])

		if jobs <= 0:
			cmd = (f"make -j$(nproc) -f {makefile_file} -rR -Otarget {target_args_str}")
		elif jobs == 1:
			cmd = (f"make -j1 -f {makefile_file} -rR {target_args_str}")
		else:
			cmd = (f"make -j{jobs} -f {makefile_file} -rR -Otarget {target_args_str}")
		return os.system(cmd)

	def _generate_test_scripts(self, test_case_id_globs: list[str], **kwargs):
		self._logger.debug(f"_generate_test_scripts")

		test_config = self.config.tests[self._config_test_name]
		test_collections = test_config.get_test_collections(test_case_id_globs)

		if not test_collections:
			return 0

		passlist = test_config.passlist
		task = self.__gen_task()

		for collection_name, test_cases in test_collections.items():
			collection = self.config.collections[collection_name]
			collection_out_dir = self.tests_out_dir / collection_name
			for test_name, test_path in test_cases.items():
				full_test_name = f"@{collection_name}/{test_name}"
				self._logger.debug(f"Preparing {full_test_name}")
				test_out_dir = collection_out_dir / test_name
				test_out_dir.mkdir(parents = True, exist_ok = True)
				status_file = collection_out_dir / test_name / "status.txt"
				test_case_task = task if full_test_name in passlist else ExpectErrorTestStep(task)
				script = BashScriptTaskGenerator(test_case_task, full_test_name, status_file, parameters = {
					"PRODUCT_DIR": str(self.product_dir),
					"RESULTS_DIR": str(test_out_dir),
					"TEST_COLLECTION_DIR": str(collection.base_dir),
					"TEST_SUBDIR": str(test_path.parent.relative_to(collection.base_dir)),
					"TEST_FILE_NAME": str(test_path.name),
				})
				test_script_file = test_out_dir / "test.sh"
				self._logger.debug(f"Creating test script: {test_script_file}")
				with test_script_file.open("w") as f:
					f.write(str(script) + "\n")
				test_script_file.chmod(0o777)

				mk_fragment_file = test_out_dir / "test.inc.mk"
				mk_fragment = dedent(fr"""
					.PHONY: {full_test_name}

					{full_test_name}: results_dir := $(dir $(abspath $(lastword ${{MAKEFILE_LIST}})))

					{full_test_name}:
						@${{results_dir}}test.sh | tee ${{results_dir}}test.log || true

					all_tests += {full_test_name}
				""").strip()
				self._logger.debug(f"Creating makefile fragment: {mk_fragment_file}")
				with mk_fragment_file.open("w") as f:
					f.write(mk_fragment + "\n")

		makefile_file = self.tests_out_dir / "Makefile"
		makefile = dedent(fr"""
			override RESULTS_TOP_DIR := $(dir $(abspath $(lastword ${{MAKEFILE_LIST}})))
			export PATH := {self.product_dir / "bin"}:${{PATH}}

			all :

			all_tests :=
			include ${{RESULTS_TOP_DIR}}*/*/test.inc.mk

			# .PHONY: all
			# all : ${{all_tests}}
		""").strip()
		self._logger.debug(f"Creating makefile: {makefile_file}")
		with makefile_file.open("w") as f:
			f.write(makefile + "\n")

	def _handle_clean_command(self, test_case_id_globs: list[str], **kwargs) -> int:
		self._logger.debug(f"_handle_clean_command")

		tc = self.config.tests[self._config_test_name]
		test_collections = tc.get_test_collections(test_case_id_globs)

		if not test_collections:
			return 0

		some_tests_remain: bool = False

		for collection_name, test_cases in test_collections.items():
			collection = self.config.collections[collection_name]
			collection_out_dir = self.tests_out_dir / collection_name
			for test_name, test_path in test_cases.items():
				test_out_dir = collection_out_dir / test_name
				if test_out_dir.is_dir():
					shutil.rmtree(test_out_dir)
					self._logger.info(f"Removed: {test_out_dir}")

			if collection_out_dir.is_dir():
				try:
					collection_out_dir.rmdir()
					self._logger.info(f"Removed: {collection_out_dir}")
				except OSError:
					# That's OK, it most probably happened because there are files inside.
					some_tests_remain = True
					pass

		makefile_file = self.tests_out_dir / "Makefile"
		if not some_tests_remain and makefile_file.is_file():
			makefile_file.unlink()
			self._logger.info(f"Removed: {makefile_file}")

		if not some_tests_remain and self.tests_out_dir.is_dir():
			try:
				self.tests_out_dir.rmdir()
				self._logger.info(f"Removed: {self.tests_out_dir}")
			except OSError:
				# That's OK, it most probably happened because there are files inside.
				pass

		return 0

	@dataclass(slots = True, kw_only = True)
	class ResultData():
		results_dir: Path
		status: str = "n/a"
		detailed_status: str = ""
		tty_color: int = 37
		details: dict[str, str] = dataclasses.field(default_factory = dict)

	def _get_results(self, test_case_id_globs: list[str], **kwargs) -> Generator[tuple[str, "FormalVerificationTestHandler.ResultData"], None, None]:
		self._logger.debug(f"_get_results")

		test_config = self.config.tests[self._config_test_name]
		test_collections = test_config.get_test_collections(test_case_id_globs)

		if not test_collections:
			return None

		EQUIV_LOG_PATTERNS = re.compile(r"|".join([
			r"""(?P<pass>^ *Equivalence successfully proven)""",
			r"""(?P<diff>^ *Unproven \$equiv|Found [0-9]+ unproven \$equiv cells)""",
			r"""(?P<invalid_model_synlig>^ERROR: Can't find gold module synlig)""",
			r"""(?P<invalid_model_yosys>^ERROR: Can't find gold module yosys)""",
			r"""(?P<empty_model>^Proved 0 previously unproven \$equiv cells)""",
			r"""(?P<model_error>^ERROR:)""",
		]))

		passlist = test_config.passlist

		for collection_name, test_cases in test_collections.items():
			collection = self.config.collections[collection_name]
			collection_out_dir = self.tests_out_dir / collection_name
			for test_name, test_path in test_cases.items():
				full_test_name = f"@{collection_name}/{test_name}"
				test_out_dir = collection_out_dir / test_name
				on_passlist = full_test_name in passlist

				status: str = ""
				detailed_status: str = ""
				tty_color: int = 37

				status_file = test_out_dir / "status.txt"

				if not status_file.is_file():
					yield (
						full_test_name,
						FormalVerificationTestHandler.ResultData(
							results_dir = test_out_dir,
							status = "n/a",
							detailed_status = "",
							tty_color = tty_color,
						),
					)
					continue

				with status_file.open("r") as f:
					status = f.read().strip()

				if status not in ["pass", "fail"]:
					status = "unknown"

				match (status, on_passlist):
					case ("pass", True):
						detailed_status = "expect-noerr-got-noerr"
						tty_color = 92
					case ("pass", False):
						detailed_status = "expect-err-got-err"
						tty_color = 32
					case ("fail", True):
						detailed_status = "expect-noerr-got-err"
						tty_color = 91
					case ("fail", False):
						detailed_status = "expect-err-got-noerr"
						tty_color = 33
					case ("unknown", True):
						detailed_status = "expect-noerr"
						tty_color = 35
					case ("unknown", False):
						detailed_status = "expect-err"
						tty_color = 35

				# Determine detailed statuses of executed commands

				read_systemverilog_status = "n/a"
				read_verilog_status = "n/a"
				equiv_status = ""

				# read_verilog status

				read_verilog_status_file = test_out_dir / "read_verilog_synth.status.txt"
				sv2v_status_file = test_out_dir / "sv2v.status.txt"
				read_verilog_sv2v_status_file = test_out_dir / "read_verilog_synth_sv2v.status.txt"

				if read_verilog_sv2v_status_file.exists():
					with read_verilog_sv2v_status_file.open() as f:
						if f.read().strip() == "0":
							read_verilog_status = "read-sv2v-ok"
						else:
							read_verilog_status = "read-sv2v-fail"
							equiv_status = "ref-netlist-missing"
				elif sv2v_status_file.exists():
					with sv2v_status_file.open() as f:
						if f.read().strip() != "0":
							read_verilog_status = "sv2v-fail"
						else:
							read_verilog_status = "read-sv2v-fail"
					equiv_status = "ref-netlist-missing"
				elif read_verilog_status_file.exists():
					with read_verilog_status_file.open() as f:
						if f.read().strip() == "0":
							read_verilog_status = "read-ok"
						else:
							read_verilog_status = "sv2v-fail"
							equiv_status = "ref-netlist-missing"

				# read_systemverilog status

				read_systemverilog_status_file = test_out_dir / "read_systemverilog_synth.status.txt"

				if read_systemverilog_status_file.exists():
					with read_systemverilog_status_file.open() as f:
						if f.read().strip() == "0":
							read_systemverilog_status = "read-ok"
						else:
							read_systemverilog_status = "read-fail"
							if equiv_status:
								equiv_status += "|"
							equiv_status += "synlig-netlist-missing"

				# Equiv status from cmp

				compare_status_file = test_out_dir / "compare_netlists.status.txt"

				if not equiv_status and compare_status_file.exists():
					with compare_status_file.open() as f:
						if f.read().strip() == "0":
							equiv_status = "pass"

				# Equiv status from yosys_equiv log

				equiv_log_file = test_out_dir / "yosys_equiv.log"

				if not equiv_status and equiv_log_file.exists():
					with equiv_log_file.open() as f:
						for line in f:
							m = EQUIV_LOG_PATTERNS.match(line)
							if not m or not m.lastgroup:
								continue
							equiv_status = m.lastgroup.replace("_", "-")
							match m.lastgroup:
								case "empty_model":
									# Continue as there can be `proven` pattern in further lines.
									...
								case _:
									break

				if not equiv_status:
					equiv_status = "inconclusive"

				yield (
					full_test_name,
					FormalVerificationTestHandler.ResultData(results_dir = test_out_dir, status = status, detailed_status = detailed_status, tty_color = tty_color, details = {
						"read_verilog": read_verilog_status,
						"read_systemverilog": read_systemverilog_status,
						"equivalence": equiv_status,
					}),
				)

	def _handle_status_command_tty(
		self,
		test_case_id_globs: list[str],
		**kwargs,
	) -> int:
		results = self._get_results(test_case_id_globs)

		summary: dict[str, dict[str, int]] = {}
		tests_num = 0

		def round_up_to_multiple_of(v: int, base: int):
			return ((v + base - 1) // base) * base

		for test_name, result in sorted(results, key = lambda e: e[0]):
			tests_num += 1
			summary.setdefault(result.status, {})
			summary[result.status].setdefault("", 0)
			summary[result.status][""] += 1
			if result.detailed_status:
				summary[result.status].setdefault(result.detailed_status, 0)
				summary[result.status][result.detailed_status] += 1

			cl = result.tty_color
			name_cl = cl if cl >= 90 else cl + 60
			print(" ".join([
				f"\x1b[{cl}m\x1b[7m{result.status.upper():<7}\x1b[27;40m",
				f"{result.detailed_status or 'n/a':<31}\x1b[49m",
				f"\x1b[{name_cl}m{test_name}\x1b[0m",
			]))

			if not result.details:
				continue
			# Adding width of indent and ": " (4)
			key_col_width = round_up_to_multiple_of(max([len(k) for k in result.details.keys()]) + 4, 4)
			for k, v in sorted(result.details.items(), key = lambda kv: kv[0]):
				print(f"\x1b[39m{'  ' + k + ': ':<{key_col_width}}{v}\x1b[0m")

		header = "SUMMARY"
		line = "\x1b[2;37m" + ("─" * (2 + len(header))) + "\x1b[0m"
		print()
		print(line)
		print(f"\x1b[1;36m{header}\x1b[0m")
		print(line)
		print()

		summary_table: list[tuple[int, str, int]] = []
		for status, detailed_statuses in summary.items():
			summary_table += [(0, f"{status}: ", detailed_statuses.pop(""))]
			for detailed_status, count in detailed_statuses.items():
				summary_table += [(1, f"  {detailed_status}: ", count)]
		summary_table += [(2, "total: ", tests_num)]

		key_col_width = round_up_to_multiple_of(max([len(e[1]) for e in summary_table]), 4)
		for kind, key, count in summary_table:
			if kind == 0:
				key = key.upper()
			fmt = "1" if kind == 0 else "0" if kind == 1 else "2"
			num_fmt = "1" if kind == 0 else "0" if kind == 1 else "2"
			print(f"\x1b[{fmt}m{key:<{key_col_width}}\x1b[{num_fmt}m{count}\x1b[0m")

		print()

		return 0

	def _handle_status_command_plain(
		self,
		test_case_id_globs: list[str],
		**kwargs,
	) -> int:
		results = self._get_results(test_case_id_globs)

		summary: dict[str, dict[str, int]] = {}
		tests_num = 0

		def round_up_to_multiple_of(v: int, base: int):
			return ((v + base - 1) // base) * base

		for test_name, result in results:
			tests_num += 1
			summary.setdefault(result.status, {})
			summary[result.status].setdefault("", 0)
			summary[result.status][""] += 1
			if result.detailed_status:
				summary[result.status].setdefault(result.detailed_status, 0)
				summary[result.status][result.detailed_status] += 1

			print(" ".join([
				f"{result.status.upper():<7}",
				f"{result.detailed_status or 'n/a':<31}",
				f"{test_name}",
			]))

			if not result.details:
				continue
			# Adding width of indent and ": " (4)
			key_col_width = round_up_to_multiple_of(max([len(k) for k in result.details.keys()]) + 4, 4)
			for k, v in sorted(result.details.items(), key = lambda kv: kv[0]):
				print(f"{'  ' + k + ': ':<{key_col_width}}{v}")

		header = "SUMMARY"
		line = "─" * (2 + len(header))
		print()
		print(line)
		print(f"{header}")
		print(line)
		print()

		summary_table: list[tuple[int, str, int]] = []
		for status, detailed_statuses in summary.items():
			summary_table += [(0, f"{status}: ", detailed_statuses.pop(""))]
			for detailed_status, count in detailed_statuses.items():
				summary_table += [(1, f"  {detailed_status}: ", count)]
		summary_table += [(2, "total: ", tests_num)]

		key_col_width = round_up_to_multiple_of(max([len(e[1]) for e in summary_table]), 4)
		for kind, key, count in summary_table:
			if kind == 0:
				key = key.upper()
			print(f"{key:<{key_col_width}}{count}")

		print()

		return 0

	def _handle_status_command(
		self,
		format: StatusOutputFormat,
		test_case_id_globs: list[str],
		**kwargs,
	) -> int:
		self._logger.debug(f"_handle_status_command")

		match format:
			case StatusOutputFormat.TTY:
				return self._handle_status_command_tty(test_case_id_globs, **kwargs)
			case StatusOutputFormat.PLAIN:
				return self._handle_status_command_plain(test_case_id_globs, **kwargs)

	def _get_test_case_list(self, test_case_id_globs: list[str]) -> dict[str, str]:
		self._logger.debug(f"_handle_list_command")

		test_config = self.config.tests[self._config_test_name]
		test_cases = test_config.get_tests(test_case_id_globs)

		return {
			n: str(p.relative_to(self.top_dir))
			for n, p in test_cases.items()
		}

	def __gen_task(self) -> TestStep:
		And, Or, All, Seq = AndTestStep, OrTestStep, AllTestStep, SeqTestStep

		yosys_command = dedent(r"""
			yosys -Q -q -q -l "${RESULTS_DIR}/${file_name_prefix}.log" ${extra_yosys_args} \
				-p "tee -o ${RESULTS_DIR}/${file_name_prefix}.ast.log ${read_cmd}" \
				-p "synth_xilinx" \
				-p "write_verilog ${RESULTS_DIR}/netlist.${netlist_id}.v"
		""").strip()

		yosys_status_check_script = dedent(r"""
			result=$?
			printf '%d\n' "$result" > "${RESULTS_DIR}/${file_name_prefix}.status.txt"
			if (( result != 0 )); then
				cat "${RESULTS_DIR}/${file_name_prefix}.stderr.log"
			fi
			exit $result
		""").strip()

		read_verilog_synth_cmd = CommandTestStep(
			name = "read_verilog_synth",
			cwd = r"${TEST_COLLECTION_DIR}/${TEST_SUBDIR}",
			command = yosys_command,
			stderr = r"${RESULTS_DIR}/${file_name_prefix}.stderr.log",
			status_check_script = yosys_status_check_script,
			parameter_substitutions = {
				"file_name_prefix": r"read_verilog_synth",
				"extra_yosys_args": r"",
				"read_cmd": r"read_verilog -dump_ast1 -sv ${TEST_FILE_NAME}",
				"netlist_id": r"ref",
			},
		)

		sv2v_cmd = CommandTestStep(
			name = "sv2v",
			cwd = r"${TEST_COLLECTION_DIR}/${TEST_SUBDIR}",
			command = dedent(r"""
				sv2v -w "${RESULTS_DIR}/sv2v_out.v" "${TEST_FILE_NAME}"
			""").strip(),
			stderr = r"${RESULTS_DIR}/sv2v.stderr.log",
			status_check_script = dedent(r"""
				result=$?
				printf '%d\n' "$result" > "${RESULTS_DIR}/sv2v.status.txt"
				if (( result != 0 )); then
					cat "${RESULTS_DIR}/sv2v.stderr.log"
				fi
				exit $result
			""").strip(),
		)

		read_verilog_synth_sv2v_cmd = CommandTestStep(
			name = "read_verilog_synth_sv2v",
			cwd = r"${TEST_COLLECTION_DIR}/${TEST_SUBDIR}",
			command = yosys_command,
			stderr = r"${RESULTS_DIR}/${file_name_prefix}.stderr.log",
			status_check_script = yosys_status_check_script,
			parameter_substitutions = {
				"file_name_prefix": r"read_verilog_synth_sv2v",
				"extra_yosys_args": r"",
				"read_cmd": r"read_verilog -dump_ast1 -sv ${RESULTS_DIR}/sv2v_out.v",
				"netlist_id": r"ref",
			},
		)

		read_systemverilog_synth_cmd = CommandTestStep(
			name = "read_systemverilog_synth",
			cwd = r"${TEST_COLLECTION_DIR}/${TEST_SUBDIR}",
			command = yosys_command,
			stderr = r"${RESULTS_DIR}/${file_name_prefix}.stderr.log",
			status_check_script = yosys_status_check_script,
			parameter_substitutions = {
				"file_name_prefix": r"read_systemverilog_synth",
				"extra_yosys_args": r"-m systemverilog",
				"read_cmd": r"read_systemverilog -dump_ast1 -mutestdout ${TEST_FILE_NAME}",
				"netlist_id": r"synlig",
			},
		)

		cleanup_netlist_command = dedent(r"""
			sed -r \
				-e 's|\b1'\''hx\b|1'\''h0|g' \
				-e 's` *\(\* src = "[a-zA-Z0-9_/|:.-]*" \*\) *``g' \
				-e 's` *\(\* keep = +1 +\*\) *``g' \
				-e '/^$/ d' \
				"netlist.${netlist_id}.v"
		""").strip()

		cleanup_netlist_status_check_script = dedent(r"""
			result=$?
			printf '%d\n' "$result" > "${RESULTS_DIR}/cleanup_${netlist_id}_netlist.status.txt"
			if (( result != 0 )); then
				cat "${RESULTS_DIR}/cleanup_${netlist_id}_netlist.stderr.log"
			fi
			exit $result
		""").strip()

		cleanup_ref_netlist_cmd = CommandTestStep(
			name = "cleanup_ref_netlist",
			cwd = r"${RESULTS_DIR}",
			command = cleanup_netlist_command,
			stdout = r"${RESULTS_DIR}/netlist.${netlist_id}.clean.v",
			stderr = r"${RESULTS_DIR}/cleanup_${netlist_id}_netlist.stderr.log",
			status_check_script = cleanup_netlist_status_check_script,
			parameter_substitutions = {
				"netlist_id": r"ref",
			},
		)

		cleanup_synlig_netlist_cmd = CommandTestStep(
			name = "cleanup_synlig_netlist",
			cwd = r"${RESULTS_DIR}",
			command = cleanup_netlist_command,
			stdout = r"${RESULTS_DIR}/netlist.${netlist_id}.clean.v",
			stderr = r"${RESULTS_DIR}/cleanup_${netlist_id}_netlist.stderr.log",
			status_check_script = cleanup_netlist_status_check_script,
			parameter_substitutions = {
				"netlist_id": r"synlig",
			},
		)

		compare_netlists_cmd = CommandTestStep(
			name = "compare_netlists",
			cwd = r"${RESULTS_DIR}",
			command = dedent(r"""
				cmp -s netlist.ref.clean.v netlist.synlig.clean.v
			""").strip(),
			status_check_script = dedent(r"""
				result=$?
				printf '%d\n' "$result" > "${RESULTS_DIR}/compare_netlists.status.txt"
				if (( result == 0 )); then
					echo "Netlists are equal"
				fi

				exit $result
			""").strip(),
		)

		find_top_module_cmd = CommandTestStep(
			name = "find_top_module",
			cwd = r"${RESULTS_DIR}",
			command = dedent(r"""
				sed -rn -e '/^Top module:/ { s/.*\\//g; p; q}' read_systemverilog_synth.log
			""").strip(),
			stderr = r"${RESULTS_DIR}/find_top_module.stderr.log",
			stdout = r"${RESULTS_DIR}/top_module_name.txt",
			status_check_script = dedent(r"""
				result=$?
				if (( result != 0 )); then
					cat "${RESULTS_DIR}/find_top_module.stderr.log",
				else
					cat "${RESULTS_DIR}/top_module_name.txt"
				fi
				exit $result
			""").strip(),
		)

		xilinx_cells_dir = self.product_dir / "share" / "yosys" / "xilinx"

		yosys_equiv_cmd = CommandTestStep(
			name = "yosys_equiv",
			cwd = r"${RESULTS_DIR}",
			command = dedent(r"""
				yosys -Q -q -q -l "${RESULTS_DIR}/${file_name_prefix}.log" -m systemverilog \
					-p "read_verilog -sv netlist.synlig.clean.v ${xilinx_cell_files}" \
					-p "prep -flatten -top ${top_module}" \
					-p "splitnets -ports;;" \
					-p "design -stash synlig" \
					-p "read_verilog -sv netlist.ref.clean.v ${xilinx_cell_files}" \
					-p "prep -flatten -top ${top_module}" \
					-p "splitnets -ports;;" \
					-p "design -stash ref" \
					-p "design -copy-from synlig -as synlig ${top_module}" \
					-p "design -copy-from ref -as ref ${top_module}" \
					-p "equiv_make synlig ref equiv" \
					-p "prep -flatten -top equiv" \
					-p "opt_clean -purge" \
					-p "opt -full" \
					-p "equiv_simple -seq 5" \
					-p "equiv_induct -seq 5" \
					-p "equiv_status -assert"
			""").strip(),
			stderr = r"${RESULTS_DIR}/${file_name_prefix}.out.log",
			stdout = r"${RESULTS_DIR}/${file_name_prefix}.out.log",
			status_check_script = dedent(r"""
				result=$?
				printf '%d\n' "$result" > "${RESULTS_DIR}/${file_name_prefix}.status.txt"
				if (( result != 0 )); then
					cat "${RESULTS_DIR}/${file_name_prefix}.out.log"
				else
					local pattern
					pattern='Equivalence successfully proven'
					if sed -n -e "/${pattern}/"' { s/^[ \t]*//; p; q0 }' -e '$ q1' "${RESULTS_DIR}/${file_name_prefix}.log"; then
						exit 0
					fi
					pattern='Proved 0 previously unproven \$equiv cells\.'
					if sed -n -e "/${pattern}/ { p; q0 }" -e '$ q1' "${RESULTS_DIR}/${file_name_prefix}.log"; then
						exit 1
					fi
				fi
				exit $result
			""").strip(),
			parameter_substitutions = {
				"file_name_prefix": r"yosys_equiv",
				"top_module": r"$(< top_module_name.txt)",
				"xilinx_cell_files": " ".join([
					str(xilinx_cells_dir / "cells_sim.v"),
					str(xilinx_cells_dir / "cells_xtra.v"),
				]),
			},
		)

		task = And([
			All([
				And([
					Or([
						read_verilog_synth_cmd,
						And([
							sv2v_cmd,
							read_verilog_synth_sv2v_cmd,
						]),
					]),
					cleanup_ref_netlist_cmd,
				]),
				And([
					read_systemverilog_synth_cmd,
					cleanup_synlig_netlist_cmd,
				]),
			]),
			Or([
				compare_netlists_cmd,
				Seq([
					find_top_module_cmd,
					yosys_equiv_cmd,
				]),
			]),
		])

		return task
