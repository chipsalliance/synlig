#include "kernel/celltypes.h"
#include "kernel/register.h"
#include "kernel/rtlil.h"
#include "kernel/yosys.h"

#ifndef SYNLIG_SETUP_H
#define SYNLIG_SETUP_H

namespace Synlig
{
void synlig_setup();
bool synlig_already_setup();
}; // namespace Synlig

#endif
