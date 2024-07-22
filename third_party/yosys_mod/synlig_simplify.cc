/*
 *  yosys -- Yosys Open SYnthesis Suite
 *
 *  Copyright (C) 2012  Claire Xenia Wolf <claire@yosyshq.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *  ---
 *
 *  This is the AST frontend library.
 *
 *  The AST frontend library is not a frontend on it's own but provides a
 *  generic abstract syntax tree (AST) abstraction for HDL code and can be
 *  used by HDL frontends. See "ast.h" for an overview of the API and the
 *  Verilog frontend for an usage example.
 *
 */

#include "kernel/log.h"
#include "libs/sha1/sha1.h"

#include "synlig_const2ast.h"

#include <math.h>
#include <sstream>
#include <stdarg.h>
#include <stdlib.h>

#include "synlig_simplify.h"

YOSYS_NAMESPACE_BEGIN
namespace VERILOG_FRONTEND
{
extern bool sv_mode;
}
YOSYS_NAMESPACE_END

namespace systemverilog_plugin
{

using namespace ::Yosys;
using namespace ::Yosys::AST_INTERNAL;

void annotateTypedEnums(Yosys::AST::AstNode *ast_node, Yosys::AST::AstNode *template_node)
{
    // check if enum
    if (template_node->attributes.count(ID::enum_type)) {
        // get reference to enum node:
        std::string enum_type = template_node->attributes[ID::enum_type]->str.c_str();
        //			log("enum_type=%s (count=%lu)\n", enum_type.c_str(), current_scope.count(enum_type));
        //			log("current scope:\n");
        //			for (auto &it : current_scope)
        //				log("  %s\n", it.first.c_str());
        log_assert(current_scope.count(enum_type) == 1);
        Yosys::AST::AstNode *enum_node = current_scope.at(enum_type);
        log_assert(enum_node->type == Yosys::AST::AST_ENUM);
        while (simplify(enum_node, true, false, false, 1, -1, false, true)) {
        }
        // get width from 1st enum item:
        log_assert(enum_node->children.size() >= 1);
        Yosys::AST::AstNode *enum_item0 = enum_node->children[0];
        log_assert(enum_item0->type == Yosys::AST::AST_ENUM_ITEM);
        int width;
        if (!enum_item0->range_valid)
            width = 1;
        else if (enum_item0->range_swapped)
            width = enum_item0->range_right - enum_item0->range_left + 1;
        else
            width = enum_item0->range_left - enum_item0->range_right + 1;
        log_assert(width > 0);
        // add declared enum items:
        for (auto enum_item : enum_node->children) {
            log_assert(enum_item->type == Yosys::AST::AST_ENUM_ITEM);
            // get is_signed
            bool is_signed;
            if (enum_item->children.size() == 1) {
                is_signed = false;
            } else if (enum_item->children.size() == 2) {
                log_assert(enum_item->children[1]->type == Yosys::AST::AST_RANGE);
                is_signed = enum_item->children[1]->is_signed;
            } else {
                log_error("enum_item children size==%lu, expected 1 or 2 for %s (%s)\n", enum_item->children.size(), enum_item->str.c_str(),
                          enum_node->str.c_str());
            }
            // start building attribute string
            std::string enum_item_str = "\\enum_value_";
            // get enum item value
            if (enum_item->children[0]->type != Yosys::AST::AST_CONSTANT) {
                log_error("expected const, got %s for %s (%s)\n", type2str(enum_item->children[0]->type).c_str(), enum_item->str.c_str(),
                          enum_node->str.c_str());
            }
            RTLIL::Const val = enum_item->children[0]->bitsAsConst(width, is_signed);
            enum_item_str.append(val.as_string());
            // set attribute for available val to enum item name mappings
            ast_node->attributes[enum_item_str.c_str()] = Yosys::AST::AstNode::mkconst_str(enum_item->str);
        }
    }
}

static bool name_has_dot(const std::string &name, std::string &struct_name)
{
    // check if plausible struct member name \sss.mmm
    std::string::size_type pos;
    if (name.substr(0, 1) == "\\" && (pos = name.find('.', 0)) != std::string::npos) {
        struct_name = name.substr(0, pos);
        return true;
    }
    return false;
}

static Yosys::AST::AstNode *make_range(int left, int right, bool is_signed = false)
{
    // generate a pre-validated range node for a fixed signal range.
    auto range = new Yosys::AST::AstNode(Yosys::AST::AST_RANGE);
    range->range_left = left;
    range->range_right = right;
    range->range_valid = true;
    range->children.push_back(Yosys::AST::AstNode::mkconst_int(left, true));
    range->children.push_back(Yosys::AST::AstNode::mkconst_int(right, true));
    range->is_signed = is_signed;
    return range;
}

static int range_width(Yosys::AST::AstNode *node, Yosys::AST::AstNode *rnode)
{
    log_assert(rnode->type == Yosys::AST::AST_RANGE);
    if (!rnode->range_valid) {
        log_file_error(node->filename, node->location.first_line, "Size must be constant in packed struct/union member %s\n", node->str.c_str());
    }
    // note: range swapping has already been checked for
    return rnode->range_left - rnode->range_right + 1;
}

[[noreturn]] static void struct_array_packing_error(Yosys::AST::AstNode *node)
{
    log_file_error(node->filename, node->location.first_line, "Unpacked array in packed struct/union member %s\n", node->str.c_str());
}

static void save_struct_range_dimensions(Yosys::AST::AstNode *node, Yosys::AST::AstNode *rnode)
{
    node->dimensions.push_back({rnode->range_right, range_width(node, rnode), rnode->range_swapped});
}

static int get_struct_range_offset(Yosys::AST::AstNode *node, int dimension) { return node->dimensions[dimension].range_right; }

static int get_struct_range_width(Yosys::AST::AstNode *node, int dimension) { return node->dimensions[dimension].range_width; }

static int size_packed_struct(Yosys::AST::AstNode *snode, int base_offset)
{
    // Struct members will be laid out in the structure contiguously from left to right.
    // Union members all have zero offset from the start of the union.
    // Determine total packed size and assign offsets.  Store these in the member node.
    bool is_union = (snode->type == Yosys::AST::AST_UNION);
    int offset = 0;
    int packed_width = -1;

    // embedded struct or union with range?
    auto it =
      std::remove_if(snode->children.begin(), snode->children.end(), [](Yosys::AST::AstNode *node) { return node->type == Yosys::AST::AST_RANGE; });
    std::vector<Yosys::AST::AstNode *> ranges(it, snode->children.end());
    snode->children.erase(it, snode->children.end());
    if (!ranges.empty()) {
        if (ranges.size() > 1) {
            log_file_error(ranges[1]->filename, ranges[1]->location.first_line,
                           "Currently support for custom-type with range is limited to single range\n");
        }
        for (auto range : ranges) {
            snode->dimensions.push_back({
                min(range->range_left, range->range_right),
                max(range->range_left, range->range_right) - min(range->range_left, range->range_right) + 1,
                range->range_swapped
            });
        }
    }
    // examine members from last to first
    for (auto it = snode->children.rbegin(); it != snode->children.rend(); ++it) {
        auto node = *it;
        int width;
        if (node->type == Yosys::AST::AST_STRUCT || node->type == Yosys::AST::AST_UNION) {
            // embedded struct or union
            width = size_packed_struct(node, base_offset + offset);
            // set range of struct
            node->range_right = base_offset + offset;
            node->range_left = base_offset + offset + width - 1;
            node->range_valid = true;
        } else {
            log_assert(node->type == Yosys::AST::AST_STRUCT_ITEM);
            if (node->children.size() > 0 && node->children[0]->type == Yosys::AST::AST_RANGE) {
                // member width e.g. bit [7:0] a
                width = range_width(node, node->children[0]);
                if (node->children.size() == 2) {
                    // Unpacked array. Note that this is a Yosys extension; only packed data types
                    // and integer data types are allowed in packed structs / unions in SystemVerilog.
                    if (node->children[1]->type == Yosys::AST::AST_RANGE) {
                        // Unpacked array, e.g. bit [63:0] a [0:3]
                        auto rnode = node->children[1];
                        if (rnode->children.size() == 1) {
                            // C-style array size, e.g. bit [63:0] a [4]
                            node->dimensions.push_back({
                                0,
                                rnode->range_left,
                                true,
                            });
                            width *= rnode->range_left;
                        } else {
                            save_struct_range_dimensions(node, rnode);
                            width *= range_width(node, rnode);
                        }
                        save_struct_range_dimensions(node, node->children[0]);
                    } else {
                        // The Yosys extension for unpacked arrays in packed structs / unions
                        // only supports memories, i.e. e.g. logic [7:0] a [256] - see above.
                        struct_array_packing_error(node);
                    }
                } else {
                    // Vector
                    save_struct_range_dimensions(node, node->children[0]);
                }
                // range nodes are now redundant
                for (Yosys::AST::AstNode *child : node->children)
                    delete child;
                node->children.clear();
            } else if (node->children.size() > 0 && node->children[0]->type == Yosys::AST::AST_MULTIRANGE) {
                // Packed array, e.g. bit [3:0][63:0] a
                if (node->children.size() != 1) {
                    // The Yosys extension for unpacked arrays in packed structs / unions
                    // only supports memories, i.e. e.g. logic [7:0] a [256] - see above.
                    struct_array_packing_error(node);
                }
                width = 1;
                for (auto rnode : node->children[0]->children) {
                    save_struct_range_dimensions(node, rnode);
                    width *= range_width(node, rnode);
                }
                // range nodes are now redundant
                for (Yosys::AST::AstNode *child : node->children)
                    delete child;
                node->children.clear();
            } else if (node->range_left < 0) {
                // 1 bit signal: bit, logic or reg
                width = 1;
            } else {
                // already resolved and compacted
                width = node->range_left - node->range_right + 1;
            }
            if (is_union) {
                node->range_right = base_offset;
                node->range_left = base_offset + width - 1;
            } else {
                node->range_right = base_offset + offset;
                node->range_left = base_offset + offset + width - 1;
            }
            node->range_valid = true;
        }
        if (is_union) {
            // check that all members have the same size
            if (packed_width == -1) {
                // first member
                packed_width = width;
            } else {
                if (packed_width != width) {

                    log_file_error(node->filename, node->location.first_line, "member %s of a packed union has %d bits, expecting %d\n",
                                   node->str.c_str(), width, packed_width);
                }
            }
        } else {
            offset += width;
        }
    }
    return (is_union ? packed_width : offset);
}

Yosys::AST::AstNode *get_struct_member(const Yosys::AST::AstNode *node)
{
    Yosys::AST::AstNode *member_node;
    if (node->attributes.count(ID::wiretype) && (member_node = node->attributes.at(ID::wiretype)) &&
        (member_node->type == Yosys::AST::AST_STRUCT_ITEM || member_node->type == Yosys::AST::AST_STRUCT ||
         member_node->type == Yosys::AST::AST_UNION)) {
        return member_node;
    }
    return NULL;
}

static void add_members_to_scope(Yosys::AST::AstNode *snode, std::string name)
{
    // add all the members in a struct or union to local scope
    // in case later referenced in assignments
    log_assert(snode->type == Yosys::AST::AST_STRUCT || snode->type == Yosys::AST::AST_UNION);
    for (auto *node : snode->children) {
        auto member_name = name + "." + node->str;
        current_scope[member_name] = node;
        if (node->type != Yosys::AST::AST_STRUCT_ITEM) {
            // embedded struct or union
            add_members_to_scope(node, name + "." + node->str);
        }
    }
}

static int get_max_offset(Yosys::AST::AstNode *node)
{
    // get the width from the MS member in the struct
    // as members are laid out from left to right in the packed wire
    log_assert(node->type == Yosys::AST::AST_STRUCT || node->type == Yosys::AST::AST_UNION);
    while (node->type != Yosys::AST::AST_STRUCT_ITEM) {
        node = node->children[0];
    }
    return node->range_left;
}

static Yosys::AST::AstNode *make_packed_struct(Yosys::AST::AstNode *template_node, std::string &name)
{
    // create a wire for the packed struct
    auto wnode = new Yosys::AST::AstNode(Yosys::AST::AST_WIRE);
    wnode->str = name;
    wnode->is_logic = true;
    wnode->range_valid = true;
    wnode->is_signed = template_node->is_signed;
    int offset = get_max_offset(template_node);
    auto range = make_range(offset, 0);
    wnode->children.push_back(range);
    // make sure this node is the one in scope for this name
    current_scope[name] = wnode;
    // add all the struct members to scope under the wire's name
    add_members_to_scope(template_node, name);
    return wnode;
}

// check if a node or its children contains an assignment to the given variable
static bool node_contains_assignment_to(const Yosys::AST::AstNode *node, const Yosys::AST::AstNode *var)
{
    if (node->type == Yosys::AST::AST_ASSIGN_EQ || node->type == Yosys::AST::AST_ASSIGN_LE) {
        // current node is iteslf an assignment
        log_assert(node->children.size() >= 2);
        const Yosys::AST::AstNode *lhs = node->children[0];
        if (lhs->type == Yosys::AST::AST_IDENTIFIER && lhs->str == var->str)
            return false;
    }
    for (const Yosys::AST::AstNode *child : node->children) {
        // if this child shadows the given variable
        if (child != var && child->str == var->str && child->type == Yosys::AST::AST_WIRE)
            break; // skip the remainder of this block/scope
        // depth-first short circuit
        if (!node_contains_assignment_to(child, var))
            return false;
    }
    return true;
}

static std::string prefix_id(const std::string &prefix, const std::string &str)
{
    log_assert(!prefix.empty() && (prefix.front() == '$' || prefix.front() == '\\'));
    log_assert(!str.empty() && (str.front() == '$' || str.front() == '\\'));
    log_assert(prefix.back() == '.');
    if (str.front() == '\\')
        return prefix + str.substr(1);
    return prefix + str;
}

// returns whether an expression contains an unbased unsized literal; does not
// check the literal exists in a self-determined context
static bool contains_unbased_unsized(const Yosys::AST::AstNode *node)
{
    if (node->type == Yosys::AST::AST_CONSTANT)
        return node->is_unsized;
    for (const Yosys::AST::AstNode *child : node->children)
        if (contains_unbased_unsized(child))
            return true;
    return false;
}

// adds a wire to the current module with the given name that matches the
// dimensions of the given wire reference
void add_wire_for_ref(const RTLIL::Wire *ref, const std::string &str)
{
    Yosys::AST::AstNode *left = Yosys::AST::AstNode::mkconst_int(ref->width - 1 + ref->start_offset, true);
    Yosys::AST::AstNode *right = Yosys::AST::AstNode::mkconst_int(ref->start_offset, true);
    if (ref->upto)
        std::swap(left, right);
    Yosys::AST::AstNode *range = new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, left, right);

    Yosys::AST::AstNode *wire = new Yosys::AST::AstNode(Yosys::AST::AST_WIRE, range);
    wire->is_signed = ref->is_signed;
    wire->is_logic = true;
    wire->str = str;

    current_ast_mod->children.push_back(wire);
    current_scope[str] = wire;
}

enum class IdentUsage {
    NotReferenced, // target variable is neither read or written in the block
    Assigned,      // target variable is always assigned before use
    SyncRequired,  // target variable may be used before it has been assigned
};

// determines whether a local variable a block is always assigned before it is
// used, meaning the nosync attribute can automatically be added to that
// variable
static IdentUsage always_asgn_before_use(const Yosys::AST::AstNode *node, const std::string &target)
{
    // This variable has been referenced before it has necessarily been assigned
    // a value in this procedure.
    if (node->type == Yosys::AST::AST_IDENTIFIER && node->str == target)
        return IdentUsage::SyncRequired;

    // For case statements (which are also used for if/else), we check each
    // possible branch. If the variable is assigned in all branches, then it is
    // assigned, and a sync isn't required. If it used before assignment in any
    // branch, then a sync is required.
    if (node->type == Yosys::AST::AST_CASE) {
        bool all_defined = true;
        bool any_used = false;
        bool has_default = false;
        for (const Yosys::AST::AstNode *child : node->children) {
            if (child->type == Yosys::AST::AST_COND && child->children.at(0)->type == Yosys::AST::AST_DEFAULT)
                has_default = true;
            IdentUsage nested = always_asgn_before_use(child, target);
            if (nested != IdentUsage::Assigned && child->type == Yosys::AST::AST_COND)
                all_defined = false;
            if (nested == IdentUsage::SyncRequired)
                any_used = true;
        }
        if (any_used)
            return IdentUsage::SyncRequired;
        else if (all_defined && has_default)
            return IdentUsage::Assigned;
        else
            return IdentUsage::NotReferenced;
    }

    // Check if this is an assignment to the target variable. For simplicity, we
    // don't analyze sub-ranges of the variable.
    if (node->type == Yosys::AST::AST_ASSIGN_EQ) {
        const Yosys::AST::AstNode *ident = node->children.at(0);
        if (ident->type == Yosys::AST::AST_IDENTIFIER && ident->str == target)
            return IdentUsage::Assigned;
    }

    for (const Yosys::AST::AstNode *child : node->children) {
        IdentUsage nested = always_asgn_before_use(child, target);
        if (nested != IdentUsage::NotReferenced)
            return nested;
    }
    return IdentUsage::NotReferenced;
}

static const std::string auto_nosync_prefix = "\\AutoNosync";

// mark a local variable in an always_comb block for automatic nosync
// consideration
static void mark_auto_nosync(Yosys::AST::AstNode *block, const Yosys::AST::AstNode *wire)
{
    log_assert(block->type == Yosys::AST::AST_BLOCK);
    log_assert(wire->type == Yosys::AST::AST_WIRE);
    block->attributes[auto_nosync_prefix + wire->str] = Yosys::AST::AstNode::mkconst_int(1, false);
}

// block names can be prefixed with an explicit scope during elaboration
static bool is_autonamed_block(const std::string &str)
{
    size_t last_dot = str.rfind('.');
    // unprefixed names: autonamed if the first char is a dollar sign
    if (last_dot == std::string::npos)
        return str.at(0) == '$'; // e.g., `$fordecl_block$1`
    // prefixed names: autonamed if the final chunk begins with a dollar sign
    return str.rfind(".$") == last_dot; // e.g., `\foo.bar.$fordecl_block$1`
}

// check a procedural block for auto-nosync markings, remove them, and add
// nosync to local variables as necessary
static void check_auto_nosync(Yosys::AST::AstNode *node)
{
    std::vector<RTLIL::IdString> attrs_to_drop;
    for (const auto &elem : node->attributes) {
        // skip attributes that don't begin with the prefix
        if (elem.first.compare(0, auto_nosync_prefix.size(), auto_nosync_prefix.c_str()))
            continue;

        // delete and remove the attribute once we're done iterating
        attrs_to_drop.push_back(elem.first);

        // find the wire based on the attribute
        std::string wire_name = elem.first.substr(auto_nosync_prefix.size());
        auto it = current_scope.find(wire_name);
        if (it == current_scope.end())
            continue;

        // analyze the usage of the local variable in this block
        IdentUsage ident_usage = always_asgn_before_use(node, wire_name);
        if (ident_usage != IdentUsage::Assigned)
            continue;

        // mark the wire with `nosync`
        Yosys::AST::AstNode *wire = it->second;
        log_assert(wire->type == Yosys::AST::AST_WIRE);
        wire->attributes[ID::nosync] = node->mkconst_int(1, false);
    }

    // remove the attributes we've "consumed"
    for (const RTLIL::IdString &str : attrs_to_drop) {
        auto it = node->attributes.find(str);
        delete it->second;
        node->attributes.erase(it);
    }

    // check local variables in any nested blocks
    for (Yosys::AST::AstNode *child : node->children)
        check_auto_nosync(child);
}

static inline std::string encode_filename(const std::string &filename)
{
    std::stringstream val;
    if (!std::any_of(filename.begin(), filename.end(),
                     [](char c) { return static_cast<unsigned char>(c) < 33 || static_cast<unsigned char>(c) > 126; }))
        return filename;
    for (unsigned char const c : filename) {
        if (c < 33 || c > 126)
            val << stringf("$%02x", c);
        else
            val << c;
    }
    return val.str();
}

