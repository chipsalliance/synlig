// Symbol redefinitions for backwards compatibility.
// This ensures that the plugin can still be loaded with older Yosys even if new extern variables are added to Yosys headers.
#include "kernel/rtlil.h"

YOSYS_NAMESPACE_BEGIN

#define X(_id) RTLIL::IdString RTLIL::ID::_id = "\\" #_id;
#include "kernel/constids.inc"
#undef X

YOSYS_NAMESPACE_END
