import enum
import re

from dataclasses import dataclass
from typing import Self

# Valid shell parameter (variable) name
_NAME_RE_PAT = r"(?:" + r"|".join([
	# Normal parameters, e.g. `$PWD`
	r"""[a-zA-Z_][a-zA-Z0-9_]*""",
	# "Special" single-character parameters, e.g. `$#`
	r"""[^0-9{}"'\\ \t\n\r\f]""",
	# Positional arguments, e.g. `$0`
	r"""[0-9]+""",
]) + r")"

_COMMAND_LEX = re.compile(
	"|".join([
		r"""(?P<dquote_start>")""",
		r"""(?P<param_exp>\$""" + _NAME_RE_PAT + r"""|\$\{""" + _NAME_RE_PAT + r"""\})""",
		r"""(?P<esc_nl>\\[\n])""",
		r"""(?P<esc_seq>\\.)""",
		r"""(?P<whitespace>[ \t\n\r\f]+)""",
		r"""(?P<squote_str>'[^']*')""",
		r"""(?P<str>[^"'$\\ \t\n\r\f]+)""",
	]),
	re.DOTALL,
)

_DOUBLE_QUOTE_LEX = re.compile(
	"|".join([
		r"""(?P<dquote_end>")""",
		r"""(?P<param_exp>\$""" + _NAME_RE_PAT + r"""|\$\{""" + _NAME_RE_PAT + r"""\})""",
		r"""(?P<esc_nl>\\[\n])""",
		r"""(?P<esc_seq>\\["$\\])""",
		r"""(?P<str>(?:[^"$\\]|\\[^"$\\\n])+)""",
	]),
	re.DOTALL,
)

_DOUBLE_QUOTED_PARAMETER_VALUE_LEX = re.compile(
	"|".join([
		r"""(?P<special>["$\\])""",
		r"""(?P<str>[^"$\\]+)""",
	]),
	re.DOTALL,
)

_PARAMETER_VALUE_LEX = re.compile(
	"|".join([
		r"""(?P<special>[`!#$^&*(){}[\]|'";<>?\\])""",
		r"""(?P<whitespace>[ \t\n\r\f]+)""",
		r"""(?P<str>[^`!#$^&*(){}[\]|'";<>?\\ \t\n\r\f]+)""",
	]),
	re.DOTALL,
)


class TokenKind(enum.IntEnum):
	STRING = enum.auto()
	WHITESPACE = enum.auto()
	ESCAPE_SEQUENCE = enum.auto()
	ESCAPED_NEW_LINE = enum.auto()
	PARAMETER_EXPANSION = enum.auto()
	SINGLE_QUOTED_STRING = enum.auto()
	DOUBLE_QUOTE_START = enum.auto()
	DOUBLE_QUOTE_END = enum.auto()


@dataclass(slots = True)
class Token:
	text: str
	kind: TokenKind

	def __str__(self):
		return self.text


