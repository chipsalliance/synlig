#include "kernel/yosys.h"
#include "setup.h"
#include <pybind11/pybind11.h>

namespace py = pybind11;

namespace PySynlig
{
void run_pass(std::string command) { Yosys::run_pass(command); }
}; // namespace PySynlig

PYBIND11_MODULE(libsynlig, m)
{
    m.doc() = "PySynlig - Synlig as Python module";
    m.def("run_pass", &PySynlig::run_pass, "Execute Synlig pass");
    if (!Synlig::synlig_already_setup()) {
        Yosys::log_streams.push_back(&std::cout);
        Yosys::log_error_stderr = true;
        Synlig::synlig_setup();
    }
}
