#include "setup.h"

namespace Synlig
{
static bool already_setup = false;

std::string find_data_dir()
{
    using namespace Yosys;
    std::string proc_self_path = proc_self_dirname();
    std::string proc_share_path = proc_self_path + "share/";
    if (check_file_exists(proc_share_path, true)) {
        return proc_share_path;
    }
    proc_share_path = proc_self_path + "../share/" + proc_program_prefix() + "synlig/";
    if (check_file_exists(proc_share_path, true)) {
        return proc_share_path;
    }
    proc_share_path = SYNLIG_DATDIR "/";
    if (check_file_exists(proc_share_path, true)) {
        return proc_share_path;
    }
}

void synlig_setup()
{
    if (already_setup)
        return;

    already_setup = true;
    Yosys::yosys_share_dirname = find_data_dir();
    Yosys::yosys_abc_executable = "built in abc";

    {
        using namespace Yosys;
#define X(_id) RTLIL::ID::_id = "\\" #_id;
#include "kernel/constids.inc"
#undef X
        Pass::init_register();
        yosys_design = new RTLIL::Design;
        yosys_celltypes.setup();
        log_push();
    }
}

bool synlig_already_setup() { return already_setup; }
}; // namespace Synlig