class ShCmdTemplate:
	__slots__ = ("_tokens")

	def __init__(
		self,
		input: str | list[Token],
	):
		match input:
			case str():
				self._tokens: list[Token] = self._tokenize_word_list(input)
			case _:
				self._tokens: list[Token] = input

	def __str__(self):
		return self.to_sh_code()

	def __iter__(self):
		yield from self._tokens

	def get_parameter_list(self) -> set[str]:
		return {  #
			token.text[1:].strip(r"{}")
			for token in self._tokens
			if token.kind == TokenKind.PARAMETER_EXPANSION
		}

	def to_sh_code(self) -> str:
		return "".join(t.text for t in self._tokens)

	def to_argument_list(
		self,
		unexpanded_ok: bool = False,
	) -> list[str]:
		argv: list[str] = []

		start_new_arg = True
		inside_dquote = isinstance(self, ShStrTemplate)

		for t in self._tokens:
			if t.kind == TokenKind.WHITESPACE:
				start_new_arg = True
				continue

			match t.kind:
				case TokenKind.DOUBLE_QUOTE_START:
					if start_new_arg: argv.append("")
					inside_dquote = True
				case TokenKind.DOUBLE_QUOTE_END:
					inside_dquote = False
				case TokenKind.ESCAPE_SEQUENCE | TokenKind.ESCAPED_NEW_LINE:
					if start_new_arg: argv.append("")
					argv[-1] += t.text[1]
				case TokenKind.SINGLE_QUOTED_STRING:
					if start_new_arg: argv.append("")
					argv[-1] += t.text[1:-1]
				case TokenKind.STRING:
					if start_new_arg: argv.append("")
					argv[-1] += t.text
				case TokenKind.PARAMETER_EXPANSION if not unexpanded_ok:
					raise ValueError(f"Unexpanded parameter: {t.text}")
				case _:
					continue

			if start_new_arg: start_new_arg = False

		return argv

	def indent(
		self,
		indent: str = "\t",
	) -> Self:
		tokens: list[Token] = []
		inside_dquote = isinstance(self, ShStrTemplate)

		tokens.append(Token(indent, TokenKind.WHITESPACE))
		for t in self._tokens:
			match t.kind:
				case TokenKind.DOUBLE_QUOTE_START:
					inside_dquote = True
					tokens.append(t)
				case TokenKind.DOUBLE_QUOTE_END:
					inside_dquote = False
					tokens.append(t)
				case TokenKind.ESCAPED_NEW_LINE if not inside_dquote:
					tokens.append(Token(t.text, TokenKind.ESCAPED_NEW_LINE))
					tokens.append(Token(indent, TokenKind.WHITESPACE))
				case TokenKind.WHITESPACE if not inside_dquote:
					tokens.append(Token(t.text.replace("\n", "\n" + indent), TokenKind.WHITESPACE))
				case _:
					tokens.append(t)

		cls = ShStrTemplate if isinstance(self, ShStrTemplate) else ShCmdTemplate
		return cls(tokens)

	# Literally substitutes parameter expansions in the template with their
	# corresponding values from `parameters` and returns new reparsed template.
	def substitute_parameters(
		self,
		parameters: dict[str, str] | None = None,
		default_value: str | None = None,
		undefined_ok: bool | None = None,
	) -> Self:
		if parameters is None:
			parameters = {}
		# Accept undefined parameters if default_value has been set.
		if undefined_ok is None and default_value is not None:
			undefined_ok = True

		tokens: list[Token] = []

		for t in self._tokens:
			match t.kind:
				case TokenKind.PARAMETER_EXPANSION:
					name = t.text[1:].strip(r"{}")
					if not undefined_ok and name not in parameters:
						raise ValueError(f"Undefined parameter: {name}")
					if (pv := parameters.get(name, default_value)) is None:
						tokens.append(t)
					else:
						tokens.append(Token(pv, TokenKind.STRING))
				case _:
					tokens.append(t)

		# Reparse whole template. Less efficient, but simpler.
		cls = ShStrTemplate if isinstance(self, ShStrTemplate) else ShCmdTemplate
		return cls("".join(t.text for t in tokens))

	# Performs parameter substitution in a way similar to POSIX sh.
	def expand_parameters(
		self,
		parameters: dict[str, str] | None = None,
		default_value: str | None = None,
		undefined_ok: bool | None = None,
	) -> Self:
		if parameters is None:
			parameters = {}
		# Accept undefined parameters if default_value has been set.
		if undefined_ok is None and default_value is not None:
			undefined_ok = True

		tokens: list[Token] = []
		inside_dquote = isinstance(self, ShStrTemplate)

		for t in self._tokens:
			match t.kind:
				case TokenKind.DOUBLE_QUOTE_START:
					inside_dquote = True
					tokens.append(t)
				case TokenKind.DOUBLE_QUOTE_END:
					inside_dquote = False
					tokens.append(t)
				case TokenKind.PARAMETER_EXPANSION:
					name = t.text[1:].strip(r"{}")
					if not undefined_ok and name not in parameters:
						raise ValueError(f"Undefined parameter: {name}")
					if (pv := parameters.get(name, default_value)) is None:
						tokens.append(t)
					else:
						tokens.extend(self._tokenize_parameter_value(pv, inside_dquote = inside_dquote))
				case _:
					tokens.append(t)

		cls = ShStrTemplate if isinstance(self, ShStrTemplate) else ShCmdTemplate
		return cls(tokens)

	@staticmethod
	def _raise_syntax_error(input: str, pos: int):
		snippet = f"{input[pos:pos+29]}..." if (len(input) - pos) > 32 else input[pos:]
		raise SyntaxError(f"Unterminated or invalid sequence at position {pos}: {snippet!r}")

	@staticmethod
	def _tokenize_word_list(input: str) -> list[Token]:
		lexer = _COMMAND_LEX
		tokens: list[Token] = []
		i = 0
		double_quote_start_pos = -1

		while i < len(input):
			if (m := lexer.match(input[i:])) is not None:
				assert (m.start() == 0)
				assert (m.end() > 0)

				mtext = m.group(0)
				match m.lastgroup:
					case "whitespace":
						tokens.append(Token(mtext, TokenKind.WHITESPACE))
					case "str":
						tokens.append(Token(mtext, TokenKind.STRING))
					case "squote_str":
						tokens.append(Token(mtext, TokenKind.SINGLE_QUOTED_STRING))
					case "esc_seq":
						tokens.append(Token(mtext, TokenKind.ESCAPE_SEQUENCE))
					case "esc_nl":
						tokens.append(Token(mtext, TokenKind.ESCAPED_NEW_LINE))
					case "param_exp":
						tokens.append(Token(mtext, TokenKind.PARAMETER_EXPANSION))
					case "dquote_start":
						tokens.append(Token(mtext, TokenKind.DOUBLE_QUOTE_START))
						double_quote_start_pos = i
						lexer = _DOUBLE_QUOTE_LEX
					case "dquote_end":
						tokens.append(Token(mtext, TokenKind.DOUBLE_QUOTE_END))
						lexer = _COMMAND_LEX

				i += m.end()
			else:
				ShCmdTemplate._raise_syntax_error(input, i)

		# If that's the case, the input ended without closing double quote.
		if lexer == _DOUBLE_QUOTE_LEX:
			ShCmdTemplate._raise_syntax_error(input, double_quote_start_pos)

		return tokens

	@staticmethod
	def _tokenize_string(input: str) -> list[Token]:
		lexer = _DOUBLE_QUOTE_LEX
		tokens: list[Token] = []
		i = 0

		while i < len(input):
			if (m := lexer.match(input[i:])) is not None:
				assert (m.start() == 0)
				assert (m.end() > 0)

				mtext = m.group(0)
				match m.lastgroup:
					case "str":
						tokens.append(Token(mtext, TokenKind.STRING))
					case "esc_seq":
						tokens.append(Token(mtext, TokenKind.ESCAPE_SEQUENCE))
					case "esc_nl":
						tokens.append(Token(mtext, TokenKind.ESCAPED_NEW_LINE))
					case "param_exp":
						tokens.append(Token(mtext, TokenKind.PARAMETER_EXPANSION))
					case "dquote_end":
						tokens.append(Token(r"\"", TokenKind.ESCAPE_SEQUENCE))

				i += m.end()
			else:
				ShCmdTemplate._raise_syntax_error(input, i)

		return tokens

	@staticmethod
	def _tokenize_parameter_value(
		value: str,
		inside_dquote: bool = False,
	) -> list[Token]:
		lexer = _DOUBLE_QUOTED_PARAMETER_VALUE_LEX if inside_dquote else _PARAMETER_VALUE_LEX
		tokens: list[Token] = []
		i = 0

		while i < len(value):
			if (m := lexer.match(value[i:])) is not None:
				assert (m.start() == 0)
				assert (m.end() > 0)

				mtext = m.group(0)
				match m.lastgroup:
					case "str":
						tokens.append(Token(mtext, TokenKind.STRING))
					case "special":
						tokens.append(Token("\\" + mtext, TokenKind.ESCAPE_SEQUENCE))
					case "whitespace":
						tokens.append(Token(mtext, TokenKind.WHITESPACE))

				i += m.end()
			else:
				ShCmdTemplate._raise_syntax_error(value, i)

		return tokens


