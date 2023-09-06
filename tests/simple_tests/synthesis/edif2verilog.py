#!/usr/bin/env python3

import os, sys

# ############### lexer ########################################### #
import ply.lex as lex

tokens = (
  'LPAREN',
  'RPAREN',
  'NUMBER',
  'NAME',
  'STRING',
)

t_LPAREN  = r'\('
t_RPAREN  = r'\)'
t_NAME    = r'[a-zA-Z_][a-zA-Z0-9_]*'
t_STRING  = r'".*"'

def t_NUMBER(t):
    r'\d+'
    t.value = int(t.value)
    return t

def t_error(t):
    print("Illegal character '%s'" % t.value[0])
    t.lexer.skip(1)

# Ignored characters
t_ignore = " \t"

def t_newline(t):
    r'\n+'
    t.lexer.lineno += t.value.count("\n")

lexer = lex.lex()
# ################################################################## #
import ply.yacc as yacc

def p_expression_group(p):
    'expression : LPAREN expression_list RPAREN'
    p[0] = p[2]

def p_expression_list(p):
    '''expression_list : expression_list expression
                       | expression'''
    if len(p) == 2:
        p[0] = list()
        p[0].append(p[1])
    else:
        p[0] = p[1]
        p[0].append(p[2])

def p_expression_number(p):
    'expression : NUMBER'
    p[0] = p[1]

def p_expression_name(p):
    'expression : NAME'
    p[0] = p[1]

def p_expression_string(p):
    'expression : STRING'
    p[0] = p[1]

def p_error(p):
    print(f"Syntax error at {p.value!r}")

yacc.yacc()
# ################################################################## #

external_libs = dict()

def analyze_port(x):
    assert(x[0] == 'port')
    name = x[1]
    assert(type(name) == str)

    port = dict()
    port['name'] = name

    port['input']     = False
    port['output']    = False
    port['direction'] = None

    i = 2
    while i < len(x):
        key = x[i]
        if key[0] == 'direction':
            direction = key[1]
            if direction == 'INPUT':
                port['input'] = True
                port['direction'] = 'in'
            elif direction == 'OUTPUT':
                port['output'] = True
                port['direction'] = 'out'
            else:
                print('Unknown direction: %s' % direction)
        else:
            print('Unknown: %s' % key[0])
        i = i + 1

    return port


def analyze_ref(x):
    assert(x[0] == 'portRef')
    ref = dict()
    ref['name'] = x[1]
    if (len(x) >= 3):
        instance = x[2]
        assert(instance[0] == 'instanceRef');
        ref['instance'] = instance[1]

    return ref


def analyze_cellref(x):
    assert(x[0] == 'cellRef')
    ref = dict()
    ref['name'] = x[1];

    libref = x[2]
    assert(libref[0] == 'libraryRef')
    ref['library'] = ref['lib'] = libref[1]

    return ref


def analyze_viewref(x):
    assert(x[0] == 'viewRef')
    assert(x[1] == 'VIEW_NETLIST')
    return analyze_cellref(x[2])


def analyze_contents(x):
    assert(x[0] == 'contents')
    contents = dict()
    contents['instances'] = dict()
    contents['nets'] = dict()

    i = 1
    while i < len(x):
        item = x[i]
        i = i + 1

        if item[0] == 'instance':
            name = item[1]

            if type(name) == list:
                assert(name[0] == 'rename')
                name = name[1]

            instance = dict()
            instance['name'] = name

            ref = analyze_viewref(item[2])
            instance['ref'] = ref

            assert(name not in contents['instances'].keys())
            contents['instances'][name] = instance

        elif item[0] == 'net':
            name = item[1]
            if type(name) == list:
                assert(name[0] == 'rename');
                name = name[1]

            net = dict()
            net['name'] = name
            net['join'] = []

            join = item[2]
            assert(join[0] == 'joined')
            ref = analyze_ref(join[1])
            net['join'].append(ref)
            ref = analyze_ref(join[2]);
            net['join'].append(ref)
            assert(len(net['join']) == 2)

            assert(name not in contents['nets'].keys())
            contents['nets'][name] = net

        else:
            print('  contents: Unknown key: %s' % item[0])

    return contents


