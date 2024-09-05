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

#include "frontends/ast/ast.h"
#include "kernel/yosys.h"
#include "uhdm_ast.h"
#include "uhdm_common_frontend.h"

#if defined(_MSC_VER)
#include <direct.h>
#include <process.h>
#else
#include <sys/param.h>
#include <unistd.h>
#endif
#include <memory>

#include <list>

#include "Surelog/API/Surelog.h"
#include "Surelog/CommandLine/CommandLineParser.h"
#include "Surelog/ErrorReporting/ErrorContainer.h"
#include "Surelog/SourceCompile/SymbolTable.h"
#include "uhdm/uhdm-version.h" // UHDM_VERSION define
#include "uhdm/vpi_visitor.h"  // visit_object

namespace systemverilog_plugin
{

using namespace ::Yosys;

// Store systemverilog defaults to be passed for every invocation of read_systemverilog
static std::vector<std::string> systemverilog_defaults;
static std::list<std::vector<std::string>> systemverilog_defaults_stack;

// Store global definitions for top-level defines
static std::vector<std::string> systemverilog_defines;

// SURELOG::scompiler wrapper.
// Owns UHDM/VPI resources used by designs returned from `execute`
class Compiler
{
  public:
    Compiler() = default;
    ~Compiler()
    {
        if (this->scompiler) {
            SURELOG::shutdown_compiler(this->scompiler);
        }
    }

    const std::vector<vpiHandle> &execute(std::unique_ptr<SURELOG::ErrorContainer> errors, std::unique_ptr<SURELOG::CommandLineParser> clp)
    {
        log_assert(!this->errors && !this->clp && !this->scompiler);

        bool success = true;
        bool noFatalErrors = true;
        unsigned int codedReturn = 0;
        clp->setWriteUhdm(false);
        errors->printMessages(clp->muteStdout());
        if (success && (!clp->help())) {
            this->scompiler = SURELOG::start_compiler(clp.get());
            if (!this->scompiler)
                codedReturn |= 1;
            this->designs.push_back(SURELOG::get_uhdm_design(this->scompiler));
        }
        SURELOG::ErrorContainer::Stats stats;
        if (!clp->help()) {
            stats = errors->getErrorStats();
            if (stats.nbFatal)
                codedReturn |= 1;
            if (stats.nbSyntax)
                codedReturn |= 2;
        }
        bool noFErrors = true;
        if (!clp->help())
            noFErrors = errors->printStats(stats, clp->muteStdout());
        if (noFErrors == false) {
            noFatalErrors = false;
        }
        if ((!noFatalErrors) || (!success) || (errors->getErrorStats().nbError))
            codedReturn |= 1;
        if (codedReturn) {
            log_error("Error when parsing design. Aborting!\n");
        }

        this->clp = std::move(clp);
        this->errors = std::move(errors);

        return this->designs;
    }

  private:
    std::unique_ptr<SURELOG::ErrorContainer> errors = nullptr;
    std::unique_ptr<SURELOG::CommandLineParser> clp = nullptr;
    SURELOG::scompiler *scompiler = nullptr;
    std::vector<vpiHandle> designs = {};
};

struct UhdmSurelogAstFrontend : public UhdmCommonFrontend {
    UhdmSurelogAstFrontend(std::string name, std::string short_help) : UhdmCommonFrontend(name, short_help) {}
    UhdmSurelogAstFrontend() : UhdmCommonFrontend("verilog_with_uhdm", "generate/read UHDM file")
    {
#ifndef SYNLIG_STANDALONE_BINARY
        log_warning("Using synlig as yosys plugin is deprecated. It is recommended to build synlig as standalone binary.\n");
#endif
    }

    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("    read_verilog_with_uhdm [options] [filenames]\n");
        log("\n");
        log("Read SystemVerilog files using Surelog into the current design\n");
        log("\n");
        this->print_read_options();
    }