# TODO(mglb): Improve organization of Sh*Template common code. Right now everything is in ShCmdTemplate and checks `self` class when needed.


class ShStrTemplate(ShCmdTemplate):
	__slots__ = ("_tokens")

	def __init__(
		self,
		input: str | list[Token],
	):
		match input:
			case str():
				self._tokens: list[Token] = self._tokenize_string(input)
			case _:
				self._tokens: list[Token] = input

	def __str__(self):
		args = self.to_argument_list(unexpanded_ok = True)
		return args[0] if args else ""

	def to_sh_code(self) -> str:
		return "\"" + "".join(t.text for t in self._tokens) + "\""

	@classmethod
	def escape(cls, input: str) -> Self:
		return ShStrTemplate(cls._tokenize_parameter_value(input, True))


def highlight_syntax_for_tty(sct: ShCmdTemplate | ShStrTemplate) -> str:
	result: str = ""
	inside_dquote = isinstance(sct, ShStrTemplate)
	if inside_dquote: result += f"\x1b[40m"
	for token in sct:
		match token:
			case Token(kind = TokenKind.DOUBLE_QUOTE_START):
				inside_dquote = True
				result += f"\x1b[36m\"\x1b[40m"
			case Token(kind = TokenKind.DOUBLE_QUOTE_END):
				inside_dquote = False
				result += f"\x1b[49;36m\"\x1b[39m"
			case Token(text = t, kind = TokenKind.STRING) if inside_dquote:
				result += f"\x1b[96m{t}\x1b[39m"
			case Token(text = t, kind = TokenKind.STRING):
				result += f"\x1b[97m{t}\x1b[39m"
			case Token(text = t, kind = TokenKind.ESCAPE_SEQUENCE) if inside_dquote:
				result += f"\x1b[33m\\\x1b[96m{t[1]}\x1b[39m"
			case Token(text = t, kind = TokenKind.ESCAPE_SEQUENCE):
				result += f"\x1b[33m\\\x1b[22;39m{t[1]}\x1b[39m"
			case Token(kind = TokenKind.ESCAPED_NEW_LINE) if inside_dquote:
				result += f"\x1b[33;49m\\\x1b[39m\n\x1b[40m"
			case Token(kind = TokenKind.ESCAPED_NEW_LINE):
				result += f"\x1b[33m\\\x1b[39m\n"
			case Token(text = t, kind = TokenKind.WHITESPACE):
				result += f"\x1b[30m{t}\x1b[39m"
			case Token(text = t, kind = TokenKind.PARAMETER_EXPANSION) if t[-1] == "}":
				result += f"\x1b[32m${{\x1b[1;92m{t[2:-1]}\x1b[22;32m}}\x1b[39m"
			case Token(text = t, kind = TokenKind.PARAMETER_EXPANSION):
				result += f"\x1b[32m$\x1b[1;92m{t[1:]}\x1b[22;39m"
			case Token(text = t, kind = TokenKind.SINGLE_QUOTED_STRING):
				result += f"\x1b[34m'\x1b[94;40m{t[1:-1]}\x1b[34;49m'\x1b[39m"
			case _:
				raise ValueError(token)
	result += f"\x1b[0m"
	return result


