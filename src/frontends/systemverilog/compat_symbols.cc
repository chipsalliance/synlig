// This code is used only when compiling synlig as yosys plugin
// Symbol redefinitions for backwards compatibility.
// This ensures that the plugin can still be loaded with older Yosys even if new extern variables are added to Yosys headers.
#include "kernel/rtlil.h"

YOSYS_NAMESPACE_BEGIN

#define X(_id) RTLIL::IdString RTLIL::ID::_id = "\\" #_id;
#include "kernel/constids.inc"
#undef X

#ifdef __linux__
namespace AST
{
extern void process(Design *, AstNode *, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool,
                    bool, bool, bool);

void __attribute__((weak))
process(RTLIL::Design *design, AST::AstNode *ast, bool dump_ast1, bool dump_ast2, bool no_dump_ptr, bool dump_vlog1, bool dump_vlog2, bool dump_rtlil,
        bool nolatches, bool nomeminit, bool nomem2reg, bool mem2reg, bool noblackbox, bool lib, bool nowb, bool noopt, bool icells, bool pwires,
        bool nooverwrite, bool overwrite, bool defer, bool autowire)
{
    process(design, ast, false, dump_ast1, dump_ast2, no_dump_ptr, dump_vlog1, dump_vlog2, dump_rtlil, nolatches, nomeminit, nomem2reg, mem2reg,
            noblackbox, lib, nowb, noopt, icells, pwires, nooverwrite, overwrite, defer, autowire);
}

} // namespace AST
#endif
YOSYS_NAMESPACE_END
