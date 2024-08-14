#!/usr/bin/env python3

ANSI_RED    = "\033[0;31m"
ANSI_GREEN  = "\033[0;32m"
ANSI_YELLOW = "\033[0;33m"
ANSI_BLUE   = "\033[0;35m"
ANSI_NONE   = "\033[0m"

def ansi_color(text, ansi_code):
	return ansi_code + text + ANSI_NONE

def color_result(result):
	if result == "PASS" or result == "converted":
		return ansi_color(result, ANSI_GREEN)
	else:
		return ansi_color(result, ANSI_RED)
