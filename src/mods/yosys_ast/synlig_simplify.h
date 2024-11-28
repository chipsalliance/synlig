#include "frontends/ast/ast.h"

namespace Synlig
{
using ys_size_type = int; // Makes it easy to change if changed upstream.
bool synlig_simplify(Yosys::AST::AstNode *ast_node, bool const_fold, bool at_zero, bool in_lvalue, int stage, int width_hint, bool sign_hint,
                     bool in_param);
void synlig_expand_genblock(Yosys::AST::AstNode *current_node, std::string prefix, bool only_resolve_scope);
} // namespace Synlig