def analyze_cell(x):
    key  = x[0]
    name = x[1]

    cell = dict()
    cell['name']  = name
    cell['ports'] = dict()

    i = 2
    while i < len(x):
        item = x[i]
        if item[0] == 'view':
            j = 2
            while j < len(item):
                view_item = item[j]
                j = j + 1

                if view_item[0] == 'viewType':
                    assert(view_item[1] == 'NETLIST')
                elif view_item[0] == 'interface':
                    k = 1
                    while k < len(view_item):
                        intf_item = view_item[k]
                        k = k + 1

                        if intf_item[0] == 'port':
                            tmp_port = analyze_port(intf_item)
                            cell['ports'][tmp_port['name']] = tmp_port
                        else:
                            print('Unknown: %s' % intf_item[0])
                elif view_item[0] == 'contents':
                    cell['contents'] = analyze_contents(view_item)
                else:
                    print('  Unknown: %s' % view_item[0]);

        i = i + 1

    return cell


def analyze(x):
    key = x[0]
    if key == 'edif':
        name = x[1]
        print("Design name: '%s'" % name)
        i = 2;
        while (i < len(x)):
            analyze(x[i])
            i = i + 1
    elif key == 'edifVersion':
        version = str(x[1]) + '.' + str(x[2]) + '.' + str(x[3])
        print("Format version: v%s" % version)
    elif key == 'external' or key == 'library' or key == 'design':
        name = str(x[1])
        print("Library name: %s" % name)
        extlib = external_libs.get(name)

        assert(extlib is None)

        extlib = dict()
        extlib['name'] = name

        extlib['external'] = False
        extlib['design']   = False

        if key == 'external':
            extlib['external'] = True
        elif key == 'design':
            extlib['design'] = True

        extlib['cells'] = dict()

        # FIXME: Temporary
        extlib['ref'] = None

        i = 2
        while (i < len(x)):
            itr = x[i]
            i = i + 1

            itr_key = itr[0];
            if itr_key == 'cell':
                cell = analyze_cell(itr)
                if cell is not None:
                    extlib['cells'][cell['name']] = cell

            elif itr_key == 'cellRef':
                cellref = analyze_cellref(itr)
                assert(extlib['ref'] == None) # FIXME: Temporary
                extlib['ref'] = cellref

            else:
                print('Unknown key: %s' % itr_key)

        external_libs[name] = extlib

    else:
        print('Unknown: ' + key)


# ################################################################## #

def dump_ref(x):
    lib  = x['library']
    name = x['name']
    print('Dumping %s from %s' % (name, lib))

    lib  = external_libs[lib]
    cell = lib['cells'][name]

    cell_name  = cell['name']
    cell_ports = cell['ports']

    fd = open('top.edif.v', 'w')

    fd.write('module %s (\n' % cell_name)
    n = len(cell_ports)
    i = 0
    for port in cell_ports:
        i = i + 1
        if i == n:
            fd.write('    %s\n' % port)
        else:
            fd.write('    %s,\n' % port);

    fd.write(');\n')


    if 'contents' in cell.keys():
        contents  = cell['contents']
        instances = contents['instances']
        nets      = contents['nets']

        # numerate nets
        i = 0
        for n in nets:
            if nets[n]['name'] in cell_ports:
                nets[n]['id'] = nets[n]['name']
            else:
                nets[n]['id'] = i
                i += 1

        # ... and instances
        for instance in instances:
            instances[instance]['id'] = i
            i = i + 1

        for n in nets:
            net = nets[n]
            net_id = net['id']
            if net_id in cell_ports:
                port = cell_ports[net_id]
                if port['input']:
                    fd.write('  input %s;\n' % net_id)
                elif port['output']:
                    fd.write('  output %s;\n' % net_id)

            else:
                fd.write('  wire _%d_;\n' % net_id)

        for i in instances:
            instance = instances[i]
            fd.write('  %s _%d_ (\n' % (instance['ref']['name'], instance['id']))

            refname = instance['ref']['name']
            reflib  = instance['ref']['lib']
            lib = external_libs[reflib]
            item = lib['cells'][refname]
            portnum = len(item['ports'])

            porti = 0
            for n in nets:
                net = nets[n]
                for j in net['join']:
                    if 'instance' in j:
                        if j['instance'] == i:
                            porti = porti + 1
                            comma = ''
                            if porti < portnum:
                                comma = ','

                            if type(net['id']) != str:
                                fd.write('      .%s(_%d_)%s\n' % (j['name'], net['id'], comma))
                            else:
                                fd.write('      .%s(%s)%s\n' % (j['name'], net['id'], comma))

            fd.write('    );\n')


    fd.write('endmodule\n')
    fd.close()


# ################################################################## #

def main():
  with open('top.edif', 'r') as fp:
    fd = fp.read()
    x = yacc.parse(fd)
    analyze(x)

    for extlib in external_libs.keys():
        lib = external_libs[extlib]
        if lib['design']:
            print('Design libarary: %s' % lib['name'])
            if lib['ref'] != None:
                dump_ref(lib['ref'])


if __name__ == "__main__":
    main()