    AST::AstNode *parse(std::string filename) override
    {
        std::vector<const char *> cstrings;
        bool link = false;
        if (this->shared.formal) {
            systemverilog_defines.push_back("-DFORMAL=1");
        } else {
            systemverilog_defines.push_back("-DSYNTHESIS=1");
        }
        cstrings.reserve(this->args.size() + systemverilog_defaults.size() + systemverilog_defines.size());
        for (size_t i = 0; i < this->args.size(); ++i) {
            cstrings.push_back(const_cast<char *>(this->args[i].c_str()));
            if (this->args[i] == "-link")
                link = true;
        }

        if (!link) {
            // Add systemverilog defaults args
            for (size_t i = 0; i < systemverilog_defaults.size(); ++i) {
                // Convert args to surelog compatible
                if (systemverilog_defaults[i] == "-defer")
                    this->shared.defer = true;
                // Pass any remainings args directly to surelog
                else
                    cstrings.push_back(const_cast<char *>(systemverilog_defaults[i].c_str()));
            }

            // Add systemverilog defines args
            for (size_t i = 0; i < systemverilog_defines.size(); ++i)
                cstrings.push_back(const_cast<char *>(systemverilog_defines[i].c_str()));
        }

        auto symbolTable = std::make_unique<SURELOG::SymbolTable>();
        auto errors = std::make_unique<SURELOG::ErrorContainer>(symbolTable.get());
        auto clp = std::make_unique<SURELOG::CommandLineParser>(errors.get(), symbolTable.get(), false, false);
        bool success = clp->parseCommandLine(cstrings.size(), &cstrings[0]);
        if (!success) {
            log_error("Error parsing Surelog arguments!\n");
        }
        // Force -parse flag settings even if it wasn't specified
        clp->setwritePpOutput(true);
        clp->setParse(true);
        clp->fullSVMode(true);
        clp->setCacheAllowed(true);
        if (!this->shared.disable_synth) {
            clp->setReportNonSynthesizable(true);
        }
        if (this->shared.defer) {
            clp->setCompile(false);
            clp->setElaborate(false);
            clp->setSepComp(true);
        } else {
            clp->setCompile(true);
            clp->setElaborate(true);
            clp->setElabUhdm(true);
        }
        if (this->shared.link) {
            clp->setLink(true);
        }

        Compiler compiler;
        const auto &uhdm_designs = compiler.execute(std::move(errors), std::move(clp));

        // on parse_only mode, don't try to load design
        // into yosys
        if (this->shared.parse_only)
            return nullptr;

        if (this->shared.defer && !this->shared.link)
            return nullptr;

        // FIXME: SynthSubset annotation is incompatible with separate compilation
        // `-defer` turns elaboration off, so check for it
        // Should be called 1. for normal flow 2. after finishing with `-link`
        if (!this->shared.defer) {
            vpiHandle designH = uhdm_designs.at(0);
            UHDM::design *design = UhdmDesignFromVpiHandle(designH);
            UHDM::Serializer serializer;
            UHDM::SynthSubset *synthSubset =
              make_new_object_with_optional_extra_true_arg<UHDM::SynthSubset>(&serializer, this->shared.nonSynthesizableObjects, design, false);
            synthSubset->listenDesigns(uhdm_designs);
            delete synthSubset;
        }

        UhdmAst uhdm_ast(this->shared);
        AST::AstNode *current_ast = uhdm_ast.visit_designs(uhdm_designs);

        // FIXME: Check and reset remaining shared data
        this->shared.top_nodes.clear();
        this->shared.nonSynthesizableObjects.clear();
        return current_ast;
    }
    void call_log_header(RTLIL::Design *design) override { log_header(design, "Executing Verilog with UHDM frontend.\n"); }
} UhdmSurelogAstFrontend;

struct UhdmSystemVerilogFrontend : public UhdmSurelogAstFrontend {
    UhdmSystemVerilogFrontend() : UhdmSurelogAstFrontend("systemverilog", "read SystemVerilog files") {}
    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("    read_systemverilog [options] [filenames]\n");
        log("\n");
        log("Read SystemVerilog files using Surelog into the current design\n");
        log("\n");
        this->print_read_options();
        log("    -Ipath\n");
        log("        add include path.\n");
        log("\n");
        log("    -Pparameter=value\n");
        log("        define parameter as value.\n");
        log("\n");
    }
} UhdmSystemVerilogFrontend;