# Small test/demo
if __name__ == "__main__":
	from textwrap import dedent

	samples = [
		dedent(r"""
		empty dquote:       ""
		valid escapes:      "dquote \" backslash \\ dollar \$"
		invalid escapes:    "n \n ' \' ; \; | \|"
		escaped line break: "before\
		after"
		line break:         "before
		after"
		parameters:         "inside {}: /${TEST_FILE}/ without {}: /$TEST_SUBDIR/ undefined: $FooBarBaz"
		""").strip(),
		dedent(r"""
		valid escapes:      dquote \" backslash \\ dollar \$ n \n apos \' semicolon \; pipe \|
		escaped line break: before\
		after
		parameters:         inside {}: /${TEST_FILE}/ without {}: /$TEST_SUBDIR/ ${FooBarBaz}
		""").strip(),
		dedent(r"""
		single quote:       'hello, world. $PWD ${SHELL}'
		line break:         'before
		after'
		""").strip(),
		dedent(r"""
		mix:                "dquote"noquote'squote' $? $$ ${?} ${$}
		escapes:            'squote with ->'\''apos'\''<-'
		""").strip(),
	]

	for sample in samples:
		s = ShCmdTemplate(sample)
		print("====================")
		print(highlight_syntax_for_tty(s))
		print("--------------------")
		print(s.get_parameter_list())
		print(s.to_argument_list(unexpanded_ok = True))

		se = s.expand_parameters({
			"TEST_COLLECTION_DIR": "Test Collection Dir",
			"TEST_SUBDIR": "\"Test Subdir\"",
			"TEST_FILE": "'Test File'",
		}, undefined_ok = True)
		print("--------------------")
		print(highlight_syntax_for_tty(se))
		print("--------------------")
		print(se.get_parameter_list())
		print(se.to_argument_list(unexpanded_ok = True))
		print("--------------------")