// convert the AST into a simpler AST that has all parameters substituted by their
// values, unrolled for-loops, expanded generate blocks, etc. when this function
// is done with an AST it can be converted into RTLIL using genRTLIL().
//
// this function also does all name resolving and sets the id2ast member of all
// nodes that link to a different node using names and lexical scoping.
bool simplify(Yosys::AST::AstNode *ast_node, bool const_fold, bool at_zero, bool in_lvalue, int stage, int width_hint, bool sign_hint, bool in_param)
{
    static int recursion_counter = 0;
    static bool deep_recursion_warning = false;

    if (recursion_counter++ == 1000 && deep_recursion_warning) {
        log_warning(
          "Deep recursion in AST simplifier.\nDoes this design contain overly long or deeply nested expressions, or excessive recursion?\n");
        deep_recursion_warning = false;
    }

    static bool unevaluated_tern_branch = false;

    Yosys::AST::AstNode *newNode = NULL;
    bool did_something = false;

#if 0
	log("-------------\n");
	log("AST simplify[%d] depth %d at %s:%d on %s %p:\n", stage, recursion_counter, filename.c_str(), location.first_line, type2str(type).c_str(), this);
	log("const_fold=%d, at_zero=%d, in_lvalue=%d, stage=%d, width_hint=%d, sign_hint=%d, in_param=%d\n",
			int(const_fold), int(at_zero), int(in_lvalue), int(stage), int(width_hint), int(sign_hint), int(in_param));
	// dumpAst(NULL, "> ");
#endif

    if (stage == 0) {
        log_assert(ast_node->type == Yosys::AST::AST_MODULE || ast_node->type == Yosys::AST::AST_INTERFACE);

        deep_recursion_warning = true;
        while (simplify(ast_node, const_fold, at_zero, in_lvalue, 1, width_hint, sign_hint, in_param)) {
        }

        if (!flag_nomem2reg && !ast_node->get_bool_attribute(ID::nomem2reg)) {
            dict<Yosys::AST::AstNode *, pool<std::string>> mem2reg_places;
            dict<Yosys::AST::AstNode *, uint32_t> mem2reg_candidates, dummy_proc_flags;
            uint32_t flags = flag_mem2reg ? Yosys::AST::AstNode::MEM2REG_FL_ALL : 0;
            ast_node->mem2reg_as_needed_pass1(mem2reg_places, mem2reg_candidates, dummy_proc_flags, flags); // not sure if correct MAND

            pool<Yosys::AST::AstNode *> mem2reg_set;
            for (auto &it : mem2reg_candidates) {
                Yosys::AST::AstNode *mem = it.first;
                uint32_t memflags = it.second;
                bool this_nomeminit = flag_nomeminit;
                log_assert((memflags & ~0x00ffff00) == 0);

                if (mem->get_bool_attribute(ID::nomem2reg))
                    continue;

                if (mem->get_bool_attribute(ID::nomeminit) || ast_node->get_bool_attribute(ID::nomeminit))
                    this_nomeminit = true;

                if (memflags & Yosys::AST::AstNode::MEM2REG_FL_FORCED)
                    goto silent_activate;

                if (memflags & Yosys::AST::AstNode::MEM2REG_FL_EQ2)
                    goto verbose_activate;

                if (memflags & Yosys::AST::AstNode::MEM2REG_FL_SET_ASYNC)
                    goto verbose_activate;

                if ((memflags & Yosys::AST::AstNode::MEM2REG_FL_SET_INIT) && (memflags & Yosys::AST::AstNode::MEM2REG_FL_SET_ELSE) && this_nomeminit)
                    goto verbose_activate;

                if (memflags & Yosys::AST::AstNode::MEM2REG_FL_CMPLX_LHS)
                    goto verbose_activate;

                if ((memflags & Yosys::AST::AstNode::MEM2REG_FL_CONST_LHS) && !(memflags & Yosys::AST::AstNode::MEM2REG_FL_VAR_LHS))
                    goto verbose_activate;

                // log("Note: Not replacing memory %s with list of registers (flags=0x%08lx).\n", mem->str.c_str(), long(memflags));
                continue;

            verbose_activate:
                if (mem2reg_set.count(mem) == 0) {
                    std::string message = stringf("Replacing memory %s with list of registers.", mem->str.c_str());
                    bool first_element = true;
                    for (auto &place : mem2reg_places[it.first]) {
                        message += stringf("%s%s", first_element ? " See " : ", ", place.c_str());
                        first_element = false;
                    }
                    log_warning("%s\n", message.c_str());
                }

            silent_activate:
                // log("Note: Replacing memory %s with list of registers (flags=0x%08lx).\n", mem->str.c_str(), long(memflags));
                mem2reg_set.insert(mem);
            }

            for (auto node : mem2reg_set) {
                int mem_width, mem_size, addr_bits;
                node->meminfo(mem_width, mem_size, addr_bits);

                int data_range_left = node->children[0]->range_left;
                int data_range_right = node->children[0]->range_right;

                if (node->children[0]->range_swapped)
                    std::swap(data_range_left, data_range_right);

                for (int i = 0; i < mem_size; i++) {
                    Yosys::AST::AstNode *reg = new Yosys::AST::AstNode(
                      Yosys::AST::AST_WIRE, new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, node->mkconst_int(data_range_left, true),
                                                                    node->mkconst_int(data_range_right, true)));
                    reg->str = stringf("%s[%d]", node->str.c_str(), i);
                    reg->is_reg = true;
                    reg->is_signed = node->is_signed;
                    for (auto &it : node->attributes)
                        if (it.first != ID::mem2reg)
                            reg->attributes.emplace(it.first, it.second->clone());
                    reg->filename = node->filename;
                    reg->location = node->location;
                    ast_node->children.push_back(reg);
                    while (simplify(reg, true, false, false, 1, -1, false, false)) {
                    } // <- not sure about reg being the first arg here...
                }
            }

            Yosys::AST::AstNode *async_block = NULL;
            while (ast_node->mem2reg_as_needed_pass2(mem2reg_set, ast_node, NULL, async_block)) {
            }

            vector<Yosys::AST::AstNode *> delnodes;
            ast_node->mem2reg_remove(mem2reg_set, delnodes);

            for (auto node : delnodes)
                delete node;
        }

        while (simplify(ast_node, const_fold, at_zero, in_lvalue, 2, width_hint, sign_hint, in_param)) {
        }
        recursion_counter--;
        return false;
    }

    Yosys::AST::current_filename = ast_node->filename;

    // we do not look inside a task or function
    // (but as soon as a task or function is instantiated we process the generated AST as usual)
    if (ast_node->type == Yosys::AST::AST_FUNCTION || ast_node->type == Yosys::AST::AST_TASK) {
        recursion_counter--;
        return false;
    }

    // deactivate all calls to non-synthesis system tasks
    // note that $display, $finish, and $stop are used for synthesis-time DRC so they're not in this list
    if ((ast_node->type == Yosys::AST::AST_FCALL || ast_node->type == Yosys::AST::AST_TCALL) &&
        (ast_node->str == "$strobe" || ast_node->str == "$monitor" || ast_node->str == "$time" || ast_node->str == "$dumpfile" ||
         ast_node->str == "$dumpvars" || ast_node->str == "$dumpon" || ast_node->str == "$dumpoff" || ast_node->str == "$dumpall")) {
        log_file_warning(ast_node->filename, ast_node->location.first_line, "Ignoring call to system %s %s.\n",
                         ast_node->type == Yosys::AST::AST_FCALL ? "function" : "task", ast_node->str.c_str());
        ast_node->delete_children();
        ast_node->str = std::string();
    }

    if ((ast_node->type == Yosys::AST::AST_TCALL) && (ast_node->str == "$display" || ast_node->str == "$write") &&
        (!current_always || current_always->type != Yosys::AST::AST_INITIAL)) {
        log_file_warning(ast_node->filename, ast_node->location.first_line, "System task `%s' outside initial block is unsupported.\n",
                         ast_node->str.c_str());
        ast_node->delete_children();
        ast_node->str = std::string();
    }

    // print messages if this a call to $display() or $write()
    // This code implements only a small subset of Verilog-2005 $display() format specifiers,
    // but should be good enough for most uses
    if ((ast_node->type == Yosys::AST::AST_TCALL) && ((ast_node->str == "$display") || (ast_node->str == "$write"))) {
        if (!current_always) {
            log_file_warning(ast_node->filename, ast_node->location.first_line, "System task `%s' outside initial or always block is unsupported.\n",
                             ast_node->str.c_str());
        } else if (current_always->type == Yosys::AST::AST_INITIAL) {
            int default_base = 10;
            if (ast_node->str.back() == 'b')
                default_base = 2;
            else if (ast_node->str.back() == 'o')
                default_base = 8;
            else if (ast_node->str.back() == 'h')
                default_base = 16;

            // when $display()/$write() functions are used in an initial block, print them during synthesis
            Fmt fmt = ast_node->processFormat(stage, /*sformat_like=*/false, default_base);
            if (ast_node->str.substr(0, 8) == "$display")
                fmt.append_literal("\n");
            log("%s", fmt.render().c_str());
        } else {
            // when $display()/$write() functions are used in an always block, simplify the expressions and
            // convert them to a special cell later in genrtlil
            for (auto node : ast_node->children)
                while (node->simplify(true, stage, -1, false)) {
                }
            return false;
        }
        ast_node->delete_children();
        ast_node->str = std::string();
    }

    // activate const folding if this is anything that must be evaluated statically (ranges, parameters, attributes, etc.)
    if (ast_node->type == Yosys::AST::AST_WIRE || ast_node->type == Yosys::AST::AST_PARAMETER || ast_node->type == Yosys::AST::AST_LOCALPARAM ||
        ast_node->type == Yosys::AST::AST_ENUM_ITEM || ast_node->type == Yosys::AST::AST_DEFPARAM || ast_node->type == Yosys::AST::AST_PARASET ||
        ast_node->type == Yosys::AST::AST_RANGE || ast_node->type == Yosys::AST::AST_PREFIX || ast_node->type == Yosys::AST::AST_TYPEDEF)
        const_fold = true;
    if (ast_node->type == Yosys::AST::AST_IDENTIFIER && current_scope.count(ast_node->str) > 0 &&
        (current_scope[ast_node->str]->type == Yosys::AST::AST_PARAMETER || current_scope[ast_node->str]->type == Yosys::AST::AST_LOCALPARAM ||
         current_scope[ast_node->str]->type == Yosys::AST::AST_ENUM_ITEM))
        const_fold = true;

    // in certain cases a function must be evaluated constant. this is what in_param controls.
    if (ast_node->type == Yosys::AST::AST_PARAMETER || ast_node->type == Yosys::AST::AST_LOCALPARAM || ast_node->type == Yosys::AST::AST_DEFPARAM ||
        ast_node->type == Yosys::AST::AST_PARASET || ast_node->type == Yosys::AST::AST_PREFIX)
        in_param = true;

    std::map<std::string, Yosys::AST::AstNode *> backup_scope;

    // create name resolution entries for all objects with names
    // also merge multiple declarations for the same wire (e.g. "output foobar; reg foobar;")
    if (ast_node->type == Yosys::AST::AST_MODULE || ast_node->type == Yosys::AST::AST_INTERFACE) {
        current_scope.clear();
        std::set<std::string> existing;
        int counter = 0;
        ast_node->label_genblks(existing, counter);
        std::map<std::string, Yosys::AST::AstNode *> this_wire_scope;
        for (size_t i = 0; i < ast_node->children.size(); i++) {
            Yosys::AST::AstNode *node = ast_node->children[i];

            if (node->type == Yosys::AST::AST_WIRE) {
                if (node->children.size() == 1 && node->children[0]->type == Yosys::AST::AST_RANGE) {
                    for (auto c : node->children[0]->children) {
                        if (!c->is_simple_const_expr()) {
                            if (ast_node->attributes.count(ID::dynports))
                                delete ast_node->attributes.at(ID::dynports);
                            node->attributes[ID::dynports] = node->mkconst_int(1, true);
                        }
                    }
                }
                if (this_wire_scope.count(node->str) > 0) {
                    Yosys::AST::AstNode *first_node = this_wire_scope[node->str];
                    if (first_node->is_input && node->is_reg)
                        goto wires_are_incompatible;
                    if (!node->is_input && !node->is_output && node->is_reg && node->children.size() == 0)
                        goto wires_are_compatible;
                    if (first_node->children.size() == 0 && node->children.size() == 1 && node->children[0]->type == Yosys::AST::AST_RANGE) {
                        Yosys::AST::AstNode *r = node->children[0];
                        if (r->range_valid && r->range_left == 0 && r->range_right == 0) {
                            delete r;
                            node->children.pop_back();
                        }
                    }
                    if (first_node->children.size() != node->children.size())
                        goto wires_are_incompatible;
                    for (size_t j = 0; j < node->children.size(); j++) {
                        Yosys::AST::AstNode *n1 = first_node->children[j], *n2 = node->children[j];
                        if (n1->type == Yosys::AST::AST_RANGE && n2->type == Yosys::AST::AST_RANGE && n1->range_valid && n2->range_valid) {
                            if (n1->range_left != n2->range_left)
                                goto wires_are_incompatible;
                            if (n1->range_right != n2->range_right)
                                goto wires_are_incompatible;
                        } else if (*n1 != *n2)
                            goto wires_are_incompatible;
                    }
                    if (first_node->range_left != node->range_left)
                        goto wires_are_incompatible;
                    if (first_node->range_right != node->range_right)
                        goto wires_are_incompatible;
                    if (first_node->port_id == 0 && (node->is_input || node->is_output))
                        goto wires_are_incompatible;
                wires_are_compatible:
                    if (node->is_input)
                        first_node->is_input = true;
                    if (node->is_output)
                        first_node->is_output = true;
                    if (node->is_reg)
                        first_node->is_reg = true;
                    if (node->is_logic)
                        first_node->is_logic = true;
                    if (node->is_signed)
                        first_node->is_signed = true;
                    for (auto &it : node->attributes) {
                        if (first_node->attributes.count(it.first) > 0)
                            delete first_node->attributes[it.first];
                        first_node->attributes[it.first] = it.second->clone();
                    }
                    ast_node->children.erase(ast_node->children.begin() + (i--));
                    did_something = true;
                    delete node;
                    continue;
                wires_are_incompatible:
                    if (stage > 1)
                        log_file_error(ast_node->filename, ast_node->location.first_line, "Incompatible re-declaration of wire %s.\n",
                                       node->str.c_str());
                    continue;
                }
                this_wire_scope[node->str] = node;
            }
            // these nodes appear at the top level in a module and can define names
            if (node->type == Yosys::AST::AST_PARAMETER || node->type == Yosys::AST::AST_LOCALPARAM || node->type == Yosys::AST::AST_WIRE ||
                node->type == Yosys::AST::AST_AUTOWIRE || node->type == Yosys::AST::AST_GENVAR || node->type == Yosys::AST::AST_MEMORY ||
                node->type == Yosys::AST::AST_FUNCTION || node->type == Yosys::AST::AST_TASK || node->type == Yosys::AST::AST_DPI_FUNCTION ||
                node->type == Yosys::AST::AST_CELL || node->type == Yosys::AST::AST_TYPEDEF) {
                backup_scope[node->str] = current_scope[node->str];
                current_scope[node->str] = node;
            }
            if (node->type == Yosys::AST::AST_ENUM) {
                current_scope[node->str] = node;
                for (auto enode : node->children) {
                    log_assert(enode->type == Yosys::AST::AST_ENUM_ITEM);
                    if (current_scope.count(enode->str) == 0)
                        current_scope[enode->str] = enode;
                    else
                        log_file_error(ast_node->filename, ast_node->location.first_line, "enum item %s already exists\n", enode->str.c_str());
                }
            }
        }
        for (size_t i = 0; i < ast_node->children.size(); i++) {
            Yosys::AST::AstNode *node = ast_node->children[i];
            if (node->type == Yosys::AST::AST_PARAMETER || node->type == Yosys::AST::AST_LOCALPARAM || node->type == Yosys::AST::AST_WIRE ||
                node->type == Yosys::AST::AST_AUTOWIRE || node->type == Yosys::AST::AST_MEMORY || node->type == Yosys::AST::AST_TYPEDEF)
                while (simplify(node, true, false, false, 1, -1, false,
                                node->type == Yosys::AST::AST_PARAMETER || node->type == Yosys::AST::AST_LOCALPARAM))
                    did_something = true;
            if (node->type == Yosys::AST::AST_ENUM) {
                for (auto enode : node->children) {
                    log_assert(enode->type == Yosys::AST::AST_ENUM_ITEM);
                    while (simplify(node, true, false, false, 1, -1, false, in_param))
                        did_something = true;
                }
            }
        }

        for (Yosys::AST::AstNode *child : ast_node->children)
            if (child->type == Yosys::AST::AST_ALWAYS && child->attributes.count(ID::always_comb))
                check_auto_nosync(child);
    }

    // create name resolution entries for all objects with names
    if (ast_node->type == Yosys::AST::AST_PACKAGE) {
        // add names to package scope
        for (size_t i = 0; i < ast_node->children.size(); i++) {
            Yosys::AST::AstNode *node = ast_node->children[i];
            // these nodes appear at the top level in a package and can define names
            if (node->type == Yosys::AST::AST_PARAMETER || node->type == Yosys::AST::AST_LOCALPARAM || node->type == Yosys::AST::AST_TYPEDEF ||
                node->type == Yosys::AST::AST_FUNCTION || node->type == Yosys::AST::AST_TASK) {
                current_scope[node->str] = node;
            }
            if (node->type == Yosys::AST::AST_ENUM) {
                current_scope[node->str] = node;
                for (auto enode : node->children) {
                    log_assert(enode->type == Yosys::AST::AST_ENUM_ITEM);
                    if (current_scope.count(enode->str) == 0)
                        current_scope[enode->str] = enode;
                    else
                        log_file_error(ast_node->filename, ast_node->location.first_line, "enum item %s already exists in package\n",
                                       enode->str.c_str());
                }
            }
        }
    }

    auto backup_current_block = current_block;
    auto backup_current_block_child = current_block_child;
    auto backup_current_top_block = current_top_block;
    auto backup_current_always = current_always;
    auto backup_current_always_clocked = current_always_clocked;

    if (ast_node->type == Yosys::AST::AST_ALWAYS || ast_node->type == Yosys::AST::AST_INITIAL) {
        if (current_always != nullptr)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Invalid nesting of always blocks and/or initializations.\n");

        current_always = ast_node;
        current_always_clocked = false;

        if (ast_node->type == Yosys::AST::AST_ALWAYS)
            for (auto child : ast_node->children) {
                if (child->type == Yosys::AST::AST_POSEDGE || child->type == Yosys::AST::AST_NEGEDGE)
                    current_always_clocked = true;
                if (child->type == Yosys::AST::AST_EDGE && GetSize(child->children) == 1 && child->children[0]->type == Yosys::AST::AST_IDENTIFIER &&
                    child->children[0]->str == "\\$global_clock")
                    current_always_clocked = true;
            }
    }

    if (ast_node->type == Yosys::AST::AST_CELL) {
        bool lookup_suggested = false;

        for (Yosys::AST::AstNode *child : ast_node->children) {
            // simplify any parameters to constants
            if (child->type == Yosys::AST::AST_PARASET)
                while (simplify(child, true, false, false, 1, -1, false, true)) {
                }

            // look for patterns which _may_ indicate ambiguity requiring
            // resolution of the underlying module
            if (child->type == Yosys::AST::AST_ARGUMENT) {
                if (child->children.size() != 1)
                    continue;
                const Yosys::AST::AstNode *value = child->children[0];
                if (value->type == Yosys::AST::AST_IDENTIFIER) {
                    const Yosys::AST::AstNode *elem = value->id2ast;
                    if (elem == nullptr) {
                        if (current_scope.count(value->str))
                            elem = current_scope.at(value->str);
                        else
                            continue;
                    }
                    if (elem->type == Yosys::AST::AST_MEMORY)
                        // need to determine is the is a read or wire
                        lookup_suggested = true;
                    else if (elem->type == Yosys::AST::AST_WIRE && elem->is_signed && !value->children.empty())
                        // this may be a fully sliced signed wire which needs
                        // to be indirected to produce an unsigned connection
                        lookup_suggested = true;
                } else if (contains_unbased_unsized(value))
                    // unbased unsized literals extend to width of the context
                    lookup_suggested = true;
            }
        }

        const RTLIL::Module *module = nullptr;
        if (lookup_suggested)
            module = ast_node->lookup_cell_module();
        if (module) {
            size_t port_counter = 0;
            for (Yosys::AST::AstNode *child : ast_node->children) {
                if (child->type != Yosys::AST::AST_ARGUMENT)
                    continue;

                // determine the full name of port this argument is connected to
                RTLIL::IdString port_name;
                if (child->str.size())
                    port_name = child->str;
                else {
                    if (port_counter >= module->ports.size())
                        log_file_error(ast_node->filename, ast_node->location.first_line, "Cell instance has more ports than the module!\n");
                    port_name = module->ports[port_counter++];
                }

                // find the port's wire in the underlying module
                const RTLIL::Wire *ref = module->wire(port_name);
                if (ref == nullptr)
                    log_file_error(ast_node->filename, ast_node->location.first_line,
                                   "Cell instance refers to port %s which does not exist in module %s!.\n", log_id(port_name), log_id(module->name));

                // select the argument, if present
                log_assert(child->children.size() <= 1);
                if (child->children.empty())
                    continue;
                Yosys::AST::AstNode *arg = child->children[0];

                // plain identifiers never need indirection; this also prevents
                // adding infinite levels of indirection
                if (arg->type == Yosys::AST::AST_IDENTIFIER && arg->children.empty())
                    continue;

                // only add indirection for standard inputs or outputs
                if (ref->port_input == ref->port_output)
                    continue;

                did_something = true;

                // create the indirection wire
                std::stringstream sstr;
                sstr << "$indirect$" << ref->name.c_str() << "$" << encode_filename(ast_node->filename) << ":" << ast_node->location.first_line << "$"
                     << (autoidx++);
                std::string tmp_str = sstr.str();
                add_wire_for_ref(ref, tmp_str);

                Yosys::AST::AstNode *asgn = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN);
                current_ast_mod->children.push_back(asgn);

                Yosys::AST::AstNode *ident = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
                ident->str = tmp_str;
                child->children[0] = ident->clone();

                if (ref->port_input && !ref->port_output) {
                    asgn->children.push_back(ident);
                    asgn->children.push_back(arg);
                } else {
                    log_assert(!ref->port_input && ref->port_output);
                    asgn->children.push_back(arg);
                    asgn->children.push_back(ident);
                }
            }
        }
    }

    int backup_width_hint = width_hint;
    bool backup_sign_hint = sign_hint;

    bool detect_width_simple = false;
    bool child_0_is_self_determined = false;
    bool child_1_is_self_determined = false;
    bool child_2_is_self_determined = false;
    bool children_are_self_determined = false;
    bool reset_width_after_children = false;

    switch (ast_node->type) {
    case Yosys::AST::AST_ASSIGN_EQ:
    case Yosys::AST::AST_ASSIGN_LE:
    case Yosys::AST::AST_ASSIGN:
        while (!ast_node->children[0]->basic_prep && simplify(ast_node->children[0], false, false, true, stage, -1, false, in_param) == true)
            did_something = true;
        while (!ast_node->children[1]->basic_prep && simplify(ast_node->children[1], false, false, false, stage, -1, false, in_param) == true)
            did_something = true;
        ast_node->children[0]->detectSignWidth(backup_width_hint, backup_sign_hint);
        ast_node->children[1]->detectSignWidth(width_hint, sign_hint);
        width_hint = max(width_hint, backup_width_hint);
        child_0_is_self_determined = true;
        // test only once, before optimizations and memory mappings but after assignment LHS was mapped to an identifier
        if (ast_node->children[0]->id2ast && !ast_node->children[0]->was_checked) {
            if ((ast_node->type == Yosys::AST::AST_ASSIGN_LE || ast_node->type == Yosys::AST::AST_ASSIGN_EQ) &&
                ast_node->children[0]->id2ast->is_logic)
                ast_node->children[0]->id2ast->is_reg = true; // if logic type is used in a block asignment
            if ((ast_node->type == Yosys::AST::AST_ASSIGN_LE || ast_node->type == Yosys::AST::AST_ASSIGN_EQ) &&
                !ast_node->children[0]->id2ast->is_reg)
                log_warning("wire '%s' is assigned in a block at %s.\n", ast_node->children[0]->str.c_str(), ast_node->loc_string().c_str());
            if (ast_node->type == Yosys::AST::AST_ASSIGN && ast_node->children[0]->id2ast->is_reg) {
                bool is_rand_reg = false;
                if (ast_node->children[1]->type == Yosys::AST::AST_FCALL) {
                    if (ast_node->children[1]->str == "\\$anyconst")
                        is_rand_reg = true;
                    if (ast_node->children[1]->str == "\\$anyseq")
                        is_rand_reg = true;
                    if (ast_node->children[1]->str == "\\$allconst")
                        is_rand_reg = true;
                    if (ast_node->children[1]->str == "\\$allseq")
                        is_rand_reg = true;
                }
                if (!is_rand_reg)
                    log_warning("reg '%s' is assigned in a continuous assignment at %s.\n", ast_node->children[0]->str.c_str(),
                                ast_node->loc_string().c_str());
            }
            ast_node->children[0]->was_checked = true;
        }
        break;

    case Yosys::AST::AST_STRUCT:
    case Yosys::AST::AST_UNION:
        if (!ast_node->basic_prep) {
            for (auto *node : ast_node->children) {
                // resolve any ranges
                while (!node->basic_prep && simplify(node, true, false, false, stage, -1, false, false)) {
                    did_something = true;
                }
            }
            // determine member offsets and widths
            size_packed_struct(ast_node, 0);

            // instance rather than just a type in a typedef or outer struct?
            if (!ast_node->str.empty() && ast_node->str[0] == '\\') {
                // instance so add a wire for the packed structure
                auto wnode = make_packed_struct(ast_node, ast_node->str);
                log_assert(current_ast_mod);
                current_ast_mod->children.push_back(wnode);
            }
            ast_node->basic_prep = true;
        }
        break;

    case Yosys::AST::AST_STRUCT_ITEM:
        break;

    case Yosys::AST::AST_ENUM:
        // log("\nENUM %s: %d child %d\n", ast_node->str.c_str(), ast_node->basic_prep, ast_node->children[0]->basic_prep);
        if (!ast_node->basic_prep) {
            for (auto item_node : ast_node->children) {
                while (!item_node->basic_prep && simplify(item_node, false, false, false, stage, -1, false, in_param))
                    did_something = true;
            }
            // allocate values (called more than once)
            ast_node->allocateDefaultEnumValues();
        }
        break;

    case Yosys::AST::AST_PARAMETER:
    case Yosys::AST::AST_LOCALPARAM:
        // if parameter is implicit type which is the typename of a struct or union,
        // save information about struct in wiretype attribute
        if (ast_node->children[0]->type == Yosys::AST::AST_IDENTIFIER && current_scope.count(ast_node->children[0]->str) > 0) {
            auto item_node = current_scope[ast_node->children[0]->str];
            if (item_node->type == Yosys::AST::AST_STRUCT || item_node->type == Yosys::AST::AST_UNION) {
                ast_node->attributes[ID::wiretype] = item_node->clone();
                size_packed_struct(ast_node->attributes[ID::wiretype], 0);
                add_members_to_scope(ast_node->attributes[ID::wiretype], ast_node->str);
            }
        }
        while (!ast_node->children[0]->basic_prep && simplify(ast_node->children[0], false, false, false, stage, -1, false, true) == true)
            did_something = true;
        ast_node->children[0]->detectSignWidth(width_hint, sign_hint);
        if (ast_node->children.size() > 1 && ast_node->children[1]->type == Yosys::AST::AST_RANGE) {
            while (!ast_node->children[1]->basic_prep && simplify(ast_node->children[1], false, false, false, stage, -1, false, true) == true)
                did_something = true;
            if (!ast_node->children[1]->range_valid)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Non-constant width range on parameter decl.\n");
            width_hint = max(width_hint, ast_node->children[1]->range_left - ast_node->children[1]->range_right + 1);
        }
        break;
    case Yosys::AST::AST_ENUM_ITEM:
        while (!ast_node->children[0]->basic_prep && simplify(ast_node->children[0], false, false, false, stage, -1, false, in_param))
            did_something = true;
        ast_node->children[0]->detectSignWidth(width_hint, sign_hint);
        if (ast_node->children.size() > 1 && ast_node->children[1]->type == Yosys::AST::AST_RANGE) {
            while (!ast_node->children[1]->basic_prep && simplify(ast_node->children[1], false, false, false, stage, -1, false, in_param))
                did_something = true;
            if (!ast_node->children[1]->range_valid)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Non-constant width range on enum item decl.\n");
            width_hint = max(width_hint, ast_node->children[1]->range_left - ast_node->children[1]->range_right + 1);
        }
        break;

    case Yosys::AST::AST_TO_BITS:
    case Yosys::AST::AST_TO_SIGNED:
    case Yosys::AST::AST_TO_UNSIGNED:
    case Yosys::AST::AST_SELFSZ:
    case Yosys::AST::AST_CAST_SIZE:
    case Yosys::AST::AST_CONCAT:
    case Yosys::AST::AST_REPLICATE:
    case Yosys::AST::AST_REDUCE_AND:
    case Yosys::AST::AST_REDUCE_OR:
    case Yosys::AST::AST_REDUCE_XOR:
    case Yosys::AST::AST_REDUCE_XNOR:
    case Yosys::AST::AST_REDUCE_BOOL:
        detect_width_simple = true;
        children_are_self_determined = true;
        break;

    case Yosys::AST::AST_NEG:
    case Yosys::AST::AST_BIT_NOT:
    case Yosys::AST::AST_POS:
    case Yosys::AST::AST_BIT_AND:
    case Yosys::AST::AST_BIT_OR:
    case Yosys::AST::AST_BIT_XOR:
    case Yosys::AST::AST_BIT_XNOR:
    case Yosys::AST::AST_ADD:
    case Yosys::AST::AST_SUB:
    case Yosys::AST::AST_MUL:
    case Yosys::AST::AST_DIV:
    case Yosys::AST::AST_MOD:
        detect_width_simple = true;
        break;

    case Yosys::AST::AST_SHIFT_LEFT:
    case Yosys::AST::AST_SHIFT_RIGHT:
    case Yosys::AST::AST_SHIFT_SLEFT:
    case Yosys::AST::AST_SHIFT_SRIGHT:
    case Yosys::AST::AST_POW:
        detect_width_simple = true;
        child_1_is_self_determined = true;
        break;

    case Yosys::AST::AST_LT:
    case Yosys::AST::AST_LE:
    case Yosys::AST::AST_EQ:
    case Yosys::AST::AST_NE:
    case Yosys::AST::AST_EQX:
    case Yosys::AST::AST_NEX:
    case Yosys::AST::AST_GE:
    case Yosys::AST::AST_GT:
        width_hint = -1;
        sign_hint = true;
        for (auto child : ast_node->children) {
            while (!child->basic_prep && simplify(child, false, false, in_lvalue, stage, -1, false, in_param) == true)
                did_something = true;
            child->detectSignWidthWorker(width_hint, sign_hint);
        }
        reset_width_after_children = true;
        break;

    case Yosys::AST::AST_LOGIC_AND:
    case Yosys::AST::AST_LOGIC_OR:
    case Yosys::AST::AST_LOGIC_NOT:
        detect_width_simple = true;
        children_are_self_determined = true;
        break;

    case Yosys::AST::AST_TERNARY:
        child_0_is_self_determined = true;
        break;

    case Yosys::AST::AST_MEMRD:
        detect_width_simple = true;
        children_are_self_determined = true;
        break;

    case Yosys::AST::AST_FCALL:
    case Yosys::AST::AST_TCALL:
        children_are_self_determined = true;
        break;

    default:
        width_hint = -1;
        sign_hint = false;
    }

    if (detect_width_simple && width_hint < 0) {
        if (ast_node->type == Yosys::AST::AST_REPLICATE)
            while (simplify(ast_node->children[0], true, false, in_lvalue, stage, -1, false, true) == true)
                did_something = true;
        for (auto child : ast_node->children)
            while (!child->basic_prep && simplify(child, false, false, in_lvalue, stage, -1, false, in_param) == true)
                did_something = true;
        ast_node->detectSignWidth(width_hint, sign_hint);
    }

    if (ast_node->type == Yosys::AST::AST_FCALL && ast_node->str == "\\$past")
        ast_node->detectSignWidth(width_hint, sign_hint);

    if (ast_node->type == Yosys::AST::AST_TERNARY) {
        if (width_hint < 0) {
            while (!ast_node->children[0]->basic_prep && simplify(ast_node->children[0], true, false, in_lvalue, stage, -1, false, in_param))
                did_something = true;

            bool backup_unevaluated_tern_branch = unevaluated_tern_branch;
            Yosys::AST::AstNode *chosen = ast_node->get_tern_choice().first;

            unevaluated_tern_branch = backup_unevaluated_tern_branch || chosen == ast_node->children[2];
            while (!ast_node->children[1]->basic_prep && simplify(ast_node->children[1], false, false, in_lvalue, stage, -1, false, in_param))
                did_something = true;

            unevaluated_tern_branch = backup_unevaluated_tern_branch || chosen == ast_node->children[1];
            while (!ast_node->children[2]->basic_prep && simplify(ast_node->children[2], false, false, in_lvalue, stage, -1, false, in_param))
                did_something = true;

            unevaluated_tern_branch = backup_unevaluated_tern_branch;
            ast_node->detectSignWidth(width_hint, sign_hint);
        }
        int width_hint_left, width_hint_right;
        bool sign_hint_left, sign_hint_right;
        bool found_real_left, found_real_right;
        ast_node->children[1]->detectSignWidth(width_hint_left, sign_hint_left, &found_real_left);
        ast_node->children[2]->detectSignWidth(width_hint_right, sign_hint_right, &found_real_right);
        if (found_real_left || found_real_right) {
            child_1_is_self_determined = true;
            child_2_is_self_determined = true;
        }
    }

    if (ast_node->type == Yosys::AST::AST_CONDX && ast_node->children.size() > 0 && ast_node->children.at(0)->type == Yosys::AST::AST_CONSTANT) {
        for (auto &bit : ast_node->children.at(0)->bits)
            if (bit == State::Sz || bit == State::Sx)
                bit = State::Sa;
    }

    if (ast_node->type == Yosys::AST::AST_CONDZ && ast_node->children.size() > 0 && ast_node->children.at(0)->type == Yosys::AST::AST_CONSTANT) {
        for (auto &bit : ast_node->children.at(0)->bits)
            if (bit == State::Sz)
                bit = State::Sa;
    }

    if (const_fold && ast_node->type == Yosys::AST::AST_CASE) {
        ast_node->detectSignWidth(width_hint, sign_hint);
        while (simplify(ast_node->children[0], const_fold, at_zero, in_lvalue, stage, width_hint, sign_hint, in_param)) {
        }
        if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT && ast_node->children[0]->bits_only_01()) {
            ast_node->children[0]->is_signed = sign_hint;
            RTLIL::Const case_expr = ast_node->children[0]->bitsAsConst(width_hint, sign_hint);
            std::vector<Yosys::AST::AstNode *> new_children;
            new_children.push_back(ast_node->children[0]);
            for (int i = 1; i < GetSize(ast_node->children); i++) {
                Yosys::AST::AstNode *child = ast_node->children[i];
                log_assert(child->type == Yosys::AST::AST_COND || child->type == Yosys::AST::AST_CONDX || child->type == Yosys::AST::AST_CONDZ);
                for (auto v : child->children) {
                    if (v->type == Yosys::AST::AST_DEFAULT)
                        goto keep_const_cond;
                    if (v->type == Yosys::AST::AST_BLOCK)
                        continue;
                    while (simplify(v, const_fold, at_zero, in_lvalue, stage, width_hint, sign_hint, in_param)) {
                    }
                    if (v->type == Yosys::AST::AST_CONSTANT && v->bits_only_01()) {
                        RTLIL::Const case_item_expr = v->bitsAsConst(width_hint, sign_hint);
                        RTLIL::Const match = const_eq(case_expr, case_item_expr, sign_hint, sign_hint, 1);
                        log_assert(match.bits.size() == 1);
                        if (match.bits.front() == RTLIL::State::S1) {
                            while (i + 1 < GetSize(ast_node->children))
                                delete ast_node->children[++i];
                            goto keep_const_cond;
                        }
                        continue;
                    }
                    goto keep_const_cond;
                }
                if (0)
                keep_const_cond:
                    new_children.push_back(child);
                else
                    delete child;
            }
            new_children.swap(ast_node->children);
        }
    }

    dict<std::string, pool<int>> backup_memwr_visible;
    dict<std::string, pool<int>> final_memwr_visible;

    if (ast_node->type == Yosys::AST::AST_CASE && stage == 2) {
        backup_memwr_visible = current_memwr_visible;
        final_memwr_visible = current_memwr_visible;
    }

    // simplify all children first
    // (iterate by index as e.g. auto wires can add new children in the process)
    for (size_t i = 0; i < ast_node->children.size(); i++) {
        bool did_something_here = true;
        bool backup_flag_autowire = flag_autowire;
        bool backup_unevaluated_tern_branch = unevaluated_tern_branch;
        if ((ast_node->type == Yosys::AST::AST_GENFOR || ast_node->type == Yosys::AST::AST_FOR) && i >= 3)
            break;
        if ((ast_node->type == Yosys::AST::AST_GENIF || ast_node->type == Yosys::AST::AST_GENCASE) && i >= 1)
            break;
        if (ast_node->type == Yosys::AST::AST_GENBLOCK)
            break;
        if (ast_node->type == Yosys::AST::AST_CELLARRAY && ast_node->children[i]->type == Yosys::AST::AST_CELL)
            continue;
        if (ast_node->type == Yosys::AST::AST_BLOCK && !ast_node->str.empty())
            break;
        if (ast_node->type == Yosys::AST::AST_PREFIX && i >= 1)
            break;
        if (ast_node->type == Yosys::AST::AST_DEFPARAM && i == 0)
            flag_autowire = true;
        if (ast_node->type == Yosys::AST::AST_TERNARY && i > 0 && !unevaluated_tern_branch) {
            Yosys::AST::AstNode *chosen = ast_node->get_tern_choice().first;
            unevaluated_tern_branch = chosen && chosen != ast_node->children[i];
        }
        while (did_something_here && i < ast_node->children.size()) {
            bool const_fold_here = const_fold, in_lvalue_here = in_lvalue;
            int width_hint_here = width_hint;
            bool sign_hint_here = sign_hint;
            bool in_param_here = in_param;
            if (i == 0 && (ast_node->type == Yosys::AST::AST_REPLICATE || ast_node->type == Yosys::AST::AST_WIRE))
                const_fold_here = true, in_param_here = true;
            if (i == 0 && (ast_node->type == Yosys::AST::AST_GENIF || ast_node->type == Yosys::AST::AST_GENCASE))
                in_param_here = true;
            if (i == 1 && (ast_node->type == Yosys::AST::AST_FOR || ast_node->type == Yosys::AST::AST_GENFOR))
                in_param_here = true;
            if (ast_node->type == Yosys::AST::AST_PARAMETER || ast_node->type == Yosys::AST::AST_LOCALPARAM)
                const_fold_here = true;
            if (i == 0 && (ast_node->type == Yosys::AST::AST_ASSIGN || ast_node->type == Yosys::AST::AST_ASSIGN_EQ ||
                           ast_node->type == Yosys::AST::AST_ASSIGN_LE))
                in_lvalue_here = true;
            if (ast_node->type == Yosys::AST::AST_BLOCK) {
                current_block = ast_node;
                current_block_child = ast_node->children[i];
            }
            if ((ast_node->type == Yosys::AST::AST_ALWAYS || ast_node->type == Yosys::AST::AST_INITIAL) &&
                ast_node->children[i]->type == Yosys::AST::AST_BLOCK)
                current_top_block = ast_node->children[i];
            if (i == 0 && child_0_is_self_determined)
                width_hint_here = -1, sign_hint_here = false;
            if (i == 1 && child_1_is_self_determined)
                width_hint_here = -1, sign_hint_here = false;
            if (i == 2 && child_2_is_self_determined)
                width_hint_here = -1, sign_hint_here = false;
            if (children_are_self_determined)
                width_hint_here = -1, sign_hint_here = false;
            did_something_here =
              simplify(ast_node->children[i], const_fold_here, at_zero, in_lvalue_here, stage, width_hint_here, sign_hint_here, in_param_here);
            if (did_something_here)
                did_something = true;
        }
        if (stage == 2 && ast_node->children[i]->type == Yosys::AST::AST_INITIAL && current_ast_mod != ast_node) {
            current_ast_mod->children.push_back(ast_node->children[i]);
            ast_node->children.erase(ast_node->children.begin() + (i--));
            did_something = true;
        }
        flag_autowire = backup_flag_autowire;
        unevaluated_tern_branch = backup_unevaluated_tern_branch;
        if (stage == 2 && ast_node->type == Yosys::AST::AST_CASE) {
            for (auto &x : current_memwr_visible) {
                for (int y : x.second)
                    final_memwr_visible[x.first].insert(y);
            }
            current_memwr_visible = backup_memwr_visible;
        }
    }
    for (auto &attr : ast_node->attributes) {
        while (simplify(attr.second, true, false, false, stage, -1, false, true))
            did_something = true;
    }
    if (ast_node->type == Yosys::AST::AST_CASE && stage == 2) {
        current_memwr_visible = final_memwr_visible;
    }
    if (ast_node->type == Yosys::AST::AST_ALWAYS && stage == 2) {
        current_memwr_visible.clear();
        current_memwr_count.clear();
    }

    if (reset_width_after_children) {
        width_hint = backup_width_hint;
        sign_hint = backup_sign_hint;
        if (width_hint < 0)
            ast_node->detectSignWidth(width_hint, sign_hint);
    }

    current_block = backup_current_block;
    current_block_child = backup_current_block_child;
    current_top_block = backup_current_top_block;
    current_always = backup_current_always;
    current_always_clocked = backup_current_always_clocked;

    for (auto it = backup_scope.begin(); it != backup_scope.end(); it++) {
        if (it->second == NULL)
            current_scope.erase(it->first);
        else
            current_scope[it->first] = it->second;
    }

    Yosys::AST::current_filename = ast_node->filename;

    if (ast_node->type == Yosys::AST::AST_MODULE || ast_node->type == Yosys::AST::AST_INTERFACE)
        current_scope.clear();

    // convert defparam nodes to cell parameters
    if (ast_node->type == Yosys::AST::AST_DEFPARAM && !ast_node->children.empty()) {
        if (ast_node->children[0]->type != Yosys::AST::AST_IDENTIFIER)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Module name in defparam contains non-constant expressions!\n");

        string modname, paramname = ast_node->children[0]->str;

        size_t pos = paramname.rfind('.');

        while (pos != 0 && pos != std::string::npos) {
            modname = paramname.substr(0, pos);

            if (current_scope.count(modname))
                break;

            pos = paramname.rfind('.', pos - 1);
        }

        if (pos == std::string::npos)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Can't find object for defparam `%s`!\n",
                           RTLIL::unescape_id(paramname).c_str());

        paramname = "\\" + paramname.substr(pos + 1);

        if (current_scope.at(modname)->type != Yosys::AST::AST_CELL)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Defparam argument `%s . %s` does not match a cell!\n",
                           RTLIL::unescape_id(modname).c_str(), RTLIL::unescape_id(paramname).c_str());

        Yosys::AST::AstNode *paraset = new Yosys::AST::AstNode(Yosys::AST::AST_PARASET, ast_node->children[1]->clone(),
                                                               GetSize(ast_node->children) > 2 ? ast_node->children[2]->clone() : NULL);
        paraset->str = paramname;

        Yosys::AST::AstNode *cell = current_scope.at(modname);
        cell->children.insert(cell->children.begin() + 1, paraset);
        ast_node->delete_children();
    }

    // resolve typedefs
    if (ast_node->type == Yosys::AST::AST_TYPEDEF) {
        log_assert(ast_node->children.size() == 1);
        auto type_node = ast_node->children[0];
        log_assert(type_node->type == Yosys::AST::AST_WIRE || type_node->type == Yosys::AST::AST_MEMORY ||
                   type_node->type == Yosys::AST::AST_STRUCT || type_node->type == Yosys::AST::AST_UNION);
        while (simplify(type_node, const_fold, at_zero, in_lvalue, stage, width_hint, sign_hint, in_param)) {
            did_something = true;
        }
        log_assert(!type_node->is_custom_type);
    }

    // resolve types of wires
    if (ast_node->type == Yosys::AST::AST_WIRE || ast_node->type == Yosys::AST::AST_MEMORY || ast_node->type == Yosys::AST::AST_STRUCT_ITEM) {
        if (ast_node->is_custom_type) {
            log_assert(ast_node->children.size() >= 1);
            log_assert(ast_node->children[0]->type == Yosys::AST::AST_WIRETYPE);
            auto type_name = ast_node->children[0]->str;
            if (!current_scope.count(type_name)) {
                log_file_error(ast_node->filename, ast_node->location.first_line, "Unknown identifier `%s' used as type name\n", type_name.c_str());
            }
            Yosys::AST::AstNode *resolved_type_node = current_scope.at(type_name);
            if (resolved_type_node->type != Yosys::AST::AST_TYPEDEF)
                log_file_error(ast_node->filename, ast_node->location.first_line, "`%s' does not name a type\n", type_name.c_str());
            log_assert(resolved_type_node->children.size() == 1);
            Yosys::AST::AstNode *template_node = resolved_type_node->children[0];

            // Ensure typedef itself is fully simplified
            while (simplify(template_node, const_fold, at_zero, in_lvalue, stage, width_hint, sign_hint, in_param)) {
            };

            if (template_node->type == Yosys::AST::AST_STRUCT || template_node->type == Yosys::AST::AST_UNION) {
                // replace with wire representing the packed structure
                newNode = make_packed_struct(template_node, ast_node->str);
                newNode->attributes[ID::wiretype] = ast_node->mkconst_str(resolved_type_node->str);
                // add original input/output attribute to resolved wire
                newNode->is_input = ast_node->is_input;
                newNode->is_output = ast_node->is_output;
                current_scope[ast_node->str] = ast_node;
                goto apply_newNode;
            }

            // Remove type reference
            delete ast_node->children[0];
            ast_node->children.erase(ast_node->children.begin());

            if (ast_node->type == Yosys::AST::AST_WIRE)
                ast_node->type = template_node->type;
            ast_node->is_reg = template_node->is_reg;
            ast_node->is_logic = template_node->is_logic;
            ast_node->is_signed = template_node->is_signed;
            ast_node->is_string = template_node->is_string;
            ast_node->is_custom_type = template_node->is_custom_type;

            ast_node->range_valid = template_node->range_valid;
            ast_node->range_swapped = template_node->range_swapped;
            ast_node->range_left = template_node->range_left;
            ast_node->range_right = template_node->range_right;

            ast_node->attributes[ID::wiretype] = ast_node->mkconst_str(resolved_type_node->str);

            // if an enum then add attributes to support simulator tracing
            annotateTypedEnums(ast_node, template_node);

            // Insert clones children from template at beginning
            for (int i = 0; i < GetSize(template_node->children); i++)
                ast_node->children.insert(ast_node->children.begin() + i, template_node->children[i]->clone());

            if (ast_node->type == Yosys::AST::AST_MEMORY && GetSize(ast_node->children) == 1) {
                // Single-bit memories must have [0:0] range
                Yosys::AST::AstNode *rng = make_range(0, 0);
                ast_node->children.insert(ast_node->children.begin(), rng);
            }
            did_something = true;
        }
        log_assert(!ast_node->is_custom_type);
    }

    // resolve types of parameters
    if (ast_node->type == Yosys::AST::AST_LOCALPARAM || ast_node->type == Yosys::AST::AST_PARAMETER) {
        if (ast_node->is_custom_type) {
            log_assert(ast_node->children.size() == 2);
            log_assert(ast_node->children[1]->type == Yosys::AST::AST_WIRETYPE);
            auto type_name = ast_node->children[1]->str;
            if (!current_scope.count(type_name)) {
                log_file_error(ast_node->filename, ast_node->location.first_line, "Unknown identifier `%s' used as type name\n", type_name.c_str());
            }
            Yosys::AST::AstNode *resolved_type_node = current_scope.at(type_name);
            if (resolved_type_node->type != Yosys::AST::AST_TYPEDEF)
                log_file_error(ast_node->filename, ast_node->location.first_line, "`%s' does not name a type\n", type_name.c_str());
            log_assert(resolved_type_node->children.size() == 1);
            Yosys::AST::AstNode *template_node = resolved_type_node->children[0];

            // Ensure typedef itself is fully simplified
            while (simplify(template_node, const_fold, at_zero, in_lvalue, stage, width_hint, sign_hint, in_param)) {
            };

            if (template_node->type == Yosys::AST::AST_STRUCT || template_node->type == Yosys::AST::AST_UNION) {
                // replace with wire representing the packed structure
                newNode = make_packed_struct(template_node, ast_node->str);
                newNode->attributes[ID::wiretype] = ast_node->mkconst_str(resolved_type_node->str);
                newNode->type = ast_node->type;
                current_scope[ast_node->str] = ast_node;
                // copy param value, it needs to be 1st value
                delete ast_node->children[1];
                ast_node->children.pop_back();
                newNode->children.insert(newNode->children.begin(), ast_node->children[0]->clone());
                goto apply_newNode;
            }
            delete ast_node->children[1];
            ast_node->children.pop_back();

            if (template_node->type == Yosys::AST::AST_MEMORY)
                log_file_error(ast_node->filename, ast_node->location.first_line, "unpacked array type `%s' cannot be used for a parameter\n",
                               ast_node->children[1]->str.c_str());
            ast_node->is_signed = template_node->is_signed;
            ast_node->is_string = template_node->is_string;
            ast_node->is_custom_type = template_node->is_custom_type;

            ast_node->range_valid = template_node->range_valid;
            ast_node->range_swapped = template_node->range_swapped;
            ast_node->range_left = template_node->range_left;
            ast_node->range_right = template_node->range_right;
            ast_node->attributes[ID::wiretype] = ast_node->mkconst_str(resolved_type_node->str);
            for (auto template_child : template_node->children)
                ast_node->children.push_back(template_child->clone());
            did_something = true;
        }
        log_assert(!ast_node->is_custom_type);
    }

    // resolve constant prefixes
    if (ast_node->type == Yosys::AST::AST_PREFIX) {
        if (ast_node->children[0]->type != Yosys::AST::AST_CONSTANT) {
            // dumpAst(NULL, ">   ");
            log_file_error(ast_node->filename, ast_node->location.first_line, "Index in generate block prefix syntax is not constant!\n");
        }
        if (ast_node->children[1]->type == Yosys::AST::AST_PREFIX)
            simplify(ast_node->children[1], const_fold, at_zero, in_lvalue, stage, width_hint, sign_hint, in_param);
        log_assert(ast_node->children[1]->type == Yosys::AST::AST_IDENTIFIER);
        newNode = ast_node->children[1]->clone();
        const char *second_part = ast_node->children[1]->str.c_str();
        if (second_part[0] == '\\')
            second_part++;
        newNode->str = stringf("%s[%d].%s", ast_node->str.c_str(), ast_node->children[0]->integer, second_part);
        goto apply_newNode;
    }

    // evaluate TO_BITS nodes
    if (ast_node->type == Yosys::AST::AST_TO_BITS) {
        if (ast_node->children[0]->type != Yosys::AST::AST_CONSTANT)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Left operand of to_bits expression is not constant!\n");
        if (ast_node->children[1]->type != Yosys::AST::AST_CONSTANT)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Right operand of to_bits expression is not constant!\n");
        RTLIL::Const new_value = ast_node->children[1]->bitsAsConst(ast_node->children[0]->bitsAsConst().as_int(), ast_node->children[1]->is_signed);
        newNode = Yosys::AST::AstNode::mkconst_bits(new_value.bits, ast_node->children[1]->is_signed);
        goto apply_newNode;
    }

    // annotate constant ranges
    if (ast_node->type == Yosys::AST::AST_RANGE) {
        bool old_range_valid = ast_node->range_valid;
        ast_node->range_valid = false;
        ast_node->range_swapped = false;
        ast_node->range_left = -1;
        ast_node->range_right = 0;
        log_assert(ast_node->children.size() >= 1);
        if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT) {
            ast_node->range_valid = true;
            ast_node->range_left = ast_node->children[0]->integer;
            if (ast_node->children.size() == 1)
                ast_node->range_right = ast_node->range_left;
        }
        if (ast_node->children.size() >= 2) {
            if (ast_node->children[1]->type == Yosys::AST::AST_CONSTANT)
                ast_node->range_right = ast_node->children[1]->integer;
            else
                ast_node->range_valid = false;
        }
        if (old_range_valid != ast_node->range_valid)
            did_something = true;
        if (ast_node->range_valid && ast_node->range_right > ast_node->range_left) {
            int tmp = ast_node->range_right;
            ast_node->range_right = ast_node->range_left;
            ast_node->range_left = tmp;
            ast_node->range_swapped = true;
        }
    }

    // annotate wires with their ranges
    if (ast_node->type == Yosys::AST::AST_WIRE) {
        if (ast_node->children.size() > 0) {
            if (ast_node->children[0]->range_valid) {
                if (!ast_node->range_valid)
                    did_something = true;
                ast_node->range_valid = true;
                ast_node->range_swapped = ast_node->children[0]->range_swapped;
                ast_node->range_left = ast_node->children[0]->range_left;
                ast_node->range_right = ast_node->children[0]->range_right;
                bool force_upto = false, force_downto = false;
                if (ast_node->attributes.count(ID::force_upto)) {
                    Yosys::AST::AstNode *val = ast_node->attributes[ID::force_upto];
                    if (val->type != Yosys::AST::AST_CONSTANT)
                        log_file_error(ast_node->filename, ast_node->location.first_line, "Attribute `force_upto' with non-constant value!\n");
                    force_upto = val->asAttrConst().as_bool();
                }
                if (ast_node->attributes.count(ID::force_downto)) {
                    Yosys::AST::AstNode *val = ast_node->attributes[ID::force_downto];
                    if (val->type != Yosys::AST::AST_CONSTANT)
                        log_file_error(ast_node->filename, ast_node->location.first_line, "Attribute `force_downto' with non-constant value!\n");
                    force_downto = val->asAttrConst().as_bool();
                }
                if (force_upto && force_downto)
                    log_file_error(ast_node->filename, ast_node->location.first_line,
                                   "Attributes `force_downto' and `force_upto' cannot be both set!\n");
                if ((force_upto && !ast_node->range_swapped) || (force_downto && ast_node->range_swapped)) {
                    std::swap(ast_node->range_left, ast_node->range_right);
                    ast_node->range_swapped = force_upto;
                }
            }
        } else {
            if (!ast_node->range_valid)
                did_something = true;
            ast_node->range_valid = true;
            ast_node->range_swapped = false;
            ast_node->range_left = 0;
            ast_node->range_right = 0;
        }
    }

    // resolve multiranges on memory decl
    if (ast_node->type == Yosys::AST::AST_MEMORY && ast_node->children.size() > 1 && ast_node->children[1]->type == Yosys::AST::AST_MULTIRANGE) {
        int total_size = 1;
        ast_node->dimensions.clear();
        for (auto range : ast_node->children[1]->children) {
            if (!range->range_valid)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Non-constant range on memory decl.\n");
            ast_node->dimensions.push_back({
                min(range->range_left, range->range_right),
                max(range->range_left, range->range_right) - min(range->range_left, range->range_right) + 1,
                range->range_swapped
            });
            total_size *= ast_node->dimensions.back().range_width;
        }
        delete ast_node->children[1];
        ast_node->children[1] =
          new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(0, true), ast_node->mkconst_int(total_size - 1, true));
        did_something = true;
    }

    // resolve multiranges on memory access
    if (ast_node->type == Yosys::AST::AST_IDENTIFIER && ast_node->id2ast && ast_node->id2ast->type == Yosys::AST::AST_MEMORY &&
        ast_node->children.size() > 0 && ast_node->children[0]->type == Yosys::AST::AST_MULTIRANGE) {
        Yosys::AST::AstNode *index_expr = nullptr;

        ast_node->integer = ast_node->children[0]->children.size(); // save original number of dimensions for $size() etc.
        for (int i = 0; i < GetSize(ast_node->id2ast->dimensions); i++) {
            if (GetSize(ast_node->children[0]->children) <= i)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Insufficient number of array indices for %s.\n",
                               log_id(ast_node->str));

            Yosys::AST::AstNode *new_index_expr = ast_node->children[0]->children[i]->children.at(0)->clone();

            if (ast_node->id2ast->dimensions[i].range_right)
                new_index_expr = new Yosys::AST::AstNode(Yosys::AST::AST_SUB, new_index_expr,
                                                         ast_node->mkconst_int(ast_node->id2ast->dimensions[i].range_right, true));

            if (i == 0)
                index_expr = new_index_expr;
            else
                index_expr =
                  new Yosys::AST::AstNode(Yosys::AST::AST_ADD,
                                          new Yosys::AST::AstNode(Yosys::AST::AST_MUL, index_expr,
                                                                  ast_node->mkconst_int(ast_node->id2ast->dimensions[i].range_width, true)),
                                          new_index_expr);
        }

        for (int i = GetSize(ast_node->id2ast->dimensions); i < GetSize(ast_node->children[0]->children); i++)
            ast_node->children.push_back(ast_node->children[0]->children[i]->clone());

        delete ast_node->children[0];
        if (index_expr == nullptr)
            ast_node->children.erase(ast_node->children.begin());
        else
            ast_node->children[0] = new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, index_expr);

        did_something = true;
    }

    // trim/extend parameters
    if (ast_node->type == Yosys::AST::AST_PARAMETER || ast_node->type == Yosys::AST::AST_LOCALPARAM || ast_node->type == Yosys::AST::AST_ENUM_ITEM) {
        if (ast_node->children.size() > 1 && ast_node->children[1]->type == Yosys::AST::AST_RANGE) {
            if (!ast_node->children[1]->range_valid)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Non-constant width range on parameter decl.\n");
            int width = std::abs(ast_node->children[1]->range_left - ast_node->children[1]->range_right) + 1;
            if (ast_node->children[0]->type == Yosys::AST::AST_REALVALUE) {
                RTLIL::Const constvalue = ast_node->children[0]->realAsConst(width);
                log_file_warning(ast_node->filename, ast_node->location.first_line, "converting real value %e to binary %s.\n",
                                 ast_node->children[0]->realvalue, log_signal(constvalue));
                delete ast_node->children[0];
                ast_node->children[0] = Yosys::AST::AstNode::mkconst_bits(constvalue.bits, sign_hint);
                did_something = true;
            }
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT) {
                if (width != int(ast_node->children[0]->bits.size())) {
                    RTLIL::SigSpec sig(ast_node->children[0]->bits);
                    sig.extend_u0(width, ast_node->children[0]->is_signed);
                    Yosys::AST::AstNode *old_child_0 = ast_node->children[0];
                    ast_node->children[0] = Yosys::AST::AstNode::mkconst_bits(sig.as_const().bits, ast_node->is_signed);
                    delete old_child_0;
                }
                ast_node->children[0]->is_signed = ast_node->is_signed;
            }
            ast_node->range_valid = true;
            ast_node->range_swapped = ast_node->children[1]->range_swapped;
            ast_node->range_left = ast_node->children[1]->range_left;
            ast_node->range_right = ast_node->children[1]->range_right;
        } else if (ast_node->children.size() > 1 && ast_node->children[1]->type == Yosys::AST::AST_REALVALUE &&
                   ast_node->children[0]->type == Yosys::AST::AST_CONSTANT) {
            double as_realvalue = ast_node->children[0]->asReal(sign_hint);
            delete ast_node->children[0];
            ast_node->children[0] = new Yosys::AST::AstNode(Yosys::AST::AST_REALVALUE);
            ast_node->children[0]->realvalue = as_realvalue;
            did_something = true;
        }
    }

    if (ast_node->type == Yosys::AST::AST_IDENTIFIER && !ast_node->basic_prep) {
        // check if a plausible struct member sss.mmmm
        std::string sname;
        if (name_has_dot(ast_node->str, sname)) {
            if (current_scope.count(ast_node->str) > 0) {
                auto item_node = current_scope[ast_node->str];
                if (item_node->type == Yosys::AST::AST_STRUCT_ITEM || item_node->type == Yosys::AST::AST_STRUCT ||
                    item_node->type == Yosys::AST::AST_UNION) {
                    // structure member, rewrite ast_node node to reference the packed struct wire
                    auto range = ast_node->make_index_range(item_node);
                    newNode = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER, range);
                    newNode->str = sname;
                    // save type and original number of dimensions for $size() etc.
                    newNode->attributes[ID::wiretype] = item_node->clone();
                    if (!item_node->dimensions.empty() && ast_node->children.size() > 0) {
                        if (ast_node->children[0]->type == Yosys::AST::AST_RANGE)
                            newNode->integer = 1;
                        else if (ast_node->children[0]->type == Yosys::AST::AST_MULTIRANGE)
                            newNode->integer = ast_node->children[0]->children.size();
                    }
                    newNode->basic_prep = true;
                    if (item_node->is_signed)
                        newNode = new Yosys::AST::AstNode(Yosys::AST::AST_TO_SIGNED, newNode);
                    goto apply_newNode;
                }
            }
        }
    }
    // annotate identifiers using scope resolution and create auto-wires as needed
    if (ast_node->type == Yosys::AST::AST_IDENTIFIER) {
        if (current_scope.count(ast_node->str) == 0) {
            Yosys::AST::AstNode *current_scope_ast = (current_ast_mod == nullptr) ? current_ast : current_ast_mod;
            ast_node->str = ast_node->try_pop_module_prefix();
            for (auto node : current_scope_ast->children) {
                // log("looking at mod scope child %s\n", type2str(node->type).c_str());
                switch (node->type) {
                case Yosys::AST::AST_PARAMETER:
                case Yosys::AST::AST_LOCALPARAM:
                case Yosys::AST::AST_WIRE:
                case Yosys::AST::AST_AUTOWIRE:
                case Yosys::AST::AST_GENVAR:
                case Yosys::AST::AST_MEMORY:
                case Yosys::AST::AST_FUNCTION:
                case Yosys::AST::AST_TASK:
                case Yosys::AST::AST_DPI_FUNCTION:
                    // log("found child %s, %s\n", type2str(node->type).c_str(), node->str.c_str());
                    if (ast_node->str == node->str) {
                        // log("add %s, type %s to scope\n", ast_node->str.c_str(), type2str(node->type).c_str());
                        current_scope[node->str] = node;
                    }
                    break;
                case Yosys::AST::AST_ENUM:
                    current_scope[node->str] = node;
                    for (auto enum_node : node->children) {
                        log_assert(enum_node->type == Yosys::AST::AST_ENUM_ITEM);
                        if (ast_node->str == enum_node->str) {
                            // log("\nadding enum item %s to scope\n", ast_node->str.c_str());
                            current_scope[ast_node->str] = enum_node;
                        }
                    }
                    break;
                default:
                    break;
                }
            }
        }
        if (current_scope.count(ast_node->str) == 0) {
            if (current_ast_mod == nullptr) {
                log_file_error(ast_node->filename, ast_node->location.first_line, "Identifier `%s' is implicitly declared outside of a module.\n",
                               ast_node->str.c_str());
            } else if (flag_autowire || ast_node->str == "\\$global_clock") {
                Yosys::AST::AstNode *auto_wire = new Yosys::AST::AstNode(Yosys::AST::AST_AUTOWIRE);
                auto_wire->str = ast_node->str;
                current_ast_mod->children.push_back(auto_wire);
                current_scope[ast_node->str] = auto_wire;
                did_something = true;
            } else {
                log_file_error(ast_node->filename, ast_node->location.first_line,
                               "Identifier `%s' is implicitly declared and `default_nettype is set to none.\n", ast_node->str.c_str());
            }
        }
        if (ast_node->id2ast != current_scope[ast_node->str]) {
            ast_node->id2ast = current_scope[ast_node->str];
            did_something = true;
        }
    }

    // split memory access with bit select to individual statements
    if (ast_node->type == Yosys::AST::AST_IDENTIFIER && ast_node->children.size() == 2 && ast_node->children[0]->type == Yosys::AST::AST_RANGE &&
        ast_node->children[1]->type == Yosys::AST::AST_RANGE && !in_lvalue && stage == 2) {
        if (ast_node->id2ast == NULL || ast_node->id2ast->type != Yosys::AST::AST_MEMORY || ast_node->children[0]->children.size() != 1)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Invalid bit-select on memory access!\n");

        int mem_width, mem_size, addr_bits;
        ast_node->id2ast->meminfo(mem_width, mem_size, addr_bits);

        int data_range_left = ast_node->id2ast->children[0]->range_left;
        int data_range_right = ast_node->id2ast->children[0]->range_right;

        if (ast_node->id2ast->children[0]->range_swapped)
            std::swap(data_range_left, data_range_right);

        std::stringstream sstr;
        sstr << "$mem2bits$" << ast_node->str << "$" << encode_filename(ast_node->filename) << ":" << ast_node->location.first_line << "$"
             << (autoidx++);
        std::string wire_id = sstr.str();

        Yosys::AST::AstNode *wire =
          new Yosys::AST::AstNode(Yosys::AST::AST_WIRE, new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(data_range_left, true),
                                                                                ast_node->mkconst_int(data_range_right, true)));
        wire->str = wire_id;
        if (current_block)
            wire->attributes[ID::nosync] = ast_node->mkconst_int(1, false);
        current_ast_mod->children.push_back(wire);
        while (simplify(wire, true, false, false, 1, -1, false, false)) {
        }

        Yosys::AST::AstNode *data = ast_node->clone();
        delete data->children[1];
        data->children.pop_back();

        Yosys::AST::AstNode *assign = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER), data);
        assign->children[0]->str = wire_id;
        assign->children[0]->was_checked = true;

        if (current_block) {
            size_t assign_idx = 0;
            while (assign_idx < current_block->children.size() && current_block->children[assign_idx] != current_block_child)
                assign_idx++;
            log_assert(assign_idx < current_block->children.size());
            current_block->children.insert(current_block->children.begin() + assign_idx, assign);
            wire->is_reg = true;
        } else {
            Yosys::AST::AstNode *proc = new Yosys::AST::AstNode(Yosys::AST::AST_ALWAYS, new Yosys::AST::AstNode(Yosys::AST::AST_BLOCK));
            proc->children[0]->children.push_back(assign);
            current_ast_mod->children.push_back(proc);
        }

        newNode = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER, ast_node->children[1]->clone());
        newNode->str = wire_id;
        newNode->integer = ast_node->integer; // save original number of dimensions for $size() etc.
        newNode->id2ast = wire;
        goto apply_newNode;
    }

    if (ast_node->type == Yosys::AST::AST_WHILE)
        log_file_error(ast_node->filename, ast_node->location.first_line, "While loops are only allowed in constant functions!\n");

    if (ast_node->type == Yosys::AST::AST_REPEAT) {
        Yosys::AST::AstNode *count = ast_node->children[0];
        Yosys::AST::AstNode *body = ast_node->children[1];

        // eval count expression
        while (simplify(count, true, false, false, stage, 32, true, false)) {
        }

        if (count->type != Yosys::AST::AST_CONSTANT)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Repeat loops outside must have constant repeat counts!\n");

        // convert to a block with the body repeated n times
        ast_node->type = Yosys::AST::AST_BLOCK;
        ast_node->children.clear();
        for (int i = 0; i < count->bitsAsConst().as_int(); i++)
            ast_node->children.insert(ast_node->children.begin(), body->clone());

        delete count;
        delete body;
        did_something = true;
    }

    // unroll for loops and generate-for blocks
    if ((ast_node->type == Yosys::AST::AST_GENFOR || ast_node->type == Yosys::AST::AST_FOR) && ast_node->children.size() != 0) {
        Yosys::AST::AstNode *init_ast = ast_node->children[0];
        Yosys::AST::AstNode *while_ast = ast_node->children[1];
        Yosys::AST::AstNode *next_ast = ast_node->children[2];
        Yosys::AST::AstNode *body_ast = ast_node->children[3];

        while (body_ast->type == Yosys::AST::AST_GENBLOCK && body_ast->str.empty() && body_ast->children.size() == 1 &&
               body_ast->children.at(0)->type == Yosys::AST::AST_GENBLOCK)
            body_ast = body_ast->children.at(0);

        const char *loop_type_str = "procedural";
        const char *var_type_str = "register";
        Yosys::AST::AstNodeType var_type = Yosys::AST::AST_WIRE;
        if (ast_node->type == Yosys::AST::AST_GENFOR) {
            loop_type_str = "generate";
            var_type_str = "genvar";
            var_type = Yosys::AST::AST_GENVAR;
        }

        if (init_ast->type != Yosys::AST::AST_ASSIGN_EQ)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Unsupported 1st expression of %s for-loop!\n", loop_type_str);
        if (next_ast->type != Yosys::AST::AST_ASSIGN_EQ)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Unsupported 3rd expression of %s for-loop!\n", loop_type_str);

        if (init_ast->children[0]->id2ast == NULL || init_ast->children[0]->id2ast->type != var_type)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Left hand side of 1st expression of %s for-loop is not a %s!\n",
                           loop_type_str, var_type_str);
        if (next_ast->children[0]->id2ast == NULL || next_ast->children[0]->id2ast->type != var_type)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Left hand side of 3rd expression of %s for-loop is not a %s!\n",
                           loop_type_str, var_type_str);

        if (init_ast->children[0]->id2ast != next_ast->children[0]->id2ast)
            log_file_error(ast_node->filename, ast_node->location.first_line,
                           "Incompatible left-hand sides in 1st and 3rd expression of %s for-loop!\n", loop_type_str);

        // eval 1st expression
        Yosys::AST::AstNode *varbuf = init_ast->children[1]->clone();
        {
            int expr_width_hint = -1;
            bool expr_sign_hint = true;
            varbuf->detectSignWidth(expr_width_hint, expr_sign_hint);
            while (simplify(varbuf, true, false, false, stage, 32, true, false)) {
            }
        }

        if (varbuf->type != Yosys::AST::AST_CONSTANT)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Right hand side of 1st expression of %s for-loop is not constant!\n",
                           loop_type_str);

        auto resolved = current_scope.at(init_ast->children[0]->str);
        if (resolved->range_valid) {
            int const_size = varbuf->range_left - varbuf->range_right;
            int resolved_size = resolved->range_left - resolved->range_right;
            if (const_size < resolved_size) {
                for (int i = const_size; i < resolved_size; i++)
                    varbuf->bits.push_back(resolved->is_signed ? varbuf->bits.back() : State::S0);
                varbuf->range_left = resolved->range_left;
                varbuf->range_right = resolved->range_right;
                varbuf->range_swapped = resolved->range_swapped;
                varbuf->range_valid = resolved->range_valid;
            }
        }

        varbuf = new Yosys::AST::AstNode(Yosys::AST::AST_LOCALPARAM, varbuf);
        varbuf->str = init_ast->children[0]->str;

        Yosys::AST::AstNode *backup_scope_varbuf = current_scope[varbuf->str];
        current_scope[varbuf->str] = varbuf;

        size_t current_block_idx = 0;
        if (ast_node->type == Yosys::AST::AST_FOR) {
            while (current_block_idx < current_block->children.size() && current_block->children[current_block_idx] != current_block_child)
                current_block_idx++;
        }

        while (1) {
            // eval 2nd expression
            Yosys::AST::AstNode *buf = while_ast->clone();
            {
                int expr_width_hint = -1;
                bool expr_sign_hint = true;
                buf->detectSignWidth(expr_width_hint, expr_sign_hint);
                while (simplify(buf, true, false, false, stage, expr_width_hint, expr_sign_hint, false)) {
                }
            }

            if (buf->type != Yosys::AST::AST_CONSTANT)
                log_file_error(ast_node->filename, ast_node->location.first_line, "2nd expression of %s for-loop is not constant!\n", loop_type_str);

            if (buf->integer == 0) {
                delete buf;
                break;
            }
            delete buf;

            // expand body
            int index = varbuf->children[0]->integer;
            log_assert(body_ast->type == Yosys::AST::AST_GENBLOCK || body_ast->type == Yosys::AST::AST_BLOCK);
            log_assert(!body_ast->str.empty());
            buf = body_ast->clone();

            std::stringstream sstr;
            sstr << buf->str << "[" << index << "].";
            std::string prefix = sstr.str();

            // create a scoped localparam for the current value of the loop variable
            Yosys::AST::AstNode *local_index = varbuf->clone();
            size_t pos = local_index->str.rfind('.');
            if (pos != std::string::npos) // remove outer prefix
                local_index->str = "\\" + local_index->str.substr(pos + 1);
            local_index->str = prefix_id(prefix, local_index->str);
            current_scope[local_index->str] = local_index;
            current_ast_mod->children.push_back(local_index);

            buf->expand_genblock(prefix);

            if (ast_node->type == Yosys::AST::AST_GENFOR) {
                for (size_t i = 0; i < buf->children.size(); i++) {
                    simplify(buf->children[i], const_fold, false, false, stage, -1, false, false);
                    current_ast_mod->children.push_back(buf->children[i]);
                }
            } else {
                for (size_t i = 0; i < buf->children.size(); i++)
                    current_block->children.insert(current_block->children.begin() + current_block_idx++, buf->children[i]);
            }
            buf->children.clear();
            delete buf;

            // eval 3rd expression
            buf = next_ast->children[1]->clone();
            {
                int expr_width_hint = -1;
                bool expr_sign_hint = true;
                buf->detectSignWidth(expr_width_hint, expr_sign_hint);
                while (simplify(buf, true, false, false, stage, expr_width_hint, expr_sign_hint, true)) {
                }
            }

            if (buf->type != Yosys::AST::AST_CONSTANT)
                log_file_error(ast_node->filename, ast_node->location.first_line,
                               "Right hand side of 3rd expression of %s for-loop is not constant (%s)!\n", loop_type_str,
                               type2str(buf->type).c_str());

            delete varbuf->children[0];
            varbuf->children[0] = buf;
        }

        if (ast_node->type == Yosys::AST::AST_FOR) {
            Yosys::AST::AstNode *buf = next_ast->clone();
            delete buf->children[1];
            buf->children[1] = varbuf->children[0]->clone();
            current_block->children.insert(current_block->children.begin() + current_block_idx++, buf);
        }

        current_scope[varbuf->str] = backup_scope_varbuf;
        delete varbuf;
        ast_node->delete_children();
        did_something = true;
    }

    // check for local objects in unnamed block
    if (ast_node->type == Yosys::AST::AST_BLOCK && ast_node->str.empty()) {
        for (size_t i = 0; i < ast_node->children.size(); i++)
            if (ast_node->children[i]->type == Yosys::AST::AST_WIRE || ast_node->children[i]->type == Yosys::AST::AST_MEMORY ||
                ast_node->children[i]->type == Yosys::AST::AST_PARAMETER || ast_node->children[i]->type == Yosys::AST::AST_LOCALPARAM ||
                ast_node->children[i]->type == Yosys::AST::AST_TYPEDEF) {
                log_assert(!VERILOG_FRONTEND::sv_mode);
                log_file_error(ast_node->children[i]->filename, ast_node->children[i]->location.first_line,
                               "Local declaration in unnamed block is only supported in SystemVerilog mode!\n");
            }
    }

    // transform block with name
    if (ast_node->type == Yosys::AST::AST_BLOCK && !ast_node->str.empty()) {
        ast_node->expand_genblock(ast_node->str + ".");

        // if ast_node is an autonamed block is in an always_comb
        if (current_always && current_always->attributes.count(ID::always_comb) && is_autonamed_block(ast_node->str))
            // track local variables in ast_node block so we can consider adding
            // nosync once the block has been fully elaborated
            for (Yosys::AST::AstNode *child : ast_node->children)
                if (child->type == Yosys::AST::AST_WIRE && !child->attributes.count(ID::nosync))
                    mark_auto_nosync(ast_node, child);

        std::vector<Yosys::AST::AstNode *> new_children;
        for (size_t i = 0; i < ast_node->children.size(); i++)
            if (ast_node->children[i]->type == Yosys::AST::AST_WIRE || ast_node->children[i]->type == Yosys::AST::AST_MEMORY ||
                ast_node->children[i]->type == Yosys::AST::AST_PARAMETER || ast_node->children[i]->type == Yosys::AST::AST_LOCALPARAM ||
                ast_node->children[i]->type == Yosys::AST::AST_TYPEDEF) {
                simplify(ast_node->children[i], false, false, false, stage, -1, false, false);
                current_ast_mod->children.push_back(ast_node->children[i]);
                current_scope[ast_node->children[i]->str] = ast_node->children[i];
            } else
                new_children.push_back(ast_node->children[i]);

        ast_node->children.swap(new_children);
        did_something = true;
        ast_node->str.clear();
    }

    // simplify unconditional generate block
    if (ast_node->type == Yosys::AST::AST_GENBLOCK && ast_node->children.size() != 0) {
        if (!ast_node->str.empty()) {
            ast_node->expand_genblock(ast_node->str + ".");
        }

        for (size_t i = 0; i < ast_node->children.size(); i++) {
            simplify(ast_node->children[i], const_fold, false, false, stage, -1, false, false);
            current_ast_mod->children.push_back(ast_node->children[i]);
        }

        ast_node->children.clear();
        did_something = true;
    }

    // simplify generate-if blocks
    if (ast_node->type == Yosys::AST::AST_GENIF && ast_node->children.size() != 0) {
        Yosys::AST::AstNode *buf = ast_node->children[0]->clone();
        while (simplify(buf, true, false, false, stage, width_hint, sign_hint, false)) {
        }
        if (buf->type != Yosys::AST::AST_CONSTANT) {
            // for (auto f : log_files)
            // 	dumpAst(f, "verilog-ast> ");
            log_file_error(ast_node->filename, ast_node->location.first_line, "Condition for generate if is not constant!\n");
        }
        if (buf->asBool() != 0) {
            delete buf;
            buf = ast_node->children[1]->clone();
        } else {
            delete buf;
            buf = ast_node->children.size() > 2 ? ast_node->children[2]->clone() : NULL;
        }

        if (buf) {
            if (buf->type != Yosys::AST::AST_GENBLOCK)
                buf = new Yosys::AST::AstNode(Yosys::AST::AST_GENBLOCK, buf);

            if (!buf->str.empty()) {
                buf->expand_genblock(buf->str + ".");
            }

            for (size_t i = 0; i < buf->children.size(); i++) {
                simplify(buf->children[i], const_fold, false, false, stage, -1, false, false);
                current_ast_mod->children.push_back(buf->children[i]);
            }

            buf->children.clear();
            delete buf;
        }

        ast_node->delete_children();
        did_something = true;
    }

    // simplify generate-case blocks
    if (ast_node->type == Yosys::AST::AST_GENCASE && ast_node->children.size() != 0) {
        Yosys::AST::AstNode *buf = ast_node->children[0]->clone();
        while (simplify(buf, true, false, false, stage, width_hint, sign_hint, false)) {
        }
        if (buf->type != Yosys::AST::AST_CONSTANT) {
            // for (auto f : log_files)
            // 	dumpAst(f, "verilog-ast> ");
            log_file_error(ast_node->filename, ast_node->location.first_line, "Condition for generate case is not constant!\n");
        }

        bool ref_signed = buf->is_signed;
        RTLIL::Const ref_value = buf->bitsAsConst();
        delete buf;

        Yosys::AST::AstNode *selected_case = NULL;
        for (size_t i = 1; i < ast_node->children.size(); i++) {
            log_assert(ast_node->children.at(i)->type == Yosys::AST::AST_COND || ast_node->children.at(i)->type == Yosys::AST::AST_CONDX ||
                       ast_node->children.at(i)->type == Yosys::AST::AST_CONDZ);

            Yosys::AST::AstNode *this_genblock = NULL;
            for (auto child : ast_node->children.at(i)->children) {
                log_assert(this_genblock == NULL);
                if (child->type == Yosys::AST::AST_GENBLOCK)
                    this_genblock = child;
            }

            for (auto child : ast_node->children.at(i)->children) {
                if (child->type == Yosys::AST::AST_DEFAULT) {
                    if (selected_case == NULL)
                        selected_case = this_genblock;
                    continue;
                }
                if (child->type == Yosys::AST::AST_GENBLOCK)
                    continue;

                buf = child->clone();
                while (simplify(buf, true, false, false, stage, width_hint, sign_hint, true)) {
                }
                if (buf->type != Yosys::AST::AST_CONSTANT) {
                    // for (auto f : log_files)
                    // 	dumpAst(f, "verilog-ast> ");
                    log_file_error(ast_node->filename, ast_node->location.first_line, "Expression in generate case is not constant!\n");
                }

                bool is_selected =
                  RTLIL::const_eq(ref_value, buf->bitsAsConst(), ref_signed && buf->is_signed, ref_signed && buf->is_signed, 1).as_bool();
                delete buf;

                if (is_selected) {
                    selected_case = this_genblock;
                    i = ast_node->children.size();
                    break;
                }
            }
        }

        if (selected_case != NULL) {
            log_assert(selected_case->type == Yosys::AST::AST_GENBLOCK);
            buf = selected_case->clone();

            if (!buf->str.empty()) {
                buf->expand_genblock(buf->str + ".");
            }

            for (size_t i = 0; i < buf->children.size(); i++) {
                simplify(buf->children[i], const_fold, false, false, stage, -1, false, false);
                current_ast_mod->children.push_back(buf->children[i]);
            }

            buf->children.clear();
            delete buf;
        }

        ast_node->delete_children();
        did_something = true;
    }

    // unroll cell arrays
    if (ast_node->type == Yosys::AST::AST_CELLARRAY) {
        if (!ast_node->children.at(0)->range_valid)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Non-constant array range on cell array.\n");

        newNode = new Yosys::AST::AstNode(Yosys::AST::AST_GENBLOCK);
        int num = max(ast_node->children.at(0)->range_left, ast_node->children.at(0)->range_right) -
                  min(ast_node->children.at(0)->range_left, ast_node->children.at(0)->range_right) + 1;

        for (int i = 0; i < num; i++) {
            int idx = ast_node->children.at(0)->range_left > ast_node->children.at(0)->range_right ? ast_node->children.at(0)->range_right + i
                                                                                                   : ast_node->children.at(0)->range_right - i;
            Yosys::AST::AstNode *new_cell = ast_node->children.at(1)->clone();
            newNode->children.push_back(new_cell);
            new_cell->str += stringf("[%d]", idx);
            if (new_cell->type == Yosys::AST::AST_PRIMITIVE) {
                log_file_error(ast_node->filename, ast_node->location.first_line, "Cell arrays of primitives are currently not supported.\n");
            } else {
                log_assert(new_cell->children.at(0)->type == Yosys::AST::AST_CELLTYPE);
                new_cell->children.at(0)->str = stringf("$array:%d:%d:%s", i, num, new_cell->children.at(0)->str.c_str());
            }
        }

        goto apply_newNode;
    }

    // replace primitives with assignments
    if (ast_node->type == Yosys::AST::AST_PRIMITIVE) {
        if (ast_node->children.size() < 2)
            log_file_error(ast_node->filename, ast_node->location.first_line, "Insufficient number of arguments for primitive `%s'!\n",
                           ast_node->str.c_str());

        std::vector<Yosys::AST::AstNode *> children_list;
        for (auto child : ast_node->children) {
            log_assert(child->type == Yosys::AST::AST_ARGUMENT);
            log_assert(child->children.size() == 1);
            children_list.push_back(child->children[0]);
            child->children.clear();
            delete child;
        }
        ast_node->children.clear();

        if (ast_node->str == "bufif0" || ast_node->str == "bufif1" || ast_node->str == "notif0" || ast_node->str == "notif1") {
            if (children_list.size() != 3)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Invalid number of arguments for primitive `%s'!\n",
                               ast_node->str.c_str());

            std::vector<RTLIL::State> z_const(1, RTLIL::State::Sz);

            Yosys::AST::AstNode *mux_input = children_list.at(1);
            if (ast_node->str == "notif0" || ast_node->str == "notif1") {
                mux_input = new Yosys::AST::AstNode(Yosys::AST::AST_BIT_NOT, mux_input);
            }
            Yosys::AST::AstNode *node = new Yosys::AST::AstNode(Yosys::AST::AST_TERNARY, children_list.at(2));
            if (ast_node->str == "bufif0") {
                node->children.push_back(Yosys::AST::AstNode::mkconst_bits(z_const, false));
                node->children.push_back(mux_input);
            } else {
                node->children.push_back(mux_input);
                node->children.push_back(Yosys::AST::AstNode::mkconst_bits(z_const, false));
            }

            ast_node->str.clear();
            ast_node->type = Yosys::AST::AST_ASSIGN;
            ast_node->children.push_back(children_list.at(0));
            ast_node->children.back()->was_checked = true;
            ast_node->children.push_back(node);
            did_something = true;
        } else if (ast_node->str == "buf" || ast_node->str == "not") {
            Yosys::AST::AstNode *input = children_list.back();
            if (ast_node->str == "not")
                input = new Yosys::AST::AstNode(Yosys::AST::AST_BIT_NOT, input);

            newNode = new Yosys::AST::AstNode(Yosys::AST::AST_GENBLOCK);
            for (auto it = children_list.begin(); it != std::prev(children_list.end()); it++) {
                newNode->children.push_back(new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN, *it, input->clone()));
                newNode->children.back()->was_checked = true;
            }
            delete input;

            did_something = true;
        } else {
            Yosys::AST::AstNodeType op_type = Yosys::AST::AST_NONE;
            bool invert_results = false;

            if (ast_node->str == "and")
                op_type = Yosys::AST::AST_BIT_AND;
            if (ast_node->str == "nand")
                op_type = Yosys::AST::AST_BIT_AND, invert_results = true;
            if (ast_node->str == "or")
                op_type = Yosys::AST::AST_BIT_OR;
            if (ast_node->str == "nor")
                op_type = Yosys::AST::AST_BIT_OR, invert_results = true;
            if (ast_node->str == "xor")
                op_type = Yosys::AST::AST_BIT_XOR;
            if (ast_node->str == "xnor")
                op_type = Yosys::AST::AST_BIT_XOR, invert_results = true;
            log_assert(op_type != Yosys::AST::AST_NONE);

            Yosys::AST::AstNode *node = children_list[1];
            if (op_type != Yosys::AST::AST_POS)
                for (size_t i = 2; i < children_list.size(); i++) {
                    node = new Yosys::AST::AstNode(op_type, node, children_list[i]);
                    node->location = ast_node->location;
                }
            if (invert_results)
                node = new Yosys::AST::AstNode(Yosys::AST::AST_BIT_NOT, node);

            ast_node->str.clear();
            ast_node->type = Yosys::AST::AST_ASSIGN;
            ast_node->children.push_back(children_list[0]);
            ast_node->children.back()->was_checked = true;
            ast_node->children.push_back(node);
            did_something = true;
        }
    }

    // replace dynamic ranges in left-hand side expressions (e.g. "foo[bar] <= 1'b1;") with
    // either a big case block that selects the correct single-bit assignment, or mask and
    // shift operations.
    if (ast_node->type == Yosys::AST::AST_ASSIGN_EQ || ast_node->type == Yosys::AST::AST_ASSIGN_LE) {
        if (ast_node->children[0]->type != Yosys::AST::AST_IDENTIFIER || ast_node->children[0]->children.size() == 0)
            goto skip_dynamic_range_lvalue_expansion;
        if (ast_node->children[0]->children[0]->range_valid || did_something)
            goto skip_dynamic_range_lvalue_expansion;
        if (ast_node->children[0]->id2ast == NULL || ast_node->children[0]->id2ast->type != Yosys::AST::AST_WIRE)
            goto skip_dynamic_range_lvalue_expansion;
        if (!ast_node->children[0]->id2ast->range_valid)
            goto skip_dynamic_range_lvalue_expansion;

        int source_width = ast_node->children[0]->id2ast->range_left - ast_node->children[0]->id2ast->range_right + 1;
        int source_offset = ast_node->children[0]->id2ast->range_right;
        int result_width = 1;
        Yosys::AST::AstNode *member_node = systemverilog_plugin::get_struct_member(ast_node->children[0]);
        if (member_node) {
            // Clamp chunk to range of member within struct/union.
            log_assert(!source_offset && !ast_node->children[0]->id2ast->range_swapped);
            source_width = member_node->range_left - member_node->range_right + 1;
        }

        Yosys::AST::AstNode *shift_expr = NULL;
        Yosys::AST::AstNode *range = ast_node->children[0]->children[0];

        if (range->children.size() == 1) {
            shift_expr = range->children[0]->clone();
        } else {
            shift_expr = range->children[1]->clone();
            Yosys::AST::AstNode *left_at_zero_ast = range->children[0]->clone();
            Yosys::AST::AstNode *right_at_zero_ast = range->children[1]->clone();
            while (simplify(left_at_zero_ast, true, true, false, stage, -1, false, false)) {
            }
            while (simplify(right_at_zero_ast, true, true, false, stage, -1, false, false)) {
            }
            if (left_at_zero_ast->type != Yosys::AST::AST_CONSTANT || right_at_zero_ast->type != Yosys::AST::AST_CONSTANT)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Unsupported expression on dynamic range select on signal `%s'!\n",
                               ast_node->str.c_str());
            result_width = abs(int(left_at_zero_ast->integer - right_at_zero_ast->integer)) + 1;
            delete left_at_zero_ast;
            delete right_at_zero_ast;
        }

        bool use_case_method = false;

        if (ast_node->children[0]->id2ast->attributes.count(ID::nowrshmsk)) {
            Yosys::AST::AstNode *node = ast_node->children[0]->id2ast->attributes.at(ID::nowrshmsk);
            while (simplify(node, true, false, false, stage, -1, false, false)) {
            }
            if (node->type != Yosys::AST::AST_CONSTANT)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Non-constant value for `nowrshmsk' attribute on `%s'!\n",
                               ast_node->children[0]->id2ast->str.c_str());
            if (node->asAttrConst().as_bool())
                use_case_method = true;
        }

        if (!use_case_method && current_always->detect_latch(ast_node->children[0]->str))
            use_case_method = true;

        if (use_case_method) {
            // big case block

            did_something = true;
            newNode = new Yosys::AST::AstNode(Yosys::AST::AST_CASE, shift_expr);
            for (int i = 0; i < source_width; i++) {
                int start_bit = source_offset + i;
                int end_bit = std::min(start_bit + result_width, source_width) - 1;
                Yosys::AST::AstNode *cond = new Yosys::AST::AstNode(Yosys::AST::AST_COND, ast_node->mkconst_int(start_bit, true));
                Yosys::AST::AstNode *lvalue = ast_node->children[0]->clone();
                lvalue->delete_children();
                if (member_node)
                    lvalue->attributes[ID::wiretype] = member_node->clone();
                lvalue->children.push_back(
                  new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(end_bit, true), ast_node->mkconst_int(start_bit, true)));
                cond->children.push_back(
                  new Yosys::AST::AstNode(Yosys::AST::AST_BLOCK, new Yosys::AST::AstNode(ast_node->type, lvalue, ast_node->children[1]->clone())));
                newNode->children.push_back(cond);
            }
        } else {
            // mask and shift operations, disabled for now

            Yosys::AST::AstNode *wire_mask = new Yosys::AST::AstNode(
              Yosys::AST::AST_WIRE,
              new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(source_width - 1, true), ast_node->mkconst_int(0, true)));
            wire_mask->str =
              stringf("$bitselwrite$mask$%s:%d$%d", encode_filename(ast_node->filename).c_str(), ast_node->location.first_line, autoidx++);
            wire_mask->attributes[ID::nosync] = ast_node->mkconst_int(1, false);
            wire_mask->is_logic = true;
            while (simplify(wire_mask, true, false, false, 1, -1, false, false)) {
            }
            current_ast_mod->children.push_back(wire_mask);

            Yosys::AST::AstNode *wire_data = new Yosys::AST::AstNode(
              Yosys::AST::AST_WIRE,
              new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(source_width - 1, true), ast_node->mkconst_int(0, true)));
            wire_data->str =
              stringf("$bitselwrite$data$%s:%d$%d", encode_filename(ast_node->filename).c_str(), ast_node->location.first_line, autoidx++);
            wire_data->attributes[ID::nosync] = ast_node->mkconst_int(1, false);
            wire_data->is_logic = true;
            while (simplify(wire_data, true, false, false, 1, -1, false, false)) {
            }
            current_ast_mod->children.push_back(wire_data);

            int shamt_width_hint = -1;
            bool shamt_sign_hint = true;
            shift_expr->detectSignWidth(shamt_width_hint, shamt_sign_hint);

            Yosys::AST::AstNode *wire_sel = new Yosys::AST::AstNode(
              Yosys::AST::AST_WIRE,
              new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(shamt_width_hint - 1, true), ast_node->mkconst_int(0, true)));
            wire_sel->str =
              stringf("$bitselwrite$sel$%s:%d$%d", encode_filename(ast_node->filename).c_str(), ast_node->location.first_line, autoidx++);
            wire_sel->attributes[ID::nosync] = ast_node->mkconst_int(1, false);
            wire_sel->is_logic = true;
            wire_sel->is_signed = shamt_sign_hint;
            while (simplify(wire_sel, true, false, false, 1, -1, false, false)) {
            }
            current_ast_mod->children.push_back(wire_sel);

            did_something = true;
            newNode = new Yosys::AST::AstNode(Yosys::AST::AST_BLOCK);

            Yosys::AST::AstNode *lvalue = ast_node->children[0]->clone();
            lvalue->delete_children();
            if (member_node)
                lvalue->attributes[ID::wiretype] = member_node->clone();

            Yosys::AST::AstNode *ref_mask = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
            ref_mask->str = wire_mask->str;
            ref_mask->id2ast = wire_mask;
            ref_mask->was_checked = true;

            Yosys::AST::AstNode *ref_data = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
            ref_data->str = wire_data->str;
            ref_data->id2ast = wire_data;
            ref_data->was_checked = true;

            Yosys::AST::AstNode *ref_sel = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
            ref_sel->str = wire_sel->str;
            ref_sel->id2ast = wire_sel;
            ref_sel->was_checked = true;

            Yosys::AST::AstNode *old_data = lvalue->clone();
            if (ast_node->type == Yosys::AST::AST_ASSIGN_LE)
                old_data->lookahead = true;

            Yosys::AST::AstNode *s = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, ref_sel->clone(), shift_expr);
            newNode->children.push_back(s);

            Yosys::AST::AstNode *shamt = ref_sel;

            // convert to signed while preserving the sign and value
            shamt = new Yosys::AST::AstNode(Yosys::AST::AST_CAST_SIZE, ast_node->mkconst_int(shamt_width_hint + 1, true), shamt);
            shamt = new Yosys::AST::AstNode(Yosys::AST::AST_TO_SIGNED, shamt);

            // offset the shift amount by the lower bound of the dimension
            int start_bit = source_offset;
            shamt = new Yosys::AST::AstNode(Yosys::AST::AST_SUB, shamt, ast_node->mkconst_int(start_bit, true));

            // reflect the shift amount if the dimension is swapped
            if (ast_node->children[0]->id2ast->range_swapped)
                shamt = new Yosys::AST::AstNode(Yosys::AST::AST_SUB, ast_node->mkconst_int(source_width - result_width, true), shamt);

            // AST_SHIFT uses negative amounts for shifting left
            shamt = new Yosys::AST::AstNode(Yosys::AST::AST_NEG, shamt);

            Yosys::AST::AstNode *t;

            t = Yosys::AST::AstNode::mkconst_bits(std::vector<RTLIL::State>(result_width, State::S1), false);
            t = new Yosys::AST::AstNode(Yosys::AST::AST_SHIFT, t, shamt->clone());
            t = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, ref_mask->clone(), t);
            newNode->children.push_back(t);

            t = new Yosys::AST::AstNode(Yosys::AST::AST_BIT_AND,
                                        Yosys::AST::AstNode::mkconst_bits(std::vector<RTLIL::State>(result_width, State::S1), false),
                                        ast_node->children[1]->clone());
            t = new Yosys::AST::AstNode(Yosys::AST::AST_SHIFT, t, shamt);
            t = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, ref_data->clone(), t);
            newNode->children.push_back(t);

            t = new Yosys::AST::AstNode(Yosys::AST::AST_BIT_AND, old_data, new Yosys::AST::AstNode(Yosys::AST::AST_BIT_NOT, ref_mask));
            t = new Yosys::AST::AstNode(Yosys::AST::AST_BIT_OR, t, ref_data);
            t = new Yosys::AST::AstNode(ast_node->type, lvalue, t);
            newNode->children.push_back(t);
        }

        goto apply_newNode;
    }