struct SystemVerilogDefaults : public Pass {
    SystemVerilogDefaults() : Pass("systemverilog_defaults", "set default options for read_systemverilog") {}
    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("    systemverilog_defaults -add [options]\n");
        log("\n");
        log("Add the specified options to the list of default options to read_systemverilog.\n");
        log("\n");
        log("\n");
        log("    systemverilog_defaults -clear\n");
        log("\n");
        log("Clear the list of Systemverilog default options.\n");
        log("\n");
        log("\n");
        log("    systemverilog_defaults -push\n");
        log("    systemverilog_defaults -pop\n");
        log("\n");
        log("Push or pop the list of default options to a stack. Note that -push does\n");
        log("not imply -clear.\n");
        log("\n");
    }
    void execute(std::vector<std::string> args, RTLIL::Design *) override
    {
        if (args.size() < 2)
            cmd_error(args, 1, "Missing argument.");

        if (args[1] == "-add") {
            systemverilog_defaults.insert(systemverilog_defaults.end(), args.begin() + 2, args.end());
            return;
        }

        if (args.size() != 2)
            cmd_error(args, 2, "Extra argument.");

        if (args[1] == "-clear") {
            systemverilog_defaults.clear();
            return;
        }

        if (args[1] == "-push") {
            systemverilog_defaults_stack.push_back(systemverilog_defaults);
            return;
        }

        if (args[1] == "-pop") {
            if (systemverilog_defaults_stack.empty()) {
                systemverilog_defaults.clear();
            } else {
                systemverilog_defaults.swap(systemverilog_defaults_stack.back());
                systemverilog_defaults_stack.pop_back();
            }
            return;
        }
    }
} SystemVerilogDefaults;

struct SystemVerilogDefines : public Pass {
    SystemVerilogDefines() : Pass("systemverilog_defines", "define and undefine systemverilog defines")
    {
        systemverilog_defines.push_back("-DYOSYS=1");
    }
    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("    systemverilog_defines [options]\n");
        log("\n");
        log("Define and undefine systemverilog preprocessor macros.\n");
        log("\n");
        log("    -Dname[=definition]\n");
        log("        define the preprocessor symbol 'name' and set its optional value\n");
        log("        'definition'\n");
        log("\n");
        log("    -Uname[=definition]\n");
        log("        undefine the preprocessor symbol 'name'\n");
        log("\n");
        log("    -reset\n");
        log("        clear list of defined preprocessor symbols\n");
        log("\n");
        log("    -list\n");
        log("        list currently defined preprocessor symbols\n");
        log("\n");
    }
    void remove(const std::string name)
    {
        auto it = systemverilog_defines.begin();
        while (it != systemverilog_defines.end()) {
            std::string nm;
            size_t equal = (*it).find('=', 2);
            if (equal == std::string::npos)
                nm = (*it).substr(2, std::string::npos);
            else
                nm = (*it).substr(2, equal - 2);
            if (name == nm)
                systemverilog_defines.erase(it);
            else
                it++;
        }
    }
    void dump(void)
    {
        for (size_t i = 0; i < systemverilog_defines.size(); ++i) {
            std::string name, value = "";
            size_t equal = systemverilog_defines[i].find('=', 2);
            name = systemverilog_defines[i].substr(2, equal - 2);
            if (equal != std::string::npos)
                value = systemverilog_defines[i].substr(equal + 1, std::string::npos);
            Yosys::log("`define %s %s\n", name.c_str(), value.c_str());
        }
    }
    void execute(std::vector<std::string> args, RTLIL::Design *design) override
    {
        size_t argidx;
        for (argidx = 1; argidx < args.size(); argidx++) {
            std::string arg = args[argidx];
            if (arg == "-D" && argidx + 1 < args.size()) {
                systemverilog_defines.push_back("-D" + args[++argidx]);
                continue;
            }
            if (arg.compare(0, 2, "-D") == 0) {
                systemverilog_defines.push_back(arg);
                continue;
            }
            if (arg == "-U" && argidx + 1 < args.size()) {
                std::string name = args[++argidx];
                this->remove(name);
                continue;
            }
            if (arg.compare(0, 2, "-U") == 0) {
                std::string name = arg.substr(2);
                this->remove(name);
                continue;
            }
            if (arg == "-reset") {
                systemverilog_defines.erase(systemverilog_defines.begin() + 1, systemverilog_defines.end());
                continue;
            }
            if (arg == "-list") {
                this->dump();
                continue;
            }
            break;
        }

        if (args.size() != argidx)
            cmd_error(args, argidx, "Extra argument.");
    }
} SystemVerilogDefines;

} // namespace systemverilog_plugin
