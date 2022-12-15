#!/usr/bin/env python3
"""Executes FuseSoC for each of the cores in dependency graph and stores results
It uses 'lowrisc_dv_chip_yosys_synth_0.dot' file as input,
and writes results to 'result.txt' and 'graph.dot'

Usage:
    ./iterate_cores.py
"""
from subprocess import run
from enum import Enum
import pygraphviz as pgv
import networkx as nx

dot_graph = pgv.AGraph('lowrisc_dv_chip_yosys_synth_0.dot')
graph = nx.DiGraph(dot_graph)

class Status(Enum):
    FAILED = 1
    PASSED = 2
    UNKNOWN = 3
    SKIPPED = 4

nx.set_node_attributes(graph, {node: Status.UNKNOWN for node in graph}, 'status')
root = [node for node, degree in graph.in_degree() if degree == 0][0]
nodes = reversed(list(nx.topological_sort(graph)))

def process_node(graph, node):
    status = nx.get_node_attributes(graph, 'status')[node]
    if status == Status.UNKNOWN:
        cmd = ['fusesoc', '--cores-root=.', 'run', '--flag=fileset_ip', '--target=default', '--build', '--tool=yosys', node]
        print('running: ' + ' '.join(cmd))
        fuse = run(cmd, shell=False, capture_output=False)
        if fuse.returncode == 0:
            nx.set_node_attributes(graph, {node: Status.PASSED}, 'status')
        else:
            nx.set_node_attributes(graph, {node: Status.FAILED}, 'status')

for node in nodes:
    children_names = list(graph[node])
    # If any of the children failed, skip this node
    for child in children_names:
        status = nx.get_node_attributes(graph, 'status')[child]
        if  status == Status.FAILED or status == Status.SKIPPED:
            nx.set_node_attributes(graph, {node: Status.SKIPPED}, 'status')
            break
    if nx.get_node_attributes(graph, 'status')[node] == Status.SKIPPED:
        continue
    process_node(graph, node)

# write markdown table with results
with open('result.txt', 'w') as f:
    f.write('| Name | Result |\n')
    f.write('|------|--------|\n')

    status_labels = {
        Status.PASSED: ':heavy_check_mark: PASSED',
        Status.FAILED: ':x: FAILED',
        Status.SKIPPED: ':heavy_minus_sign: SKIPPED',
    }
    for node in graph:
        status = nx.get_node_attributes(graph, 'status')[node]
        status_label = status_labels.get(status, status.name)
        f.write(f'| {node} | {status_label} |\n')

    passed = len([status for status in nx.get_node_attributes(graph, 'status').values() if status == Status.PASSED])
    failed = len([status for status in nx.get_node_attributes(graph, 'status').values() if status == Status.FAILED])
    skipped = len([status for status in nx.get_node_attributes(graph, 'status').values() if status == Status.SKIPPED])

    f.write('\n')
    f.write('|  |  |\n')
    f.write('|--|--|\n')
    f.write(f'| PASSED | {passed} |\n')
    f.write(f'| FAILED | {failed} |\n')
    f.write(f'| SKIPPED | {skipped} |\n')
    f.write('\n')


# set node colors and status attributes
for node in graph:
    status = nx.get_node_attributes(graph, 'status')[node]
    if status == Status.FAILED:
        nx.set_node_attributes(graph, {node: 'red'}, 'fillcolor')
        nx.set_node_attributes(graph, {node: 'filled'}, 'style')
    if status == Status.PASSED:
        nx.set_node_attributes(graph, {node: 'lightblue'}, 'fillcolor')
        nx.set_node_attributes(graph, {node: 'filled'}, 'style')

    nx.set_node_attributes(graph, {node: status.name}, 'status')

graph.graph['graph']={'rankdir':'LR'}
nx.drawing.nx_agraph.write_dot(graph, 'graph.dot')
