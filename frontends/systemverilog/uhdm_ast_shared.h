#ifndef _UHDM_AST_SHARED_H_
#define _UHDM_AST_SHARED_H_ 1

#include "frontends/ast/ast.h"

// Yosys defines a 'cover' macro in implicitly included kernel/log.h
// that clashes with cover-class in UHDM
#undef cover

#include <string>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_user.h>
#include <unordered_map>

namespace systemverilog_plugin
{

class UhdmAstShared
{
  private:
    // Used for generating enum names
    unsigned enum_count = 0;

    // Used for generating port IDS
    unsigned port_count = 0;

    // Used for generating loop names
    unsigned loop_count = 0;

    // Used for generating unique names for anonymous types used as parameters.
    unsigned anonymous_type_count = 0;

    // Used to generate unique names for anonymous enum typedefs
    unsigned anonymous_enum_typedef_count = 0;

  public:
    ~UhdmAstShared()
    {
        for (const auto &param : param_types)
            delete param.second;
        param_types.clear();
    }

    // Generate the next enum ID (starting with 0)
    unsigned next_enum_id() { return enum_count++; }

    // Generate the next port ID (starting with 1)
    unsigned next_port_id() { return ++port_count; }

    // Generate the next loop ID (starting with 0)
    unsigned next_loop_id() { return loop_count++; }

    // Generate the next anonymous type ID (starting with 0).
    unsigned next_anonymous_type_id() { return anonymous_type_count++; }

    // Generate the next anonymous enum typedef ID (starting with 0).
    unsigned next_anonymous_enum_typedef_id() { return anonymous_enum_typedef_count++; }

    // Flag that determines whether debug info should be printed
    bool debug_flag = false;

    // Flag that determines whether we should ignore assert() statements
    bool no_assert = false;

    // Flag that determines whether errors should be fatal
    bool stop_on_error = true;

    // Flag that determines whether we should only parse the design
    // applies only to read_systemverilog command
    bool parse_only = false;

    // Flag that determines whether we should defer the elaboration
    // applies only to read_systemverilog command
    bool defer = false;

    // Flag that determines whether we should perform the elaboration now
    // applies only to read_systemverilog command
    bool link = false;

    // Flag equivalent to read_verilog -formal
    // Defines FORMAL, undefines SYNTHESIS
    // Allows verification constructs in Surelog
    bool formal = false;

    // Top nodes of the design (modules, interfaces)
    std::unordered_map<std::string, ::Yosys::AST::AstNode *> top_nodes;

    // Map from AST param nodes to their types (used for params with struct types)
    std::unordered_map<std::string, ::Yosys::AST::AstNode *> param_types;

    ::Yosys::AST::AstNode *current_top_node = nullptr;
    ::Yosys::AST::AstNode *current_design = nullptr;

    // Currently processed UHDM module instance.
    // Used as a fallback when obj->Instance() and obj->vpiParent() are not available.
    const UHDM::any *current_instance = nullptr;

    // Set of non-synthesizable objects to skip in current design;
    std::set<const UHDM::BaseClass *> nonSynthesizableObjects;

    // Map of anonymous enum types to generated typedefs
    std::unordered_map<std::string, std::unordered_map<const UHDM::enum_typespec *, std::string>> anonymous_enums;
};

} // namespace systemverilog_plugin

#endif
