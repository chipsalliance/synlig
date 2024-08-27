/*
 * Copyright 2020-2022 F4PGA Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 */

#include "uhdm_common_frontend.h"
#include "synlig_edif.h"

#ifdef __linux__
namespace Yosys
{
using AST::AstNode;
using RTLIL::Design;

namespace AST
{
extern void process(Design *, AstNode *, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool,
                    bool, bool, bool);
} // namespace AST
} // namespace Yosys
#endif

namespace systemverilog_plugin
{

using namespace ::Yosys;

/* Stub for AST::process */
static void set_line_num(int) {}

/* Stub for AST::process */
static int get_line_num(void) { return 1; }

UhdmCommonFrontend::UhdmCommonFrontend(std::string name, std::string short_help) : Frontend(name, short_help) { register_synlig_edif_backend(); }

void UhdmCommonFrontend::print_read_options()
{
    log("    -noassert\n");
    log("        ignore assert() statements");
    log("\n");
    log("    -debug\n");
    log("        alias for -dump_ast1 -dump_ast2 -dump_vlog1 -dump_vlog2\n");
    log("\n");
    log("    -dump_ast1\n");
    log("        dump abstract syntax tree (before simplification)\n");
    log("\n");
    log("    -dump_ast2\n");
    log("        dump abstract syntax tree (after simplification)\n");
    log("\n");
    log("    -no_dump_ptr\n");
    log("        do not include hex memory addresses in dump (easier to diff dumps)\n");
    log("\n");
    log("    -dump_vlog1\n");
    log("        dump ast as Verilog code (before simplification)\n");
    log("\n");
    log("    -dump_vlog2\n");
    log("        dump ast as Verilog code (after simplification)\n");
    log("\n");
    log("    -dump_rtlil\n");
    log("        dump generated RTLIL netlist\n");
    log("\n");
    log("    -defer\n");
    log("        only read the abstract syntax tree and defer actual compilation\n");
    log("        to a later 'hierarchy' command. Useful in cases where the default\n");
    log("        parameters of modules yield invalid or not synthesizable code.\n");
    log("        Needs to be followed by read_systemverilog -link after reading\n");
    log("        all files.\n");
    log("\n");
    log("    -link\n");
    log("        performs linking and elaboration of the files read with -defer\n");
    log("\n");
    log("    -parse-only\n");
    log("        this parameter only applies to read_systemverilog command,\n");
    log("        it runs only Surelog to parse design, but doesn't load generated\n");
    log("        tree into Yosys.\n");
    log("\n");
    log("    -formal\n");
    log("        enable support for SystemVerilog assertions and some Yosys extensions\n");
    log("        replace the implicit -D SYNTHESIS with -D FORMAL\n");
    log("\n");
    log("    -parseall\n");
    log("        enable non-synthesizable SystemVerilog code which is discarded by default\n");
    log("\n");
}

void UhdmCommonFrontend::execute(std::istream *&f, std::string filename, std::vector<std::string> args, RTLIL::Design *design)
{
    this->call_log_header(design);
    this->args = args;

    bool defer = false;
    bool dump_ast1 = false;
    bool dump_ast2 = false;
    bool dump_vlog1 = false;
    bool dump_vlog2 = false;
    bool no_dump_ptr = false;
    bool dump_rtlil = false;
    std::vector<std::string> unhandled_args;

    for (size_t i = 0; i < args.size(); i++) {
        if (args[i] == "-debug") {
            dump_ast1 = true;
            dump_ast2 = true;
            dump_vlog1 = true;
            dump_vlog2 = true;
            this->shared.debug_flag = true;
        } else if (args[i] == "-noassert") {
            this->shared.no_assert = true;
        } else if (args[i] == "-defer") {
            this->shared.defer = true;
        } else if (args[i] == "-dump_ast1") {
            dump_ast1 = true;
        } else if (args[i] == "-dump_ast2") {
            dump_ast2 = true;
        } else if (args[i] == "-dump_vlog1") {
            dump_vlog1 = true;
        } else if (args[i] == "-dump_vlog2") {
            dump_vlog2 = true;
        } else if (args[i] == "-no_dump_ptr") {
            no_dump_ptr = true;
        } else if (args[i] == "-dump_rtlil") {
            dump_rtlil = true;
        } else if (args[i] == "-parse-only") {
            this->shared.parse_only = true;
        } else if (args[i] == "-link") {
            this->shared.link = true;
            // Surelog needs it in the command line to link correctly
            unhandled_args.push_back(args[i]);
        } else if (args[i] == "-formal") {
            this->shared.formal = true;
            // Surelog needs it in the command line to annotate UHDM
            unhandled_args.push_back(args[i]);
        } else if (args[i] == "-parseall") {
            this->shared.disable_synth = true;
        } else {
            unhandled_args.push_back(args[i]);
        }
    }
    // Yosys gets confused when extra_args are passed with -link or no option
    // It's done fully by Surelog, so skip it in this case
    if (!this->shared.link)
        extra_args(f, filename, args, args.size() - 1);
    // pass only unhandled args to Surelog
    // unhandled args starts with command name,
    // but Surelog expects args[0] to be program name
    // and skips it
    this->args = unhandled_args;

    AST::current_filename = filename;
    AST::set_line_num = &set_line_num;
    AST::get_line_num = &get_line_num;

    AST::AstNode *current_ast = parse(filename);

    if (current_ast) {
        Yosys::AST::process(design, current_ast,
                            false, // nodisplay
                            dump_ast1, dump_ast2, no_dump_ptr, dump_vlog1, dump_vlog2, dump_rtlil,
                            false, // nolatches
                            false, // nomeminit
                            false, // nomem2reg
                            false, // mem2reg
                            false, // noblackbox
                            false, // lib
                            false, // nowb
                            false, // noopt
                            false, // icells
                            false, // pwires
                            false, // nooverwrite
                            false, // overwrite
                            defer, // defer
                            true   // autowire
        );
        delete current_ast;
    }
}

} // namespace systemverilog_plugin
