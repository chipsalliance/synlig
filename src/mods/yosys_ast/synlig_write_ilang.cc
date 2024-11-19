#include "kernel/yosys.h"

namespace Synlig
{

using namespace ::Yosys;
struct WriteIlangAlias : public Pass {
    WriteIlangAlias() : Pass("write_ilang", "alias for write_rtlil pass") {}
    void help() override
    {
        log_warning("write_ilang pass is an alias for write_rtlil pass.\n\n");
        run_pass("help write_rtlil");
    }
    void execute(std::vector<std::string> args, RTLIL::Design *design) override
    {
        log_warning("write_ilang pass is an alias for write_rtlil pass.\n\n");
        std::string cmd = "write_rtlil";
        for (int i = 1; i < args.size(); i++)
            cmd += " " + args[i];
        run_pass(cmd, design);
    }
} WriteIlangAliasPass;

} // namespace Synlig
