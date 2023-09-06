#!/usr/bin/env python3
import sys
import argparse
import re
from pathlib import Path
from typing import Union, Iterable

import pygraphviz as pgv


class MakefileEmitter:
	def __init__(self):
		self._content = ""

	def __str__(self):
		return self._content.strip("\n") + "\n"

	def emit_target_prerequisites(self, target_name: str, normal_prerequisites: Iterable[str], order_only_prerequisites: Iterable[str] = []):
		normal_prerequisites_str = " ".join(normal_prerequisites)
		order_only_prerequisites_str = " ".join(order_only_prerequisites)

		self._content += f"{target_name} :"
		if normal_prerequisites_str:
			self._content += f" {normal_prerequisites_str}"
		if order_only_prerequisites_str:
			self._content += f" | {order_only_prerequisites_str}"
		self._content += "\n"

	def emit_separator(self):
		if not self._content.endswith("\n\n"):
			self._content += f"\n"

	def emit_var(self, var_name: str, value: Union[str, Iterable[str]]):
		self._content += f"{var_name} :="
		if not value:
			self._content += "\n"
			return None

		if isinstance(value, str):
			self._content += f" {value}\n"
			return None

		for item in value:
			self._content += f" \\\n\t\t{item}"
		self._content += "\n"

	def emit_target_var(self, target_name: str, var_name: str, value: Union[str, Iterable[str]]):
		self.emit_var(f"{target_name} : {var_name}", value)


def main():
	parser = argparse.ArgumentParser(description=None)
	parser.add_argument("--core-vars-prefix", type=str, default="",
			help="Prefix prepended to variables: core_names, core_deps, core_users.")
	parser.add_argument("--all-cores-var-name", type=str, default=None,
			help="Name of a variable storing list of all cores.")
	parser.add_argument("--top-cores-var-name", type=str, default=None,
			help="Name of a variable storing list of top cores.")
	parser.add_argument("--leaf-cores-var-name", type=str, default=None,
			help="Name of a variable storing list of leaf cores.")

	parser.add_argument("input_dot_path", type=Path,
			help="Path to input .dot file")
	parser.add_argument("output_makefile_path", type=Path,
			help="Path to output Makefile")

	args = parser.parse_args()

	SANITIZE_CORE_NAME_RE = re.compile(r"[^a-zA-Z0-9-_.:]")
	def sanitize_core_name(name: str) -> str:
		return SANITIZE_CORE_NAME_RE.sub("_", name.replace(":", "."))

	all_cores_list = []
	top_cores_list = []
	leaf_cores_list = []

	makefile = MakefileEmitter()

	dotgraph = pgv.AGraph(args.input_dot_path)
	for node in dotgraph.nodes_iter():
		core_name = str(node)
		core_id = sanitize_core_name(core_name)

		all_cores_list.append(core_id)

		if not next(dotgraph.in_edges_iter(node), None):
			top_cores_list.append(core_id)
		if not next(dotgraph.out_edges_iter(node), None):
			leaf_cores_list.append(core_id)

		deps = (sanitize_core_name(str(dep)) for dep in dotgraph.successors_iter(node))
		users = (sanitize_core_name(str(user)) for user in dotgraph.predecessors_iter(node))
		makefile.emit_separator()
		makefile.emit_var(f"{args.core_vars_prefix}core_names[{core_id}]", core_name)
		makefile.emit_var(f"{args.core_vars_prefix}core_deps[{core_id}]", deps)
		makefile.emit_var(f"{args.core_vars_prefix}core_users[{core_id}]", users)

	if args.top_cores_var_name:
		makefile.emit_separator()
		makefile.emit_var(args.top_cores_var_name, top_cores_list)

	if args.leaf_cores_var_name:
		makefile.emit_separator()
		makefile.emit_var(args.leaf_cores_var_name, leaf_cores_list)

	if args.all_cores_var_name:
		makefile.emit_separator()
		makefile.emit_var(args.all_cores_var_name, all_cores_list)

	with open(args.output_makefile_path, "w") as f:
		f.write(str(makefile))


if __name__ == "__main__":
	sys.exit(main())
