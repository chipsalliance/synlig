#ifndef SYSTEMVERILOG_PLUGIN_CONST2AST_H
#define SYSTEMVERILOG_PLUGIN_CONST2AST_H

#include "frontends/ast/ast.h"
#include <string>

namespace Synlig
{
// this function converts a Verilog constant to an AST_CONSTANT node
Yosys::AST::AstNode *synlig_const2ast(std::string code, char case_type = 0, bool warn_z = false);
} // namespace Synlig

#endif // SYSTEMVERILOG_PLUGIN_CONST2AST_H