skip_dynamic_range_lvalue_expansion:;

    if (stage > 1 &&
        (ast_node->type == Yosys::AST::AST_ASSERT || ast_node->type == Yosys::AST::AST_ASSUME || ast_node->type == Yosys::AST::AST_LIVE ||
         ast_node->type == Yosys::AST::AST_FAIR || ast_node->type == Yosys::AST::AST_COVER) &&
        current_block != NULL) {
        std::stringstream sstr;
        sstr << "$formal$" << encode_filename(ast_node->filename) << ":" << ast_node->location.first_line << "$" << (autoidx++);
        std::string id_check = sstr.str() + "_CHECK", id_en = sstr.str() + "_EN";

        Yosys::AST::AstNode *wire_check = new Yosys::AST::AstNode(Yosys::AST::AST_WIRE);
        wire_check->str = id_check;
        wire_check->was_checked = true;
        current_ast_mod->children.push_back(wire_check);
        current_scope[wire_check->str] = wire_check;
        while (simplify(wire_check, true, false, false, 1, -1, false, false)) {
        }

        Yosys::AST::AstNode *wire_en = new Yosys::AST::AstNode(Yosys::AST::AST_WIRE);
        wire_en->str = id_en;
        wire_en->was_checked = true;
        current_ast_mod->children.push_back(wire_en);
        if (current_always_clocked) {
            current_ast_mod->children.push_back(new Yosys::AST::AstNode(
              Yosys::AST::AST_INITIAL,
              new Yosys::AST::AstNode(Yosys::AST::AST_BLOCK,
                                      new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_LE, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                              ast_node->mkconst_int(0, false, 1)))));
            current_ast_mod->children.back()->children[0]->children[0]->children[0]->str = id_en;
            current_ast_mod->children.back()->children[0]->children[0]->children[0]->was_checked = true;
        }
        current_scope[wire_en->str] = wire_en;
        while (simplify(wire_en, true, false, false, 1, -1, false, false)) {
        }

        Yosys::AST::AstNode *check_defval;
        if (ast_node->type == Yosys::AST::AST_LIVE || ast_node->type == Yosys::AST::AST_FAIR) {
            check_defval = new Yosys::AST::AstNode(Yosys::AST::AST_REDUCE_BOOL, ast_node->children[0]->clone());
        } else {
            std::vector<RTLIL::State> x_bit;
            x_bit.push_back(RTLIL::State::Sx);
            check_defval = Yosys::AST::AstNode::mkconst_bits(x_bit, false);
        }

        Yosys::AST::AstNode *assign_check =
          new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_LE, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER), check_defval);
        assign_check->children[0]->str = id_check;
        assign_check->children[0]->was_checked = true;

        Yosys::AST::AstNode *assign_en =
          new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_LE, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER), ast_node->mkconst_int(0, false, 1));
        assign_en->children[0]->str = id_en;
        assign_en->children[0]->was_checked = true;

        Yosys::AST::AstNode *default_signals = new Yosys::AST::AstNode(Yosys::AST::AST_BLOCK);
        default_signals->children.push_back(assign_check);
        default_signals->children.push_back(assign_en);
        current_top_block->children.insert(current_top_block->children.begin(), default_signals);

        if (ast_node->type == Yosys::AST::AST_LIVE || ast_node->type == Yosys::AST::AST_FAIR) {
            assign_check = nullptr;
        } else {
            assign_check = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_LE, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                   new Yosys::AST::AstNode(Yosys::AST::AST_REDUCE_BOOL, ast_node->children[0]->clone()));
            assign_check->children[0]->str = id_check;
            assign_check->children[0]->was_checked = true;
        }

        if (current_always == nullptr || current_always->type != Yosys::AST::AST_INITIAL) {
            assign_en = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_LE, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                ast_node->mkconst_int(1, false, 1));
        } else {
            assign_en = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_LE, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                new Yosys::AST::AstNode(Yosys::AST::AST_FCALL));
            assign_en->children[1]->str = "\\$initstate";
        }
        assign_en->children[0]->str = id_en;
        assign_en->children[0]->was_checked = true;

        newNode = new Yosys::AST::AstNode(Yosys::AST::AST_BLOCK);
        if (assign_check != nullptr)
            newNode->children.push_back(assign_check);
        newNode->children.push_back(assign_en);

        Yosys::AST::AstNode *assertnode = new Yosys::AST::AstNode(ast_node->type);
        assertnode->location = ast_node->location;
        assertnode->str = ast_node->str;
        assertnode->children.push_back(new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER));
        assertnode->children.push_back(new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER));
        assertnode->children[0]->str = id_check;
        assertnode->children[1]->str = id_en;
        assertnode->attributes.swap(ast_node->attributes);
        current_ast_mod->children.push_back(assertnode);

        goto apply_newNode;
    }

    if (stage > 1 &&
        (ast_node->type == Yosys::AST::AST_ASSERT || ast_node->type == Yosys::AST::AST_ASSUME || ast_node->type == Yosys::AST::AST_LIVE ||
         ast_node->type == Yosys::AST::AST_FAIR || ast_node->type == Yosys::AST::AST_COVER) &&
        ast_node->children.size() == 1) {
        ast_node->children.push_back(ast_node->mkconst_int(1, false, 1));
        did_something = true;
    }

    // found right-hand side identifier for memory -> replace with memory read port
    if (stage > 1 && ast_node->type == Yosys::AST::AST_IDENTIFIER && ast_node->id2ast != NULL && ast_node->id2ast->type == Yosys::AST::AST_MEMORY &&
        !in_lvalue && ast_node->children.size() == 1 && ast_node->children[0]->type == Yosys::AST::AST_RANGE &&
        ast_node->children[0]->children.size() == 1) {
        newNode = new Yosys::AST::AstNode(Yosys::AST::AST_MEMRD, ast_node->children[0]->children[0]->clone());
        newNode->str = ast_node->str;
        newNode->id2ast = ast_node->id2ast;
        goto apply_newNode;
    }

    // assignment with nontrivial member in left-hand concat expression -> split assignment
    if ((ast_node->type == Yosys::AST::AST_ASSIGN_EQ || ast_node->type == Yosys::AST::AST_ASSIGN_LE) &&
        ast_node->children[0]->type == Yosys::AST::AST_CONCAT && width_hint > 0) {
        bool found_nontrivial_member = false;

        for (auto child : ast_node->children[0]->children) {
            if (child->type == Yosys::AST::AST_IDENTIFIER && child->id2ast != NULL && child->id2ast->type == Yosys::AST::AST_MEMORY)
                found_nontrivial_member = true;
        }

        if (found_nontrivial_member) {
            newNode = new Yosys::AST::AstNode(Yosys::AST::AST_BLOCK);

            Yosys::AST::AstNode *wire_tmp = new Yosys::AST::AstNode(
              Yosys::AST::AST_WIRE,
              new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(width_hint - 1, true), ast_node->mkconst_int(0, true)));
            wire_tmp->str =
              stringf("$splitcmplxassign$%s:%d$%d", encode_filename(ast_node->filename).c_str(), ast_node->location.first_line, autoidx++);
            current_ast_mod->children.push_back(wire_tmp);
            current_scope[wire_tmp->str] = wire_tmp;
            wire_tmp->attributes[ID::nosync] = ast_node->mkconst_int(1, false);
            while (simplify(wire_tmp, true, false, false, 1, -1, false, false)) {
            }
            wire_tmp->is_logic = true;

            Yosys::AST::AstNode *wire_tmp_id = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
            wire_tmp_id->str = wire_tmp->str;

            newNode->children.push_back(new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, wire_tmp_id, ast_node->children[1]->clone()));
            newNode->children.back()->was_checked = true;

            int cursor = 0;
            for (auto child : ast_node->children[0]->children) {
                int child_width_hint = -1;
                bool child_sign_hint = true;
                child->detectSignWidth(child_width_hint, child_sign_hint);

                Yosys::AST::AstNode *rhs = wire_tmp_id->clone();
                rhs->children.push_back(new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(cursor + child_width_hint - 1, true),
                                                                ast_node->mkconst_int(cursor, true)));
                newNode->children.push_back(new Yosys::AST::AstNode(ast_node->type, child->clone(), rhs));

                cursor += child_width_hint;
            }

            goto apply_newNode;
        }
    }

    // assignment with memory in left-hand side expression -> replace with memory write port
    if (stage > 1 && (ast_node->type == Yosys::AST::AST_ASSIGN_EQ || ast_node->type == Yosys::AST::AST_ASSIGN_LE) &&
        ast_node->children[0]->type == Yosys::AST::AST_IDENTIFIER && ast_node->children[0]->id2ast &&
        ast_node->children[0]->id2ast->type == Yosys::AST::AST_MEMORY && ast_node->children[0]->id2ast->children.size() >= 2 &&
        ast_node->children[0]->id2ast->children[0]->range_valid && ast_node->children[0]->id2ast->children[1]->range_valid &&
        (ast_node->children[0]->children.size() == 1 || ast_node->children[0]->children.size() == 2) &&
        ast_node->children[0]->children[0]->type == Yosys::AST::AST_RANGE) {
        std::stringstream sstr;
        sstr << "$memwr$" << ast_node->children[0]->str << "$" << encode_filename(ast_node->filename) << ":" << ast_node->location.first_line << "$"
             << (autoidx++);
        std::string id_addr = sstr.str() + "_ADDR", id_data = sstr.str() + "_DATA", id_en = sstr.str() + "_EN";

        int mem_width, mem_size, addr_bits;
        bool mem_signed = ast_node->children[0]->id2ast->is_signed;
        ast_node->children[0]->id2ast->meminfo(mem_width, mem_size, addr_bits);

        newNode = new Yosys::AST::AstNode(Yosys::AST::AST_BLOCK);
        Yosys::AST::AstNode *defNode = new Yosys::AST::AstNode(Yosys::AST::AST_BLOCK);

        int data_range_left = ast_node->children[0]->id2ast->children[0]->range_left;
        int data_range_right = ast_node->children[0]->id2ast->children[0]->range_right;
        int mem_data_range_offset = std::min(data_range_left, data_range_right);

        int addr_width_hint = -1;
        bool addr_sign_hint = true;
        ast_node->children[0]->children[0]->children[0]->detectSignWidthWorker(addr_width_hint, addr_sign_hint);
        addr_bits = std::max(addr_bits, addr_width_hint);

        std::vector<RTLIL::State> x_bits_addr, x_bits_data, set_bits_en;
        for (int i = 0; i < addr_bits; i++)
            x_bits_addr.push_back(RTLIL::State::Sx);
        for (int i = 0; i < mem_width; i++)
            x_bits_data.push_back(RTLIL::State::Sx);
        for (int i = 0; i < mem_width; i++)
            set_bits_en.push_back(RTLIL::State::S1);

        Yosys::AST::AstNode *node_addr = nullptr;
        if (ast_node->children[0]->children[0]->children[0]->isConst()) {
            node_addr = ast_node->children[0]->children[0]->children[0]->clone();
        } else {
            Yosys::AST::AstNode *wire_addr =
              new Yosys::AST::AstNode(Yosys::AST::AST_WIRE, new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(addr_bits - 1, true),
                                                                                    ast_node->mkconst_int(0, true)));
            wire_addr->str = id_addr;
            wire_addr->was_checked = true;
            current_ast_mod->children.push_back(wire_addr);
            current_scope[wire_addr->str] = wire_addr;
            while (simplify(wire_addr, true, false, false, 1, -1, false, false)) {
            }

            Yosys::AST::AstNode *assign_addr = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                                       Yosys::AST::AstNode::mkconst_bits(x_bits_addr, false));
            assign_addr->children[0]->str = id_addr;
            assign_addr->children[0]->was_checked = true;
            defNode->children.push_back(assign_addr);

            assign_addr = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                  ast_node->children[0]->children[0]->children[0]->clone());
            assign_addr->children[0]->str = id_addr;
            assign_addr->children[0]->was_checked = true;
            newNode->children.push_back(assign_addr);

            node_addr = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
            node_addr->str = id_addr;
        }

        Yosys::AST::AstNode *node_data = nullptr;
        if (ast_node->children[0]->children.size() == 1 && ast_node->children[1]->isConst()) {
            node_data = ast_node->children[1]->clone();
        } else {
            Yosys::AST::AstNode *wire_data =
              new Yosys::AST::AstNode(Yosys::AST::AST_WIRE, new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(mem_width - 1, true),
                                                                                    ast_node->mkconst_int(0, true)));
            wire_data->str = id_data;
            wire_data->was_checked = true;
            wire_data->is_signed = mem_signed;
            current_ast_mod->children.push_back(wire_data);
            current_scope[wire_data->str] = wire_data;
            while (simplify(wire_data, true, false, false, 1, -1, false, false)) {
            }

            Yosys::AST::AstNode *assign_data = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                                       Yosys::AST::AstNode::mkconst_bits(x_bits_data, false));
            assign_data->children[0]->str = id_data;
            assign_data->children[0]->was_checked = true;
            defNode->children.push_back(assign_data);

            node_data = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
            node_data->str = id_data;
        }

        Yosys::AST::AstNode *wire_en =
          new Yosys::AST::AstNode(Yosys::AST::AST_WIRE, new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(mem_width - 1, true),
                                                                                ast_node->mkconst_int(0, true)));
        wire_en->str = id_en;
        wire_en->was_checked = true;
        current_ast_mod->children.push_back(wire_en);
        current_scope[wire_en->str] = wire_en;
        while (simplify(wire_en, true, false, false, 1, -1, false, false)) {
        }

        Yosys::AST::AstNode *assign_en_first = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                                       ast_node->mkconst_int(0, false, mem_width));
        assign_en_first->children[0]->str = id_en;
        assign_en_first->children[0]->was_checked = true;
        defNode->children.push_back(assign_en_first);

        Yosys::AST::AstNode *node_en = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
        node_en->str = id_en;

        if (!defNode->children.empty())
            current_top_block->children.insert(current_top_block->children.begin(), defNode);
        else
            delete defNode;

        Yosys::AST::AstNode *assign_data = nullptr;
        Yosys::AST::AstNode *assign_en = nullptr;
        if (ast_node->children[0]->children.size() == 2) {
            if (ast_node->children[0]->children[1]->range_valid) {
                int offset = ast_node->children[0]->children[1]->range_right;
                int width = ast_node->children[0]->children[1]->range_left - offset + 1;
                offset -= mem_data_range_offset;

                std::vector<RTLIL::State> padding_x(offset, RTLIL::State::Sx);

                assign_data =
                  new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                          new Yosys::AST::AstNode(Yosys::AST::AST_CONCAT, Yosys::AST::AstNode::mkconst_bits(padding_x, false),
                                                                  ast_node->children[1]->clone()));
                assign_data->children[0]->str = id_data;
                assign_data->children[0]->was_checked = true;

                for (int i = 0; i < mem_width; i++)
                    set_bits_en[i] = offset <= i && i < offset + width ? RTLIL::State::S1 : RTLIL::State::S0;
                assign_en = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                    Yosys::AST::AstNode::mkconst_bits(set_bits_en, false));
                assign_en->children[0]->str = id_en;
                assign_en->children[0]->was_checked = true;
            } else {
                Yosys::AST::AstNode *the_range = ast_node->children[0]->children[1];
                Yosys::AST::AstNode *left_at_zero_ast = the_range->children[0]->clone();
                Yosys::AST::AstNode *right_at_zero_ast =
                  the_range->children.size() >= 2 ? the_range->children[1]->clone() : left_at_zero_ast->clone();
                Yosys::AST::AstNode *offset_ast = right_at_zero_ast->clone();

                if (mem_data_range_offset)
                    offset_ast = new Yosys::AST::AstNode(Yosys::AST::AST_SUB, offset_ast, ast_node->mkconst_int(mem_data_range_offset, true));

                while (simplify(left_at_zero_ast, true, true, false, 1, -1, false, false)) {
                }
                while (simplify(right_at_zero_ast, true, true, false, 1, -1, false, false)) {
                }
                if (left_at_zero_ast->type != Yosys::AST::AST_CONSTANT || right_at_zero_ast->type != Yosys::AST::AST_CONSTANT)
                    log_file_error(ast_node->filename, ast_node->location.first_line,
                                   "Unsupported expression on dynamic range select on signal `%s'!\n", ast_node->str.c_str());
                int width = abs(int(left_at_zero_ast->integer - right_at_zero_ast->integer)) + 1;

                assign_data =
                  new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                          new Yosys::AST::AstNode(Yosys::AST::AST_SHIFT_LEFT, ast_node->children[1]->clone(), offset_ast->clone()));
                assign_data->children[0]->str = id_data;
                assign_data->children[0]->was_checked = true;

                for (int i = 0; i < mem_width; i++)
                    set_bits_en[i] = i < width ? RTLIL::State::S1 : RTLIL::State::S0;
                assign_en = new Yosys::AST::AstNode(
                  Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                  new Yosys::AST::AstNode(Yosys::AST::AST_SHIFT_LEFT, Yosys::AST::AstNode::mkconst_bits(set_bits_en, false), offset_ast->clone()));
                assign_en->children[0]->str = id_en;
                assign_en->children[0]->was_checked = true;

                delete left_at_zero_ast;
                delete right_at_zero_ast;
                delete offset_ast;
            }
        } else {
            if (!(ast_node->children[0]->children.size() == 1 && ast_node->children[1]->isConst())) {
                assign_data = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                      ast_node->children[1]->clone());
                assign_data->children[0]->str = id_data;
                assign_data->children[0]->was_checked = true;
            }

            assign_en = new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER),
                                                Yosys::AST::AstNode::mkconst_bits(set_bits_en, false));
            assign_en->children[0]->str = id_en;
            assign_en->children[0]->was_checked = true;
        }
        if (assign_data)
            newNode->children.push_back(assign_data);
        if (assign_en)
            newNode->children.push_back(assign_en);

        Yosys::AST::AstNode *wrnode;
        if (current_always->type == Yosys::AST::AST_INITIAL)
            wrnode = new Yosys::AST::AstNode(Yosys::AST::AST_MEMINIT, node_addr, node_data, node_en, ast_node->mkconst_int(1, false));
        else
            wrnode = new Yosys::AST::AstNode(Yosys::AST::AST_MEMWR, node_addr, node_data, node_en);
        wrnode->str = ast_node->children[0]->str;
        wrnode->id2ast = ast_node->children[0]->id2ast;
        wrnode->location = ast_node->location;
        if (wrnode->type == Yosys::AST::AST_MEMWR) {
            int portid = current_memwr_count[wrnode->str]++;
            wrnode->children.push_back(ast_node->mkconst_int(portid, false));
            std::vector<RTLIL::State> priority_mask;
            for (int i = 0; i < portid; i++) {
                bool has_prio = current_memwr_visible[wrnode->str].count(i);
                priority_mask.push_back(State(has_prio));
            }
            wrnode->children.push_back(Yosys::AST::AstNode::mkconst_bits(priority_mask, false));
            current_memwr_visible[wrnode->str].insert(portid);
            current_always->children.push_back(wrnode);
        } else {
            current_ast_mod->children.push_back(wrnode);
        }

        if (newNode->children.empty()) {
            delete newNode;
            newNode = new Yosys::AST::AstNode();
        }
        goto apply_newNode;
    }

    // replace function and task calls with the code from the function or task
    if ((ast_node->type == Yosys::AST::AST_FCALL || ast_node->type == Yosys::AST::AST_TCALL) && !ast_node->str.empty()) {
        if (ast_node->type == Yosys::AST::AST_FCALL) {
            if (ast_node->str == "\\$initstate") {
                int myidx = autoidx++;

                Yosys::AST::AstNode *wire = new Yosys::AST::AstNode(Yosys::AST::AST_WIRE);
                wire->str = stringf("$initstate$%d_wire", myidx);
                current_ast_mod->children.push_back(wire);
                while (simplify(wire, true, false, false, 1, -1, false, false)) {
                }

                Yosys::AST::AstNode *cell =
                  new Yosys::AST::AstNode(Yosys::AST::AST_CELL, new Yosys::AST::AstNode(Yosys::AST::AST_CELLTYPE),
                                          new Yosys::AST::AstNode(Yosys::AST::AST_ARGUMENT, new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER)));
                cell->str = stringf("$initstate$%d", myidx);
                cell->children[0]->str = "$initstate";
                cell->children[1]->str = "\\Y";
                cell->children[1]->children[0]->str = wire->str;
                cell->children[1]->children[0]->id2ast = wire;
                current_ast_mod->children.push_back(cell);
                while (simplify(cell, true, false, false, 1, -1, false, false)) {
                }

                newNode = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
                newNode->str = wire->str;
                newNode->id2ast = wire;
                goto apply_newNode;
            }

            if (ast_node->str == "\\$past") {
                if (width_hint < 0)
                    goto replace_fcall_later;

                int num_steps = 1;

                if (GetSize(ast_node->children) != 1 && GetSize(ast_node->children) != 2)
                    log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s got %d arguments, expected 1 or 2.\n",
                                   RTLIL::unescape_id(ast_node->str).c_str(), int(ast_node->children.size()));

                if (!current_always_clocked)
                    log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s is only allowed in clocked blocks.\n",
                                   RTLIL::unescape_id(ast_node->str).c_str());

                if (GetSize(ast_node->children) == 2) {
                    Yosys::AST::AstNode *buf = ast_node->children[1]->clone();
                    while (simplify(buf, true, false, false, stage, -1, false, false)) {
                    }
                    if (buf->type != Yosys::AST::AST_CONSTANT)
                        log_file_error(ast_node->filename, ast_node->location.first_line,
                                       "Failed to evaluate system function `%s' with non-constant value.\n", ast_node->str.c_str());

                    num_steps = buf->asInt(true);
                    delete buf;
                }

                Yosys::AST::AstNode *block = nullptr;

                for (auto child : current_always->children)
                    if (child->type == Yosys::AST::AST_BLOCK)
                        block = child;

                log_assert(block != nullptr);

                if (num_steps == 0) {
                    newNode = ast_node->children[0]->clone();
                    goto apply_newNode;
                }

                int myidx = autoidx++;
                Yosys::AST::AstNode *outreg = nullptr;

                for (int i = 0; i < num_steps; i++) {
                    Yosys::AST::AstNode *reg = new Yosys::AST::AstNode(
                      Yosys::AST::AST_WIRE,
                      new Yosys::AST::AstNode(Yosys::AST::AST_RANGE, ast_node->mkconst_int(width_hint - 1, true), ast_node->mkconst_int(0, true)));

                    reg->str = stringf("$past$%s:%d$%d$%d", encode_filename(ast_node->filename).c_str(), ast_node->location.first_line, myidx, i);
                    reg->is_reg = true;
                    reg->is_signed = sign_hint;

                    current_ast_mod->children.push_back(reg);

                    while (simplify(reg, true, false, false, 1, -1, false, false)) {
                    }

                    Yosys::AST::AstNode *regid = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
                    regid->str = reg->str;
                    regid->id2ast = reg;
                    regid->was_checked = true;

                    Yosys::AST::AstNode *rhs = nullptr;

                    if (outreg == nullptr) {
                        rhs = ast_node->children.at(0)->clone();
                    } else {
                        rhs = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
                        rhs->str = outreg->str;
                        rhs->id2ast = outreg;
                    }

                    block->children.push_back(new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_LE, regid, rhs));
                    outreg = reg;
                }

                newNode = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
                newNode->str = outreg->str;
                newNode->id2ast = outreg;
                goto apply_newNode;
            }

            if (ast_node->str == "\\$stable" || ast_node->str == "\\$rose" || ast_node->str == "\\$fell" || ast_node->str == "\\$changed") {
                if (GetSize(ast_node->children) != 1)
                    log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s got %d arguments, expected 1.\n",
                                   RTLIL::unescape_id(ast_node->str).c_str(), int(ast_node->children.size()));

                if (!current_always_clocked)
                    log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s is only allowed in clocked blocks.\n",
                                   RTLIL::unescape_id(ast_node->str).c_str());

                Yosys::AST::AstNode *present = ast_node->children.at(0)->clone();
                Yosys::AST::AstNode *past = ast_node->clone();
                past->str = "\\$past";

                if (ast_node->str == "\\$stable")
                    newNode = new Yosys::AST::AstNode(Yosys::AST::AST_EQ, past, present);

                else if (ast_node->str == "\\$changed")
                    newNode = new Yosys::AST::AstNode(Yosys::AST::AST_NE, past, present);

                else if (ast_node->str == "\\$rose")
                    newNode = new Yosys::AST::AstNode(
                      Yosys::AST::AST_LOGIC_AND,
                      new Yosys::AST::AstNode(Yosys::AST::AST_LOGIC_NOT,
                                              new Yosys::AST::AstNode(Yosys::AST::AST_BIT_AND, past, ast_node->mkconst_int(1, false))),
                      new Yosys::AST::AstNode(Yosys::AST::AST_BIT_AND, present, ast_node->mkconst_int(1, false)));

                else if (ast_node->str == "\\$fell")
                    newNode = new Yosys::AST::AstNode(
                      Yosys::AST::AST_LOGIC_AND, new Yosys::AST::AstNode(Yosys::AST::AST_BIT_AND, past, ast_node->mkconst_int(1, false)),
                      new Yosys::AST::AstNode(Yosys::AST::AST_LOGIC_NOT,
                                              new Yosys::AST::AstNode(Yosys::AST::AST_BIT_AND, present, ast_node->mkconst_int(1, false))));

                else
                    log_abort();

                goto apply_newNode;
            }

            // $anyconst and $anyseq are mapped in genRTLIL()
            if (ast_node->str == "\\$anyconst" || ast_node->str == "\\$anyseq" || ast_node->str == "\\$allconst" || ast_node->str == "\\$allseq") {
                recursion_counter--;
                return false;
            }

            if (ast_node->str == "\\$clog2") {
                if (ast_node->children.size() != 1)
                    log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s got %d arguments, expected 1.\n",
                                   RTLIL::unescape_id(ast_node->str).c_str(), int(ast_node->children.size()));

                Yosys::AST::AstNode *buf = ast_node->children[0]->clone();
                while (simplify(buf, true, false, false, stage, width_hint, sign_hint, false)) {
                }
                if (buf->type != Yosys::AST::AST_CONSTANT)
                    log_file_error(ast_node->filename, ast_node->location.first_line,
                                   "Failed to evaluate system function `%s' with non-constant value.\n", ast_node->str.c_str());

                RTLIL::Const arg_value = buf->bitsAsConst();
                if (arg_value.as_bool())
                    arg_value = const_sub(arg_value, 1, false, false, GetSize(arg_value));
                delete buf;

                uint32_t result = 0;
                for (size_t i = 0; i < arg_value.bits.size(); i++)
                    if (arg_value.bits.at(i) == RTLIL::State::S1)
                        result = i + 1;

                newNode = ast_node->mkconst_int(result, true);
                goto apply_newNode;
            }

            if (ast_node->str == "\\$size" || ast_node->str == "\\$bits" || ast_node->str == "\\$high" || ast_node->str == "\\$low" ||
                ast_node->str == "\\$left" || ast_node->str == "\\$right") {
                int dim = 1;
                if (ast_node->str == "\\$bits") {
                    if (ast_node->children.size() != 1)
                        log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s got %d arguments, expected 1.\n",
                                       RTLIL::unescape_id(ast_node->str).c_str(), int(ast_node->children.size()));
                } else {
                    if (ast_node->children.size() != 1 && ast_node->children.size() != 2)
                        log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s got %d arguments, expected 1 or 2.\n",
                                       RTLIL::unescape_id(ast_node->str).c_str(), int(ast_node->children.size()));
                    if (ast_node->children.size() == 2) {
                        Yosys::AST::AstNode *buf = ast_node->children[1]->clone();
                        // Evaluate constant expression
                        while (simplify(buf, true, false, false, stage, width_hint, sign_hint, false)) {
                        }
                        dim = buf->asInt(false);
                        delete buf;
                    }
                }
                Yosys::AST::AstNode *buf = ast_node->children[0]->clone();
                int mem_depth = 1;
                int result, high = 0, low = 0, left = 0, right = 0, width = 1; // defaults for a simple wire
                Yosys::AST::AstNode *id_ast = NULL;

                // Is this needed?
                // while (simplify(buf, true, false, false, stage, width_hint, sign_hint, false)) { }
                buf->detectSignWidth(width_hint, sign_hint);

                if (buf->type == Yosys::AST::AST_IDENTIFIER) {
                    id_ast = buf->id2ast;
                    if (id_ast == NULL && current_scope.count(buf->str))
                        id_ast = current_scope.at(buf->str);
                    if (!id_ast)
                        log_file_error(ast_node->filename, ast_node->location.first_line, "Failed to resolve identifier %s for width detection!\n",
                                       buf->str.c_str());

                    // Check for item in packed struct / union
                    Yosys::AST::AstNode *item_node = systemverilog_plugin::get_struct_member(buf);
                    if (id_ast->type == Yosys::AST::AST_WIRE && item_node) {
                        // The dimension of the original array expression is saved in the 'integer' field
                        dim += buf->integer;
                        if (item_node->dimensions.empty()) {
                            if (dim != 1)
                                log_file_error(ast_node->filename, ast_node->location.first_line,
                                               "Dimension %d out of range in `%s', as it only has one dimension!\n", dim, item_node->str.c_str());
                            left = high = item_node->range_left;
                            right = low = item_node->range_right;
                        } else {
                            int dims = GetSize(item_node->dimensions);
                            if (dim < 1 || dim > dims)
                                log_file_error(ast_node->filename, ast_node->location.first_line,
                                               "Dimension %d out of range in `%s', as it only has dimensions 1..%d!\n", dim, item_node->str.c_str(),
                                               dims);
                            right = low = get_struct_range_offset(item_node, dim - 1);
                            left = high = low + get_struct_range_width(item_node, dim - 1) - 1;
                            if (item_node->dimensions[dim - 1].range_swapped) {
                                std::swap(left, right);
                            }
                            for (int i = dim; i < dims; i++) {
                                mem_depth *= get_struct_range_width(item_node, i);
                            }
                        }
                    }
                    // Otherwise, we have 4 cases:
                    // wire x;                ==> AST_WIRE, no AST_RANGE children
                    // wire [1:0]x;           ==> AST_WIRE, AST_RANGE children
                    // wire [1:0]x[1:0];      ==> AST_MEMORY, two AST_RANGE children (1st for packed, 2nd for unpacked)
                    // wire [1:0]x[1:0][1:0]; ==> AST_MEMORY, one AST_RANGE child (0) for packed, then AST_MULTIRANGE child (1) for unpacked
                    // (updated: actually by the time we are here, AST_MULTIRANGE is converted into one big AST_RANGE)
                    // case 0 handled by default
                    else if ((id_ast->type == Yosys::AST::AST_WIRE || id_ast->type == Yosys::AST::AST_MEMORY) && id_ast->children.size() > 0) {
                        // handle packed array left/right for case 1, and cases 2/3 when requesting the last dimension (packed side)
                        Yosys::AST::AstNode *wire_range = id_ast->children[0];
                        left = wire_range->children[0]->integer;
                        right = wire_range->children[1]->integer;
                        high = max(left, right);
                        low = min(left, right);
                    }
                    if (id_ast->type == Yosys::AST::AST_MEMORY) {
                        // a slice of our identifier means we advance to the next dimension, e.g. $size(a[3])
                        if (buf->children.size() > 0) {
                            // something is hanging below this identifier
                            if (buf->children[0]->type == Yosys::AST::AST_RANGE && buf->integer == 0)
                                // if integer == 0, ast_node node was originally created as Yosys::AST::AST_RANGE so it's dimension is 1
                                dim++;
                            // more than one range, e.g. $size(a[3][2])
                            else // created an Yosys::AST::AST_MULTIRANGE, converted to Yosys::AST::AST_RANGE, but original dimension saved in
                                 // 'integer' field
                                dim += buf->integer; // increment by multirange size
                        }

                        // We got here only if the argument is a memory
                        // Otherwise $size() and $bits() return the expression width
                        Yosys::AST::AstNode *mem_range = id_ast->children[1];
                        if (ast_node->str == "\\$bits") {
                            if (mem_range->type == Yosys::AST::AST_RANGE) {
                                if (!mem_range->range_valid)
                                    log_file_error(ast_node->filename, ast_node->location.first_line,
                                                   "Failed to detect width of memory access `%s'!\n", buf->str.c_str());
                                mem_depth = mem_range->range_left - mem_range->range_right + 1;
                            } else
                                log_file_error(ast_node->filename, ast_node->location.first_line, "Unknown memory depth AST type in `%s'!\n",
                                               buf->str.c_str());
                        } else {
                            // $size(), $left(), $right(), $high(), $low()
                            int dims = 1;
                            if (mem_range->type == Yosys::AST::AST_RANGE) {
                                if (id_ast->dimensions.empty()) {
                                    if (!mem_range->range_valid)
                                        log_file_error(ast_node->filename, ast_node->location.first_line,
                                                       "Failed to detect width of memory access `%s'!\n", buf->str.c_str());
                                    if (dim == 1) {
                                        left = mem_range->range_right;
                                        right = mem_range->range_left;
                                        high = max(left, right);
                                        low = min(left, right);
                                    }
                                } else {
                                    dims = GetSize(id_ast->dimensions);
                                    if (dim <= dims) {
                                        auto& current = id_ast->dimensions[dim - 1];
                                        width_hint = current.range_width;
                                        high = current.range_right + current.range_width - 1;
                                        low = current.range_width;
                                        if (current.range_swapped) {
                                            left = low;
                                            right = high;
                                        } else {
                                            right = low;
                                            left = high;
                                        }
                                    } else if ((dim > dims + 1) || (dim < 0))
                                        log_file_error(ast_node->filename, ast_node->location.first_line,
                                                       "Dimension %d out of range in `%s', as it only has dimensions 1..%d!\n", dim, buf->str.c_str(),
                                                       dims + 1);
                                }
                            } else {
                                log_file_error(ast_node->filename, ast_node->location.first_line, "Unknown memory depth AST type in `%s'!\n",
                                               buf->str.c_str());
                            }
                        }
                    }
                    width = high - low + 1;
                } else {
                    width = width_hint;
                }
                delete buf;
                if (ast_node->str == "\\$high")
                    result = high;
                else if (ast_node->str == "\\$low")
                    result = low;
                else if (ast_node->str == "\\$left")
                    result = left;
                else if (ast_node->str == "\\$right")
                    result = right;
                else if (ast_node->str == "\\$size")
                    result = width;
                else { // ast_node->str == "\\$bits"
                    result = width * mem_depth;
                }
                newNode = ast_node->mkconst_int(result, true);
                goto apply_newNode;
            }

            if (ast_node->str == "\\$ln" || ast_node->str == "\\$log10" || ast_node->str == "\\$exp" || ast_node->str == "\\$sqrt" ||
                ast_node->str == "\\$pow" || ast_node->str == "\\$floor" || ast_node->str == "\\$ceil" || ast_node->str == "\\$sin" ||
                ast_node->str == "\\$cos" || ast_node->str == "\\$tan" || ast_node->str == "\\$asin" || ast_node->str == "\\$acos" ||
                ast_node->str == "\\$atan" || ast_node->str == "\\$atan2" || ast_node->str == "\\$hypot" || ast_node->str == "\\$sinh" ||
                ast_node->str == "\\$cosh" || ast_node->str == "\\$tanh" || ast_node->str == "\\$asinh" || ast_node->str == "\\$acosh" ||
                ast_node->str == "\\$atanh" || ast_node->str == "\\$rtoi" || ast_node->str == "\\$itor") {
                bool func_with_two_arguments = ast_node->str == "\\$pow" || ast_node->str == "\\$atan2" || ast_node->str == "\\$hypot";
                double x = 0, y = 0;

                if (func_with_two_arguments) {
                    if (ast_node->children.size() != 2)
                        log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s got %d arguments, expected 2.\n",
                                       RTLIL::unescape_id(ast_node->str).c_str(), int(ast_node->children.size()));
                } else {
                    if (ast_node->children.size() != 1)
                        log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s got %d arguments, expected 1.\n",
                                       RTLIL::unescape_id(ast_node->str).c_str(), int(ast_node->children.size()));
                }

                if (ast_node->children.size() >= 1) {
                    while (simplify(ast_node->children[0], true, false, false, stage, width_hint, sign_hint, false)) {
                    }
                    if (!ast_node->children[0]->isConst())
                        log_file_error(ast_node->filename, ast_node->location.first_line,
                                       "Failed to evaluate system function `%s' with non-constant argument.\n",
                                       RTLIL::unescape_id(ast_node->str).c_str());
                    int child_width_hint = width_hint;
                    bool child_sign_hint = sign_hint;
                    ast_node->children[0]->detectSignWidth(child_width_hint, child_sign_hint);
                    x = ast_node->children[0]->asReal(child_sign_hint);
                }

                if (ast_node->children.size() >= 2) {
                    while (simplify(ast_node->children[1], true, false, false, stage, width_hint, sign_hint, false)) {
                    }
                    if (!ast_node->children[1]->isConst())
                        log_file_error(ast_node->filename, ast_node->location.first_line,
                                       "Failed to evaluate system function `%s' with non-constant argument.\n",
                                       RTLIL::unescape_id(ast_node->str).c_str());
                    int child_width_hint = width_hint;
                    bool child_sign_hint = sign_hint;
                    ast_node->children[1]->detectSignWidth(child_width_hint, child_sign_hint);
                    y = ast_node->children[1]->asReal(child_sign_hint);
                }

                if (ast_node->str == "\\$rtoi") {
                    newNode = ast_node->mkconst_int(x, true);
                } else {
                    newNode = new Yosys::AST::AstNode(Yosys::AST::AST_REALVALUE);
                    if (ast_node->str == "\\$ln")
                        newNode->realvalue = ::log(x);
                    else if (ast_node->str == "\\$log10")
                        newNode->realvalue = ::log10(x);
                    else if (ast_node->str == "\\$exp")
                        newNode->realvalue = ::exp(x);
                    else if (ast_node->str == "\\$sqrt")
                        newNode->realvalue = ::sqrt(x);
                    else if (ast_node->str == "\\$pow")
                        newNode->realvalue = ::pow(x, y);
                    else if (ast_node->str == "\\$floor")
                        newNode->realvalue = ::floor(x);
                    else if (ast_node->str == "\\$ceil")
                        newNode->realvalue = ::ceil(x);
                    else if (ast_node->str == "\\$sin")
                        newNode->realvalue = ::sin(x);
                    else if (ast_node->str == "\\$cos")
                        newNode->realvalue = ::cos(x);
                    else if (ast_node->str == "\\$tan")
                        newNode->realvalue = ::tan(x);
                    else if (ast_node->str == "\\$asin")
                        newNode->realvalue = ::asin(x);
                    else if (ast_node->str == "\\$acos")
                        newNode->realvalue = ::acos(x);
                    else if (ast_node->str == "\\$atan")
                        newNode->realvalue = ::atan(x);
                    else if (ast_node->str == "\\$atan2")
                        newNode->realvalue = ::atan2(x, y);
                    else if (ast_node->str == "\\$hypot")
                        newNode->realvalue = ::hypot(x, y);
                    else if (ast_node->str == "\\$sinh")
                        newNode->realvalue = ::sinh(x);
                    else if (ast_node->str == "\\$cosh")
                        newNode->realvalue = ::cosh(x);
                    else if (ast_node->str == "\\$tanh")
                        newNode->realvalue = ::tanh(x);
                    else if (ast_node->str == "\\$asinh")
                        newNode->realvalue = ::asinh(x);
                    else if (ast_node->str == "\\$acosh")
                        newNode->realvalue = ::acosh(x);
                    else if (ast_node->str == "\\$atanh")
                        newNode->realvalue = ::atanh(x);
                    else if (ast_node->str == "\\$itor")
                        newNode->realvalue = x;
                    else
                        log_abort();
                }
                goto apply_newNode;
            }

            if (ast_node->str == "\\$sformatf") {
                Fmt fmt = ast_node->processFormat(stage, /*sformat_like=*/true);
                newNode = Yosys::AST::AstNode::mkconst_str(fmt.render());
                goto apply_newNode;
            }

            if (ast_node->str == "\\$countbits") {
                if (ast_node->children.size() < 2)
                    log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s got %d arguments, expected at least 2.\n",
                                   RTLIL::unescape_id(ast_node->str).c_str(), int(ast_node->children.size()));

                std::vector<RTLIL::State> control_bits;

                // Determine which bits to count
                for (size_t i = 1; i < ast_node->children.size(); i++) {
                    Yosys::AST::AstNode *node = ast_node->children[i];
                    while (simplify(node, true, false, false, stage, -1, false, false)) {
                    }
                    if (node->type != Yosys::AST::AST_CONSTANT)
                        log_file_error(ast_node->filename, ast_node->location.first_line,
                                       "Failed to evaluate system function `%s' with non-constant control bit argument.\n", ast_node->str.c_str());
                    if (node->bits.size() != 1)
                        log_file_error(ast_node->filename, ast_node->location.first_line,
                                       "Failed to evaluate system function `%s' with control bit width != 1.\n", ast_node->str.c_str());
                    control_bits.push_back(node->bits[0]);
                }

                // Detect width of exp (first argument of $countbits)
                int exp_width = -1;
                bool exp_sign = false;
                Yosys::AST::AstNode *exp = ast_node->children[0];
                exp->detectSignWidth(exp_width, exp_sign, NULL);

                newNode = ast_node->mkconst_int(0, false);

                for (int i = 0; i < exp_width; i++) {
                    // Generate nodes for:  exp << i >> ($size(exp) - 1)
                    //                          ^^   ^^
                    Yosys::AST::AstNode *lsh_node =
                      new Yosys::AST::AstNode(Yosys::AST::AST_SHIFT_LEFT, exp->clone(), Yosys::AST::AstNode::mkconst_int(i, false));
                    Yosys::AST::AstNode *rsh_node =
                      new Yosys::AST::AstNode(Yosys::AST::AST_SHIFT_RIGHT, lsh_node, Yosys::AST::AstNode::mkconst_int(exp_width - 1, false));

                    Yosys::AST::AstNode *or_node = nullptr;

                    for (RTLIL::State control_bit : control_bits) {
                        // Generate node for:  (exp << i >> ($size(exp) - 1)) === control_bit
                        //                                                    ^^^
                        Yosys::AST::AstNode *eq_node =
                          new Yosys::AST::AstNode(Yosys::AST::AST_EQX, rsh_node->clone(), Yosys::AST::AstNode::mkconst_bits({control_bit}, false));

                        // Or the result for each checked bit value
                        if (or_node)
                            or_node = new Yosys::AST::AstNode(Yosys::AST::AST_LOGIC_OR, or_node, eq_node);
                        else
                            or_node = eq_node;
                    }

                    // We should have at least one element in control_bits,
                    // because we checked for the number of arguments above
                    log_assert(or_node != nullptr);

                    delete rsh_node;

                    // Generate node for adding with result of previous bit
                    newNode = new Yosys::AST::AstNode(Yosys::AST::AST_ADD, newNode, or_node);
                }

                goto apply_newNode;
            }

            if (ast_node->str == "\\$countones" || ast_node->str == "\\$isunknown" || ast_node->str == "\\$onehot" || ast_node->str == "\\$onehot0") {
                if (ast_node->children.size() != 1)
                    log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s got %d arguments, expected 1.\n",
                                   RTLIL::unescape_id(ast_node->str).c_str(), int(ast_node->children.size()));

                Yosys::AST::AstNode *countbits = ast_node->clone();
                countbits->str = "\\$countbits";

                if (ast_node->str == "\\$countones") {
                    countbits->children.push_back(Yosys::AST::AstNode::mkconst_bits({RTLIL::State::S1}, false));
                    newNode = countbits;
                } else if (ast_node->str == "\\$isunknown") {
                    countbits->children.push_back(Yosys::AST::AstNode::mkconst_bits({RTLIL::Sx}, false));
                    countbits->children.push_back(Yosys::AST::AstNode::mkconst_bits({RTLIL::Sz}, false));
                    newNode = new Yosys::AST::AstNode(Yosys::AST::AST_GT, countbits, Yosys::AST::AstNode::mkconst_int(0, false));
                } else if (ast_node->str == "\\$onehot") {
                    countbits->children.push_back(Yosys::AST::AstNode::mkconst_bits({RTLIL::State::S1}, false));
                    newNode = new Yosys::AST::AstNode(Yosys::AST::AST_EQ, countbits, Yosys::AST::AstNode::mkconst_int(1, false));
                } else if (ast_node->str == "\\$onehot0") {
                    countbits->children.push_back(Yosys::AST::AstNode::mkconst_bits({RTLIL::State::S1}, false));
                    newNode = new Yosys::AST::AstNode(Yosys::AST::AST_LE, countbits, Yosys::AST::AstNode::mkconst_int(1, false));
                } else {
                    log_abort();
                }

                goto apply_newNode;
            }

            if (current_scope.count(ast_node->str) != 0 && current_scope[ast_node->str]->type == Yosys::AST::AST_DPI_FUNCTION) {
                Yosys::AST::AstNode *dpi_decl = current_scope[ast_node->str];

                std::string rtype, fname;
                std::vector<std::string> argtypes;
                std::vector<Yosys::AST::AstNode *> args;

                rtype = RTLIL::unescape_id(dpi_decl->children.at(0)->str);
                fname = RTLIL::unescape_id(dpi_decl->children.at(1)->str);

                for (int i = 2; i < GetSize(dpi_decl->children); i++) {
                    if (i - 2 >= GetSize(ast_node->children))
                        log_file_error(ast_node->filename, ast_node->location.first_line, "Insufficient number of arguments in DPI function call.\n");

                    argtypes.push_back(RTLIL::unescape_id(dpi_decl->children.at(i)->str));
                    args.push_back(ast_node->children.at(i - 2)->clone());
                    while (simplify(args.back(), true, false, false, stage, -1, false, true)) {
                    }

                    if (args.back()->type != Yosys::AST::AST_CONSTANT && args.back()->type != Yosys::AST::AST_REALVALUE)
                        log_file_error(ast_node->filename, ast_node->location.first_line,
                                       "Failed to evaluate DPI function with non-constant argument.\n");
                }

                newNode = dpi_call(rtype, fname, argtypes, args);

                for (auto arg : args)
                    delete arg;

                goto apply_newNode;
            }

            if (current_scope.count(ast_node->str) == 0)
                ast_node->str = ast_node->try_pop_module_prefix();
            if (current_scope.count(ast_node->str) == 0 || current_scope[ast_node->str]->type != Yosys::AST::AST_FUNCTION)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Can't resolve function name `%s'.\n", ast_node->str.c_str());
        }

        if (ast_node->type == Yosys::AST::AST_TCALL) {
            if (ast_node->str == "$finish" || ast_node->str == "$stop") {
                if (!current_always || current_always->type != Yosys::AST::AST_INITIAL)
                    log_file_error(ast_node->filename, ast_node->location.first_line, "System task `%s' outside initial block is unsupported.\n",
                                   ast_node->str.c_str());

                log_file_error(ast_node->filename, ast_node->location.first_line, "System task `%s' executed.\n", ast_node->str.c_str());
            }

            if (ast_node->str == "\\$readmemh" || ast_node->str == "\\$readmemb") {
                if (GetSize(ast_node->children) < 2 || GetSize(ast_node->children) > 4)
                    log_file_error(ast_node->filename, ast_node->location.first_line, "System function %s got %d arguments, expected 2-4.\n",
                                   RTLIL::unescape_id(ast_node->str).c_str(), int(ast_node->children.size()));

                Yosys::AST::AstNode *node_filename = ast_node->children[0]->clone();
                while (simplify(node_filename, true, false, false, stage, width_hint, sign_hint, false)) {
                }
                if (node_filename->type != Yosys::AST::AST_CONSTANT)
                    log_file_error(ast_node->filename, ast_node->location.first_line,
                                   "Failed to evaluate system function `%s' with non-constant 1st argument.\n", ast_node->str.c_str());

                Yosys::AST::AstNode *node_memory = ast_node->children[1]->clone();
                while (simplify(node_memory, true, false, false, stage, width_hint, sign_hint, false)) {
                }
                if (node_memory->type != Yosys::AST::AST_IDENTIFIER || node_memory->id2ast == nullptr ||
                    node_memory->id2ast->type != Yosys::AST::AST_MEMORY)
                    log_file_error(ast_node->filename, ast_node->location.first_line,
                                   "Failed to evaluate system function `%s' with non-memory 2nd argument.\n", ast_node->str.c_str());

                int start_addr = -1, finish_addr = -1;

                if (GetSize(ast_node->children) > 2) {
                    Yosys::AST::AstNode *node_addr = ast_node->children[2]->clone();
                    while (simplify(node_addr, true, false, false, stage, width_hint, sign_hint, false)) {
                    }
                    if (node_addr->type != Yosys::AST::AST_CONSTANT)
                        log_file_error(ast_node->filename, ast_node->location.first_line,
                                       "Failed to evaluate system function `%s' with non-constant 3rd argument.\n", ast_node->str.c_str());
                    start_addr = int(node_addr->asInt(false));
                }

                if (GetSize(ast_node->children) > 3) {
                    Yosys::AST::AstNode *node_addr = ast_node->children[3]->clone();
                    while (simplify(node_addr, true, false, false, stage, width_hint, sign_hint, false)) {
                    }
                    if (node_addr->type != Yosys::AST::AST_CONSTANT)
                        log_file_error(ast_node->filename, ast_node->location.first_line,
                                       "Failed to evaluate system function `%s' with non-constant 4th argument.\n", ast_node->str.c_str());
                    finish_addr = int(node_addr->asInt(false));
                }

                bool unconditional_init = false;
                if (current_always->type == Yosys::AST::AST_INITIAL) {
                    pool<Yosys::AST::AstNode *> queue;
                    log_assert(current_always->children[0]->type == Yosys::AST::AST_BLOCK);
                    queue.insert(current_always->children[0]);
                    while (!unconditional_init && !queue.empty()) {
                        pool<Yosys::AST::AstNode *> next_queue;
                        for (auto n : queue)
                            for (auto c : n->children) {
                                if (c == ast_node)
                                    unconditional_init = true;
                                next_queue.insert(c);
                            }
                        next_queue.swap(queue);
                    }
                }

                newNode = ast_node->readmem(ast_node->str == "\\$readmemh", node_filename->bitsAsConst().decode_string(), node_memory->id2ast,
                                            start_addr, finish_addr, unconditional_init);
                delete node_filename;
                delete node_memory;
                goto apply_newNode;
            }

            if (current_scope.count(ast_node->str) == 0)
                ast_node->str = ast_node->try_pop_module_prefix();
            if (current_scope.count(ast_node->str) == 0 || current_scope[ast_node->str]->type != Yosys::AST::AST_TASK)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Can't resolve task name `%s'.\n", ast_node->str.c_str());
        }

        std::stringstream sstr;
        sstr << ast_node->str << "$func$" << encode_filename(ast_node->filename) << ":" << ast_node->location.first_line << "$" << (autoidx++) << '.';
        std::string prefix = sstr.str();

        Yosys::AST::AstNode *decl = current_scope[ast_node->str];
        if (unevaluated_tern_branch && decl->is_recursive_function())
            goto replace_fcall_later;
        decl = decl->clone();
        decl->replace_result_wire_name_in_function(ast_node->str, "$result"); // enables recursion
        decl->expand_genblock(prefix);

        if (decl->type == Yosys::AST::AST_FUNCTION && !decl->attributes.count(ID::via_celltype)) {
            bool require_const_eval = decl->has_const_only_constructs();
            bool all_args_const = true;
            for (auto child : ast_node->children) {
                while (simplify(child, true, false, false, 1, -1, false, true)) {
                }
                if (child->type != Yosys::AST::AST_CONSTANT && child->type != Yosys::AST::AST_REALVALUE)
                    all_args_const = false;
            }

            if (all_args_const) {
                Yosys::AST::AstNode *func_workspace = decl->clone();
                func_workspace->str = prefix_id(prefix, "$result");
                newNode = func_workspace->eval_const_function(ast_node, in_param || require_const_eval);
                delete func_workspace;
                if (newNode) {
                    delete decl;
                    goto apply_newNode;
                }
            }

            if (in_param)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Non-constant function call in constant expression.\n");
            if (require_const_eval)
                log_file_error(ast_node->filename, ast_node->location.first_line, "Function %s can only be called with constant arguments.\n",
                               ast_node->str.c_str());
        }

        size_t arg_count = 0;
        dict<std::string, Yosys::AST::AstNode *> wire_cache;
        vector<Yosys::AST::AstNode *> new_stmts;
        vector<Yosys::AST::AstNode *> output_assignments;

        if (current_block == NULL) {
            log_assert(ast_node->type == Yosys::AST::AST_FCALL);

            Yosys::AST::AstNode *wire = NULL;
            std::string res_name = prefix_id(prefix, "$result");
            for (auto child : decl->children)
                if (child->type == Yosys::AST::AST_WIRE && child->str == res_name)
                    wire = child->clone();
            log_assert(wire != NULL);

            wire->port_id = 0;
            wire->is_input = false;
            wire->is_output = false;

            current_scope[wire->str] = wire;
            current_ast_mod->children.push_back(wire);
            while (simplify(wire, true, false, false, 1, -1, false, false)) {
            }

            Yosys::AST::AstNode *lvalue = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
            lvalue->str = wire->str;

            Yosys::AST::AstNode *always = new Yosys::AST::AstNode(
              Yosys::AST::AST_ALWAYS,
              new Yosys::AST::AstNode(Yosys::AST::AST_BLOCK, new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, lvalue, ast_node->clone())));
            always->children[0]->children[0]->was_checked = true;

            current_ast_mod->children.push_back(always);

            goto replace_fcall_with_id;
        }

        if (decl->attributes.count(ID::via_celltype)) {
            std::string celltype = decl->attributes.at(ID::via_celltype)->asAttrConst().decode_string();
            std::string outport = ast_node->str;

            if (celltype.find(' ') != std::string::npos) {
                int pos = celltype.find(' ');
                outport = RTLIL::escape_id(celltype.substr(pos + 1));
                celltype = RTLIL::escape_id(celltype.substr(0, pos));
            } else
                celltype = RTLIL::escape_id(celltype);

            Yosys::AST::AstNode *cell = new Yosys::AST::AstNode(Yosys::AST::AST_CELL, new Yosys::AST::AstNode(Yosys::AST::AST_CELLTYPE));
            cell->str = prefix.substr(0, GetSize(prefix) - 1);
            cell->children[0]->str = celltype;

            for (auto attr : decl->attributes)
                if (attr.first.str().rfind("\\via_celltype_defparam_", 0) == 0) {
                    Yosys::AST::AstNode *cell_arg = new Yosys::AST::AstNode(Yosys::AST::AST_PARASET, attr.second->clone());
                    cell_arg->str = RTLIL::escape_id(attr.first.substr(strlen("\\via_celltype_defparam_")));
                    cell->children.push_back(cell_arg);
                }

            for (auto child : decl->children)
                if (child->type == Yosys::AST::AST_WIRE &&
                    (child->is_input || child->is_output || (ast_node->type == Yosys::AST::AST_FCALL && child->str == ast_node->str))) {
                    Yosys::AST::AstNode *wire = child->clone();
                    wire->port_id = 0;
                    wire->is_input = false;
                    wire->is_output = false;
                    current_ast_mod->children.push_back(wire);
                    while (simplify(wire, true, false, false, 1, -1, false, false)) {
                    }

                    Yosys::AST::AstNode *wire_id = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
                    wire_id->str = wire->str;

                    if ((child->is_input || child->is_output) && arg_count < ast_node->children.size()) {
                        Yosys::AST::AstNode *arg = ast_node->children[arg_count++]->clone();
                        Yosys::AST::AstNode *assign = child->is_input ? new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, wire_id->clone(), arg)
                                                                      : new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, arg, wire_id->clone());
                        assign->children[0]->was_checked = true;

                        for (auto it = current_block->children.begin(); it != current_block->children.end(); it++) {
                            if (*it != current_block_child)
                                continue;
                            current_block->children.insert(it, assign);
                            break;
                        }
                    }

                    Yosys::AST::AstNode *cell_arg = new Yosys::AST::AstNode(Yosys::AST::AST_ARGUMENT, wire_id);
                    cell_arg->str = child->str == ast_node->str ? outport : child->str;
                    cell->children.push_back(cell_arg);
                }

            current_ast_mod->children.push_back(cell);
            goto replace_fcall_with_id;
        }

        for (auto child : decl->children)
            if (child->type == Yosys::AST::AST_WIRE || child->type == Yosys::AST::AST_MEMORY || child->type == Yosys::AST::AST_PARAMETER ||
                child->type == Yosys::AST::AST_LOCALPARAM || child->type == Yosys::AST::AST_ENUM_ITEM) {
                Yosys::AST::AstNode *wire = nullptr;

                if (wire_cache.count(child->str)) {
                    wire = wire_cache.at(child->str);
                    bool contains_value = wire->type == Yosys::AST::AST_LOCALPARAM;
                    if (wire->children.size() == contains_value) {
                        for (auto c : child->children)
                            wire->children.push_back(c->clone());
                    } else if (!child->children.empty()) {
                        while (simplify(child, true, false, false, stage, -1, false, false)) {
                        }
                        if (GetSize(child->children) == GetSize(wire->children) - contains_value) {
                            for (int i = 0; i < GetSize(child->children); i++)
                                if (*child->children.at(i) != *wire->children.at(i + contains_value))
                                    goto tcall_incompatible_wires;
                        } else {
                        tcall_incompatible_wires:
                            log_file_error(ast_node->filename, ast_node->location.first_line, "Incompatible re-declaration of wire %s.\n",
                                           child->str.c_str());
                        }
                    }
                } else {
                    wire = child->clone();
                    wire->port_id = 0;
                    wire->is_input = false;
                    wire->is_output = false;
                    wire->is_reg = true;
                    wire->attributes[ID::nosync] = Yosys::AST::AstNode::mkconst_int(1, false);
                    if (child->type == Yosys::AST::AST_ENUM_ITEM)
                        wire->attributes[ID::enum_base_type] = child->attributes[ID::enum_base_type];

                    wire_cache[child->str] = wire;

                    current_scope[wire->str] = wire;
                    current_ast_mod->children.push_back(wire);
                }

                while (simplify(wire, true, false, false, 1, -1, false, false)) {
                }

                if ((child->is_input || child->is_output) && arg_count < ast_node->children.size()) {
                    Yosys::AST::AstNode *arg = ast_node->children[arg_count++]->clone();
                    // convert purely constant arguments into localparams
                    if (child->is_input && child->type == Yosys::AST::AST_WIRE && arg->type == Yosys::AST::AST_CONSTANT &&
                        node_contains_assignment_to(decl, child)) {
                        wire->type = Yosys::AST::AST_LOCALPARAM;
                        if (wire->attributes.count(ID::nosync))
                            delete wire->attributes.at(ID::nosync);
                        wire->attributes.erase(ID::nosync);
                        wire->children.insert(wire->children.begin(), arg->clone());
                        // args without a range implicitly have width 1
                        if (wire->children.back()->type != Yosys::AST::AST_RANGE) {
                            // check if this wire is redeclared with an explicit size
                            bool uses_explicit_size = false;
                            for (const Yosys::AST::AstNode *other_child : decl->children)
                                if (other_child->type == Yosys::AST::AST_WIRE && child->str == other_child->str && !other_child->children.empty() &&
                                    other_child->children.back()->type == Yosys::AST::AST_RANGE) {
                                    uses_explicit_size = true;
                                    break;
                                }
                            if (!uses_explicit_size) {
                                Yosys::AST::AstNode *range = new Yosys::AST::AstNode();
                                range->type = Yosys::AST::AST_RANGE;
                                wire->children.push_back(range);
                                range->children.push_back(Yosys::AST::AstNode::mkconst_int(0, true));
                                range->children.push_back(Yosys::AST::AstNode::mkconst_int(0, true));
                            }
                        }
                        // updates the sizing
                        while (simplify(wire, true, false, false, 1, -1, false, false)) {
                        }
                        delete arg;
                        continue;
                    }
                    Yosys::AST::AstNode *wire_id = new Yosys::AST::AstNode(Yosys::AST::AST_IDENTIFIER);
                    wire_id->str = wire->str;
                    Yosys::AST::AstNode *assign = child->is_input ? new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, wire_id, arg)
                                                                  : new Yosys::AST::AstNode(Yosys::AST::AST_ASSIGN_EQ, arg, wire_id);
                    assign->children[0]->was_checked = true;
                    if (child->is_input)
                        new_stmts.push_back(assign);
                    else
                        output_assignments.push_back(assign);
                }
            }

        for (auto child : decl->children)
            if (child->type != Yosys::AST::AST_WIRE && child->type != Yosys::AST::AST_MEMORY && child->type != Yosys::AST::AST_PARAMETER &&
                child->type != Yosys::AST::AST_LOCALPARAM)
                new_stmts.push_back(child->clone());

        new_stmts.insert(new_stmts.end(), output_assignments.begin(), output_assignments.end());

        for (auto it = current_block->children.begin();; it++) {
            log_assert(it != current_block->children.end());
            if (*it == current_block_child) {
                current_block->children.insert(it, new_stmts.begin(), new_stmts.end());
                break;
            }
        }

    replace_fcall_with_id:
        delete decl;
        if (ast_node->type == Yosys::AST::AST_FCALL) {
            ast_node->delete_children();
            ast_node->type = Yosys::AST::AST_IDENTIFIER;
            ast_node->str = prefix_id(prefix, "$result");
        }
        if (ast_node->type == Yosys::AST::AST_TCALL)
            ast_node->str = "";
        did_something = true;
    }

replace_fcall_later:;

    // perform const folding when activated
    if (const_fold) {
        bool string_op;
        std::vector<RTLIL::State> tmp_bits;
        RTLIL::Const (*const_func)(const RTLIL::Const &, const RTLIL::Const &, bool, bool, ys_size_type);
        RTLIL::Const dummy_arg;

        switch (ast_node->type) {
        case Yosys::AST::AST_IDENTIFIER:
            if (current_scope.count(ast_node->str) > 0 && (current_scope[ast_node->str]->type == Yosys::AST::AST_PARAMETER ||
                                                           current_scope[ast_node->str]->type == Yosys::AST::AST_LOCALPARAM ||
                                                           current_scope[ast_node->str]->type == Yosys::AST::AST_ENUM_ITEM)) {
                if (current_scope[ast_node->str]->children[0]->type == Yosys::AST::AST_CONSTANT) {
                    if (ast_node->children.size() != 0 && ast_node->children[0]->type == Yosys::AST::AST_RANGE &&
                        ast_node->children[0]->range_valid) {
                        std::vector<RTLIL::State> data;
                        bool param_upto = current_scope[ast_node->str]->range_valid && current_scope[ast_node->str]->range_swapped;
                        int param_offset = current_scope[ast_node->str]->range_valid ? current_scope[ast_node->str]->range_right : 0;
                        int param_width = current_scope[ast_node->str]->range_valid
                                            ? current_scope[ast_node->str]->range_left - current_scope[ast_node->str]->range_right + 1
                                            : GetSize(current_scope[ast_node->str]->children[0]->bits);
                        int tmp_range_left = ast_node->children[0]->range_left, tmp_range_right = ast_node->children[0]->range_right;
                        if (param_upto) {
                            tmp_range_left = (param_width + 2 * param_offset) - ast_node->children[0]->range_right - 1;
                            tmp_range_right = (param_width + 2 * param_offset) - ast_node->children[0]->range_left - 1;
                        }
                        Yosys::AST::AstNode *member_node = systemverilog_plugin::get_struct_member(ast_node);
                        int chunk_offset = member_node ? member_node->range_right : 0;
                        log_assert(!(chunk_offset && param_upto));
                        for (int i = tmp_range_right; i <= tmp_range_left; i++) {
                            int index = i - param_offset;
                            if (0 <= index && index < param_width)
                                data.push_back(current_scope[ast_node->str]->children[0]->bits[chunk_offset + index]);
                            else
                                data.push_back(RTLIL::State::Sx);
                        }
                        newNode = Yosys::AST::AstNode::mkconst_bits(data, false);
                    } else if (ast_node->children.size() == 0)
                        newNode = current_scope[ast_node->str]->children[0]->clone();
                } else if (current_scope[ast_node->str]->children[0]->isConst())
                    newNode = current_scope[ast_node->str]->children[0]->clone();
            } else if (at_zero && current_scope.count(ast_node->str) > 0) {
                Yosys::AST::AstNode *node = current_scope[ast_node->str];
                if (node->type == Yosys::AST::AST_WIRE || node->type == Yosys::AST::AST_AUTOWIRE || node->type == Yosys::AST::AST_MEMORY)
                    newNode = node->mkconst_int(0, sign_hint, width_hint);
            }
            break;
        case Yosys::AST::AST_MEMRD:
            if (at_zero) {
                newNode = Yosys::AST::AstNode::mkconst_int(0, sign_hint, width_hint);
            }
            break;
        case Yosys::AST::AST_BIT_NOT:
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT) {
                RTLIL::Const y = RTLIL::const_not(ast_node->children[0]->bitsAsConst(width_hint, sign_hint), dummy_arg, sign_hint, false, width_hint);
                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, sign_hint);
            }
            break;
        case Yosys::AST::AST_TO_SIGNED:
        case Yosys::AST::AST_TO_UNSIGNED:
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT) {
                RTLIL::Const y = ast_node->children[0]->bitsAsConst(width_hint, sign_hint);
                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, ast_node->type == Yosys::AST::AST_TO_SIGNED);
            }
            break;
            if (0) {
            case Yosys::AST::AST_BIT_AND:
                const_func = RTLIL::const_and;
            }
            if (0) {
            case Yosys::AST::AST_BIT_OR:
                const_func = RTLIL::const_or;
            }
            if (0) {
            case Yosys::AST::AST_BIT_XOR:
                const_func = RTLIL::const_xor;
            }
            if (0) {
            case Yosys::AST::AST_BIT_XNOR:
                const_func = RTLIL::const_xnor;
            }
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT && ast_node->children[1]->type == Yosys::AST::AST_CONSTANT) {
                RTLIL::Const y = const_func(ast_node->children[0]->bitsAsConst(width_hint, sign_hint),
                                            ast_node->children[1]->bitsAsConst(width_hint, sign_hint), sign_hint, sign_hint, width_hint);
                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, sign_hint);
            }
            break;
            if (0) {
            case Yosys::AST::AST_REDUCE_AND:
                const_func = RTLIL::const_reduce_and;
            }
            if (0) {
            case Yosys::AST::AST_REDUCE_OR:
                const_func = RTLIL::const_reduce_or;
            }
            if (0) {
            case Yosys::AST::AST_REDUCE_XOR:
                const_func = RTLIL::const_reduce_xor;
            }
            if (0) {
            case Yosys::AST::AST_REDUCE_XNOR:
                const_func = RTLIL::const_reduce_xnor;
            }
            if (0) {
            case Yosys::AST::AST_REDUCE_BOOL:
                const_func = RTLIL::const_reduce_bool;
            }
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT) {
                RTLIL::Const y = const_func(RTLIL::Const(ast_node->children[0]->bits), dummy_arg, false, false, -1);
                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, false);
            }
            break;
        case Yosys::AST::AST_LOGIC_NOT:
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT) {
                RTLIL::Const y =
                  RTLIL::const_logic_not(RTLIL::Const(ast_node->children[0]->bits), dummy_arg, ast_node->children[0]->is_signed, false, -1);
                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, false);
            } else if (ast_node->children[0]->isConst()) {
                newNode = Yosys::AST::AstNode::mkconst_int(ast_node->children[0]->asReal(sign_hint) == 0, false, 1);
            }
            break;
            if (0) {
            case Yosys::AST::AST_LOGIC_AND:
                const_func = RTLIL::const_logic_and;
            }
            if (0) {
            case Yosys::AST::AST_LOGIC_OR:
                const_func = RTLIL::const_logic_or;
            }
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT && ast_node->children[1]->type == Yosys::AST::AST_CONSTANT) {
                RTLIL::Const y = const_func(RTLIL::Const(ast_node->children[0]->bits), RTLIL::Const(ast_node->children[1]->bits),
                                            ast_node->children[0]->is_signed, ast_node->children[1]->is_signed, -1);
                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, false);
            } else if (ast_node->children[0]->isConst() && ast_node->children[1]->isConst()) {
                if (ast_node->type == Yosys::AST::AST_LOGIC_AND)
                    newNode = Yosys::AST::AstNode::mkconst_int(
                      (ast_node->children[0]->asReal(sign_hint) != 0) && (ast_node->children[1]->asReal(sign_hint) != 0), false, 1);
                else
                    newNode = Yosys::AST::AstNode::mkconst_int(
                      (ast_node->children[0]->asReal(sign_hint) != 0) || (ast_node->children[1]->asReal(sign_hint) != 0), false, 1);
            }
            break;
            if (0) {
            case Yosys::AST::AST_SHIFT_LEFT:
                const_func = RTLIL::const_shl;
            }
            if (0) {
            case Yosys::AST::AST_SHIFT_RIGHT:
                const_func = RTLIL::const_shr;
            }
            if (0) {
            case Yosys::AST::AST_SHIFT_SLEFT:
                const_func = RTLIL::const_sshl;
            }
            if (0) {
            case Yosys::AST::AST_SHIFT_SRIGHT:
                const_func = RTLIL::const_sshr;
            }
            if (0) {
            case Yosys::AST::AST_POW:
                const_func = RTLIL::const_pow;
            }
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT && ast_node->children[1]->type == Yosys::AST::AST_CONSTANT) {
                RTLIL::Const y = const_func(ast_node->children[0]->bitsAsConst(width_hint, sign_hint), RTLIL::Const(ast_node->children[1]->bits),
                                            sign_hint, ast_node->type == Yosys::AST::AST_POW ? ast_node->children[1]->is_signed : false, width_hint);
                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, sign_hint);
            } else if (ast_node->type == Yosys::AST::AST_POW && ast_node->children[0]->isConst() && ast_node->children[1]->isConst()) {
                newNode = new Yosys::AST::AstNode(Yosys::AST::AST_REALVALUE);
                newNode->realvalue = pow(ast_node->children[0]->asReal(sign_hint), ast_node->children[1]->asReal(sign_hint));
            }
            break;
            if (0) {
            case Yosys::AST::AST_LT:
                const_func = RTLIL::const_lt;
            }
            if (0) {
            case Yosys::AST::AST_LE:
                const_func = RTLIL::const_le;
            }
            if (0) {
            case Yosys::AST::AST_EQ:
                const_func = RTLIL::const_eq;
            }
            if (0) {
            case Yosys::AST::AST_NE:
                const_func = RTLIL::const_ne;
            }
            if (0) {
            case Yosys::AST::AST_EQX:
                const_func = RTLIL::const_eqx;
            }
            if (0) {
            case Yosys::AST::AST_NEX:
                const_func = RTLIL::const_nex;
            }
            if (0) {
            case Yosys::AST::AST_GE:
                const_func = RTLIL::const_ge;
            }
            if (0) {
            case Yosys::AST::AST_GT:
                const_func = RTLIL::const_gt;
            }
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT && ast_node->children[1]->type == Yosys::AST::AST_CONSTANT) {
                int cmp_width = max(ast_node->children[0]->bits.size(), ast_node->children[1]->bits.size());
                bool cmp_signed = ast_node->children[0]->is_signed && ast_node->children[1]->is_signed;
                RTLIL::Const y = const_func(ast_node->children[0]->bitsAsConst(cmp_width, cmp_signed),
                                            ast_node->children[1]->bitsAsConst(cmp_width, cmp_signed), cmp_signed, cmp_signed, 1);
                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, false);
            } else if (ast_node->children[0]->isConst() && ast_node->children[1]->isConst()) {
                bool cmp_signed = (ast_node->children[0]->type == Yosys::AST::AST_REALVALUE || ast_node->children[0]->is_signed) &&
                                  (ast_node->children[1]->type == Yosys::AST::AST_REALVALUE || ast_node->children[1]->is_signed);
                switch (ast_node->type) {
                case Yosys::AST::AST_LT:
                    newNode = Yosys::AST::AstNode::mkconst_int(ast_node->children[0]->asReal(cmp_signed) < ast_node->children[1]->asReal(cmp_signed),
                                                               false, 1);
                    break;
                case Yosys::AST::AST_LE:
                    newNode = Yosys::AST::AstNode::mkconst_int(ast_node->children[0]->asReal(cmp_signed) <= ast_node->children[1]->asReal(cmp_signed),
                                                               false, 1);
                    break;
                case Yosys::AST::AST_EQ:
                    newNode = Yosys::AST::AstNode::mkconst_int(ast_node->children[0]->asReal(cmp_signed) == ast_node->children[1]->asReal(cmp_signed),
                                                               false, 1);
                    break;
                case Yosys::AST::AST_NE:
                    newNode = Yosys::AST::AstNode::mkconst_int(ast_node->children[0]->asReal(cmp_signed) != ast_node->children[1]->asReal(cmp_signed),
                                                               false, 1);
                    break;
                case Yosys::AST::AST_EQX:
                    newNode = Yosys::AST::AstNode::mkconst_int(ast_node->children[0]->asReal(cmp_signed) == ast_node->children[1]->asReal(cmp_signed),
                                                               false, 1);
                    break;
                case Yosys::AST::AST_NEX:
                    newNode = Yosys::AST::AstNode::mkconst_int(ast_node->children[0]->asReal(cmp_signed) != ast_node->children[1]->asReal(cmp_signed),
                                                               false, 1);
                    break;
                case Yosys::AST::AST_GE:
                    newNode = Yosys::AST::AstNode::mkconst_int(ast_node->children[0]->asReal(cmp_signed) >= ast_node->children[1]->asReal(cmp_signed),
                                                               false, 1);
                    break;
                case Yosys::AST::AST_GT:
                    newNode = Yosys::AST::AstNode::mkconst_int(ast_node->children[0]->asReal(cmp_signed) > ast_node->children[1]->asReal(cmp_signed),
                                                               false, 1);
                    break;
                default:
                    log_abort();
                }
            }
            break;
            if (0) {
            case Yosys::AST::AST_ADD:
                const_func = RTLIL::const_add;
            }
            if (0) {
            case Yosys::AST::AST_SUB:
                const_func = RTLIL::const_sub;
            }
            if (0) {
            case Yosys::AST::AST_MUL:
                const_func = RTLIL::const_mul;
            }
            if (0) {
            case Yosys::AST::AST_DIV:
                const_func = RTLIL::const_div;
            }
            if (0) {
            case Yosys::AST::AST_MOD:
                const_func = RTLIL::const_mod;
            }
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT && ast_node->children[1]->type == Yosys::AST::AST_CONSTANT) {
                RTLIL::Const y = const_func(ast_node->children[0]->bitsAsConst(width_hint, sign_hint),
                                            ast_node->children[1]->bitsAsConst(width_hint, sign_hint), sign_hint, sign_hint, width_hint);
                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, sign_hint);
            } else if (ast_node->children[0]->isConst() && ast_node->children[1]->isConst()) {
                newNode = new Yosys::AST::AstNode(Yosys::AST::AST_REALVALUE);
                switch (ast_node->type) {
                case Yosys::AST::AST_ADD:
                    newNode->realvalue = ast_node->children[0]->asReal(sign_hint) + ast_node->children[1]->asReal(sign_hint);
                    break;
                case Yosys::AST::AST_SUB:
                    newNode->realvalue = ast_node->children[0]->asReal(sign_hint) - ast_node->children[1]->asReal(sign_hint);
                    break;
                case Yosys::AST::AST_MUL:
                    newNode->realvalue = ast_node->children[0]->asReal(sign_hint) * ast_node->children[1]->asReal(sign_hint);
                    break;
                case Yosys::AST::AST_DIV:
                    newNode->realvalue = ast_node->children[0]->asReal(sign_hint) / ast_node->children[1]->asReal(sign_hint);
                    break;
                case Yosys::AST::AST_MOD:
                    newNode->realvalue = fmod(ast_node->children[0]->asReal(sign_hint), ast_node->children[1]->asReal(sign_hint));
                    break;
                default:
                    log_abort();
                }
            }
            break;
            if (0) {
            case Yosys::AST::AST_SELFSZ:
                const_func = RTLIL::const_pos;
            }
            if (0) {
            case Yosys::AST::AST_POS:
                const_func = RTLIL::const_pos;
            }
            if (0) {
            case Yosys::AST::AST_NEG:
                const_func = RTLIL::const_neg;
            }
            if (ast_node->children[0]->type == Yosys::AST::AST_CONSTANT) {
                RTLIL::Const y = const_func(ast_node->children[0]->bitsAsConst(width_hint, sign_hint), dummy_arg, sign_hint, false, width_hint);
                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, sign_hint);
            } else if (ast_node->children[0]->isConst()) {
                newNode = new Yosys::AST::AstNode(Yosys::AST::AST_REALVALUE);
                if (ast_node->type == Yosys::AST::AST_NEG)
                    newNode->realvalue = -ast_node->children[0]->asReal(sign_hint);
                else
                    newNode->realvalue = +ast_node->children[0]->asReal(sign_hint);
            }
            break;
        case Yosys::AST::AST_TERNARY:
            if (ast_node->children[0]->isConst()) {
                auto pair = ast_node->get_tern_choice();
                Yosys::AST::AstNode *choice = pair.first;
                Yosys::AST::AstNode *not_choice = pair.second;

                if (choice != NULL) {
                    if (choice->type == Yosys::AST::AST_CONSTANT) {
                        int other_width_hint = width_hint;
                        bool other_sign_hint = sign_hint, other_real = false;
                        not_choice->detectSignWidth(other_width_hint, other_sign_hint, &other_real);
                        if (other_real) {
                            newNode = new Yosys::AST::AstNode(Yosys::AST::AST_REALVALUE);
                            choice->detectSignWidth(width_hint, sign_hint);
                            newNode->realvalue = choice->asReal(sign_hint);
                        } else {
                            RTLIL::Const y = choice->bitsAsConst(width_hint, sign_hint);
                            if (choice->is_string && y.bits.size() % 8 == 0 && sign_hint == false)
                                newNode = Yosys::AST::AstNode::mkconst_str(y.bits);
                            else
                                newNode = Yosys::AST::AstNode::mkconst_bits(y.bits, sign_hint);
                        }
                    } else if (choice->isConst()) {
                        newNode = choice->clone();
                    }
                } else if (ast_node->children[1]->type == Yosys::AST::AST_CONSTANT && ast_node->children[2]->type == Yosys::AST::AST_CONSTANT) {
                    RTLIL::Const a = ast_node->children[1]->bitsAsConst(width_hint, sign_hint);
                    RTLIL::Const b = ast_node->children[2]->bitsAsConst(width_hint, sign_hint);
                    log_assert(a.bits.size() == b.bits.size());
                    for (size_t i = 0; i < a.bits.size(); i++)
                        if (a.bits[i] != b.bits[i])
                            a.bits[i] = RTLIL::State::Sx;
                    newNode = Yosys::AST::AstNode::mkconst_bits(a.bits, sign_hint);
                } else if (ast_node->children[1]->isConst() && ast_node->children[2]->isConst()) {
                    newNode = new Yosys::AST::AstNode(Yosys::AST::AST_REALVALUE);
                    if (ast_node->children[1]->asReal(sign_hint) == ast_node->children[2]->asReal(sign_hint))
                        newNode->realvalue = ast_node->children[1]->asReal(sign_hint);
                    else
                        // IEEE Std 1800-2012 Sec. 11.4.11 states that the entry in Table 7-1 for
                        // the data type in question should be returned if the ?: is ambiguous. The
                        // value in Table 7-1 for the 'real' type is 0.0.
                        newNode->realvalue = 0.0;
                }
            }
            break;
        case Yosys::AST::AST_CAST_SIZE:
            if (ast_node->children.at(0)->type == Yosys::AST::AST_CONSTANT && ast_node->children.at(1)->type == Yosys::AST::AST_CONSTANT) {
                int width = ast_node->children[0]->bitsAsConst().as_int();
                RTLIL::Const val;
                if (ast_node->children[1]->is_unsized)
                    val = ast_node->children[1]->bitsAsUnsizedConst(width);
                else
                    val = ast_node->children[1]->bitsAsConst(width);
                newNode = Yosys::AST::AstNode::mkconst_bits(val.bits, ast_node->children[1]->is_signed);
            }
            break;
        case Yosys::AST::AST_CONCAT:
            string_op = !ast_node->children.empty();
            for (auto it = ast_node->children.begin(); it != ast_node->children.end(); it++) {
                if ((*it)->type != Yosys::AST::AST_CONSTANT)
                    goto not_const;
                if (!(*it)->is_string)
                    string_op = false;
                tmp_bits.insert(tmp_bits.end(), (*it)->bits.begin(), (*it)->bits.end());
            }
            newNode = string_op ? Yosys::AST::AstNode::mkconst_str(tmp_bits) : Yosys::AST::AstNode::mkconst_bits(tmp_bits, false);
            break;
        case Yosys::AST::AST_REPLICATE:
            if (ast_node->children.at(0)->type != Yosys::AST::AST_CONSTANT || ast_node->children.at(1)->type != Yosys::AST::AST_CONSTANT)
                goto not_const;
            for (int i = 0; i < ast_node->children[0]->bitsAsConst().as_int(); i++)
                tmp_bits.insert(tmp_bits.end(), ast_node->children.at(1)->bits.begin(), ast_node->children.at(1)->bits.end());
            newNode =
              ast_node->children.at(1)->is_string ? Yosys::AST::AstNode::mkconst_str(tmp_bits) : Yosys::AST::AstNode::mkconst_bits(tmp_bits, false);
            break;
        default:
        not_const:
            break;
        }
    }

    // if any of the above set 'newNode' -> use 'newNode' as template to update 'ast_node'
    if (newNode) {
    apply_newNode:
        // fprintf(stderr, "----\n");
        // dumpAst(stderr, "- ");
        // newNode->dumpAst(stderr, "+ ");
        log_assert(newNode != NULL);
        newNode->filename = ast_node->filename;
        newNode->location = ast_node->location;
        newNode->cloneInto(ast_node);
        delete newNode;
        did_something = true;
    }

    if (!did_something)
        ast_node->basic_prep = true;

    recursion_counter--;
    return did_something;
}

} // namespace systemverilog_plugin
