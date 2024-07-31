#include <algorithm>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <iostream>
#include <limits>
#include <regex>
#include <string>
#include <utility>
#include <vector>

#include "frontends/ast/ast.h"
#include "libs/sha1/sha1.h"
#include "uhdm_ast.h"

#include "utils/memory.h"

// UHDM
#include <uhdm/ExprEval.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_user.h>

#include "synlig_const2ast.h"
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

namespace AST
{
using namespace ::Yosys::AST;

namespace Extended
{
enum AstNodeTypeExtended {
    AST_DOT = ::Yosys::AST::AST_BIND + 1, // here we always want to point to the last element of yosys' AstNodeType
    AST_BREAK,
    AST_CONTINUE
};
}
} // namespace AST

namespace attr_id
{
static bool already_initialized = false;
static IdString partial;
static IdString packed_ranges;
static IdString unpacked_ranges;
static IdString force_convert;
static IdString is_imported;
static IdString is_simplified_wire;
static IdString low_high_bound;
static IdString is_type_parameter;
static IdString is_elaborated_module;
}; // namespace attr_id

// TODO(mglb): use attr_id::* directly everywhere and remove those methods.
/*static*/ const IdString &UhdmAst::partial() { return attr_id::partial; }
/*static*/ const IdString &UhdmAst::packed_ranges() { return attr_id::packed_ranges; }
/*static*/ const IdString &UhdmAst::unpacked_ranges() { return attr_id::unpacked_ranges; }
/*static*/ const IdString &UhdmAst::force_convert() { return attr_id::force_convert; }
/*static*/ const IdString &UhdmAst::is_imported() { return attr_id::is_imported; }
/*static*/ const IdString &UhdmAst::is_simplified_wire() { return attr_id::is_simplified_wire; }
/*static*/ const IdString &UhdmAst::low_high_bound() { return attr_id::low_high_bound; }
/*static*/ const IdString &UhdmAst::is_elaborated_module() { return attr_id::is_elaborated_module; }

#define MAKE_INTERNAL_ID(X) IdString("$systemverilog_plugin$" #X)

void attr_id_init()
{
    // Initialize only once
    if (attr_id::already_initialized)
        return;
    attr_id::already_initialized = true;

    // Actual initialization

    // Register IdStrings. Can't be done statically, as the IdString class uses resources created during Yosys initialization which happens after
    // static initialization of the plugin when everything is statically linked.
    attr_id::partial = MAKE_INTERNAL_ID(partial);
    attr_id::packed_ranges = MAKE_INTERNAL_ID(packed_ranges);
    attr_id::unpacked_ranges = MAKE_INTERNAL_ID(unpacked_ranges);
    attr_id::force_convert = MAKE_INTERNAL_ID(force_convert);
    attr_id::is_imported = MAKE_INTERNAL_ID(is_imported);
    attr_id::is_simplified_wire = MAKE_INTERNAL_ID(is_simplified_wire);
    attr_id::low_high_bound = MAKE_INTERNAL_ID(low_high_bound);
    attr_id::is_type_parameter = MAKE_INTERNAL_ID(is_type_parameter);
    attr_id::is_elaborated_module = MAKE_INTERNAL_ID(is_elaborated_module);
}

void attr_id_cleanup()
{
    // Release static copies of private IdStrings.
    attr_id::low_high_bound = IdString();
    attr_id::is_simplified_wire = IdString();
    attr_id::is_imported = IdString();
    attr_id::force_convert = IdString();
    attr_id::unpacked_ranges = IdString();
    attr_id::packed_ranges = IdString();
    attr_id::partial = IdString();
    attr_id::is_type_parameter = IdString();
    attr_id::is_elaborated_module = IdString();
    attr_id::already_initialized = false;
}

static AST::AstNode *get_attribute(AST::AstNode *node, const IdString &attribute)
{
    log_assert(node);
    if (!node->attributes.count(attribute))
        return nullptr;

    return node->attributes[attribute];
}

// Consumes attr_node.
static void set_attribute(AST::AstNode *node, const IdString &attribute, AST::AstNode *attr_node)
{
    log_assert(node);
    log_assert(attr_node);
    delete node->attributes[attribute];
    node->attributes[attribute] = attr_node;
}

// Delete the selected attribute if it exists.
// Does nothing if the node doesn't exist, or the attribute doesn't exists.
static void delete_attribute(AST::AstNode *node, const IdString &attribute)
{
    if (!node)
        return;

    if (node->attributes.count(attribute)) {
        delete node->attributes[attribute];
        node->attributes.erase(attribute);
    }
}

// Delete all attributes that belong to the SV plugin.
// The attributes beloning to Yosys are *not* deleted here.
static void delete_internal_attributes(AST::AstNode *node)
{
    if (!node)
        return;

    for (auto &attr : {UhdmAst::partial(), UhdmAst::packed_ranges(), UhdmAst::unpacked_ranges(), UhdmAst::force_convert(), UhdmAst::is_imported(),
                       UhdmAst::is_simplified_wire(), UhdmAst::low_high_bound(), attr_id::is_type_parameter, attr_id::is_elaborated_module}) {
        delete_attribute(node, attr);
    }
}

template <typename T> class ScopedValueChanger
{
    T &ref;
    const T prev_val;

  public:
    ScopedValueChanger() = delete;

    explicit ScopedValueChanger(T &r) : ref(r), prev_val(ref) {}

    ScopedValueChanger(T &r, const T &val) : ref(r), prev_val(ref) { ref = val; }

    ScopedValueChanger(ScopedValueChanger &&) = delete;
    ScopedValueChanger &operator=(ScopedValueChanger &&) = delete;

    ScopedValueChanger(const ScopedValueChanger &) = delete;
    ScopedValueChanger &operator=(const ScopedValueChanger &) = delete;

    ~ScopedValueChanger() { ref = prev_val; }
};

template <typename T> ScopedValueChanger(T &) -> ScopedValueChanger<T>;

template <typename T> ScopedValueChanger(T &, const T &) -> ScopedValueChanger<T>;

// Delete all children nodes.
// Does *not* delete attributes.
// This function exists as Yosys's function node->delete_children() does remove all children and attributes.
static void delete_children(AST::AstNode *node)
{
    if (!node)
        return;

    for (auto *child : node->children) {
        delete child;
    }
    node->children.clear();
}

static std::vector<AST::AstNode *> get_ranges(AST::AstNode *id)
{
    log_assert(!id->children.empty());
    std::vector<AST::AstNode *> ranges;
    for (auto c : id->children) {
        if (c->type == AST::AST_RANGE) {
            ranges.push_back(c);
        }
    }
    return ranges;
}

static std::vector<AST::AstNode *> get_all_ranges(AST::AstNode *id)
{
    log_assert(!id->children.empty());
    std::vector<AST::AstNode *> ranges;
    for (auto c : id->children) {
        if (c->type == AST::AST_RANGE) {
            ranges.push_back(c);
        }
        for (auto pair : c->attributes) {
            if (pair.second && !pair.second->children.empty()) {
                for (auto r : get_all_ranges(pair.second)) {
                    ranges.push_back(r);
                }
            }
        }
    }
    return ranges;
}

static void simplify_sv(AST::AstNode *current_node, AST::AstNode *parent_node);

static void sanitize_symbol_name(std::string &name)
{
    if (!name.empty()) {
        auto pos = name.find_last_of('@');
        name = name.substr(pos + 1);
        // symbol names must begin with '\'
        name.insert(0, "\\");
    }
}

static std::string get_object_name(vpiHandle obj_h, const std::vector<int> &name_fields = {vpiName})
{
    std::string objectName;
    for (auto name : name_fields) {
        if (auto s = vpi_get_str(name, obj_h)) {
            objectName = s;
            sanitize_symbol_name(objectName);
            break;
        }
    }
    return objectName;
}

static std::string get_name(vpiHandle obj_h) { return get_object_name(obj_h, {vpiName, vpiDefName}); }

static std::string strip_package_name(std::string name)
{
    auto sep_index = name.find("::");
    if (sep_index != string::npos) {
        name = name.substr(sep_index + 1);
        name[0] = '\\';
    }
    return name;
}

static AST::AstNode *mkconst_real(double d)
{
    AST::AstNode *node = new AST::AstNode(AST::AST_REALVALUE);
    node->realvalue = d;
    return node;
}

static AST::AstNode *make_range(int left, int right, bool is_signed = false)
{
    // generate a pre-validated range node for a fixed signal range.
    auto range = new AST::AstNode(AST::AST_RANGE);
    range->range_left = left;
    range->range_right = right;
    range->range_valid = true;
    range->children.push_back(AST::AstNode::mkconst_int(left, true));
    range->children.push_back(AST::AstNode::mkconst_int(right, true));
    range->is_signed = is_signed;
    return range;
}

static void copy_packed_unpacked_attribute(AST::AstNode *from, AST::AstNode *to)
{
    if (!to->attributes.count(UhdmAst::packed_ranges()))
        to->attributes[UhdmAst::packed_ranges()] = AST::AstNode::mkconst_int(1, false, 1);
    if (!to->attributes.count(UhdmAst::unpacked_ranges()))
        to->attributes[UhdmAst::unpacked_ranges()] = AST::AstNode::mkconst_int(1, false, 1);
    if (from->attributes.count(UhdmAst::packed_ranges())) {
        for (auto r : from->attributes[UhdmAst::packed_ranges()]->children) {
            to->attributes[UhdmAst::packed_ranges()]->children.push_back(r->clone());
        }
    }
    if (from->attributes.count(UhdmAst::unpacked_ranges())) {
        for (auto r : from->attributes[UhdmAst::unpacked_ranges()]->children) {
            to->attributes[UhdmAst::unpacked_ranges()]->children.push_back(r->clone());
        }
    }
}

static int get_max_offset_struct(AST::AstNode *node)
{
    // get the width from the MS member in the struct
    // as members are laid out from left to right in the packed wire
    log_assert(node->type == AST::AST_STRUCT || node->type == AST::AST_UNION);
    while (node->range_left < 0) {
        node = node->children[0];
    }
    return node->range_left;
}

static void visitEachDescendant(AST::AstNode *node, const std::function<void(AST::AstNode *)> &f)
{
    for (auto child : node->children) {
        f(child);
        visitEachDescendant(child, f);
    }
}

static void add_multirange_wire(AST::AstNode *node, std::vector<AST::AstNode *> packed_ranges, std::vector<AST::AstNode *> unpacked_ranges)
{
    delete_attribute(node, UhdmAst::packed_ranges());
    node->attributes[UhdmAst::packed_ranges()] = AST::AstNode::mkconst_int(1, false, 1);
    if (!packed_ranges.empty()) {
        node->attributes[UhdmAst::packed_ranges()]->children = std::move(packed_ranges);
    }

    delete_attribute(node, UhdmAst::unpacked_ranges());
    node->attributes[UhdmAst::unpacked_ranges()] = AST::AstNode::mkconst_int(1, false, 1);
    if (!unpacked_ranges.empty()) {
        node->attributes[UhdmAst::unpacked_ranges()]->children = std::move(unpacked_ranges);
    }
}

// Sets the `wire_node->multirange_dimensions` attribute and returns the total sizes of packed and unpacked ranges.
static std::pair<size_t, size_t> set_multirange_dimensions(AST::AstNode *wire_node, const std::vector<AST::AstNode *> packed_ranges,
                                                           const std::vector<AST::AstNode *> unpacked_ranges)
{
    // node->multirange_dimensions stores dimensions' offsets and widths.
    // It shall have even number of elements.
    // For a range of [A:B] it should be appended with {min(A,B)} and {max(A,B)-min(A,B)+1}
    // For a range of [A] it should be appended with {0} and {A}

    auto calc_range_size = [wire_node](const std::vector<AST::AstNode *> &ranges) -> size_t {
        size_t size = 1;
        for (size_t i = 0; i < ranges.size(); i++) {
            log_assert(AST_INTERNAL::current_ast_mod);
            simplify_sv(ranges[i], wire_node);
            // If it's a range of [A], make it [A:A].
            if (ranges[i]->children.size() == 1) {
                ranges[i]->children.push_back(ranges[i]->children[0]->clone());
            }
            while (simplify(ranges[i], true, false, false, 1, -1, false, false)) {
            }
            // this workaround case, where yosys doesn't follow id2ast and simplifies it to resolve constant
            if (ranges[i]->children[0]->id2ast) {
                simplify_sv(ranges[i]->children[0]->id2ast, ranges[i]->children[0]);
                while (simplify(ranges[i]->children[0]->id2ast, true, false, false, 1, -1, false, false)) {
                }
            }
            if (ranges[i]->children[1]->id2ast) {
                simplify_sv(ranges[i]->children[1]->id2ast, ranges[i]->children[1]);
                while (simplify(ranges[i]->children[1]->id2ast, true, false, false, 1, -1, false, false)) {
                }
            }
            simplify_sv(ranges[i], wire_node);
            while (simplify(ranges[i], true, false, false, 1, -1, false, false)) {
            }
            log_assert(ranges[i]->children[0]->type == AST::AST_CONSTANT);
            log_assert(ranges[i]->children[1]->type == AST::AST_CONSTANT);

            const auto low = min(ranges[i]->children[0]->integer, ranges[i]->children[1]->integer);
            const auto high = max(ranges[i]->children[0]->integer, ranges[i]->children[1]->integer);
            const auto elem_size = high - low + 1;

            wire_node->multirange_dimensions.push_back(low);
            wire_node->multirange_dimensions.push_back(elem_size);
            wire_node->multirange_swapped.push_back(ranges[i]->range_swapped);
            size *= elem_size;
        }
        return size;
    };
    size_t packed_size = calc_range_size(packed_ranges);
    size_t unpacked_size = calc_range_size(unpacked_ranges);
    log_assert(wire_node->multirange_dimensions.size() % 2 == 0);
    return {packed_size, unpacked_size};
}

static AST::AstNode *convert_range(AST::AstNode *id, int packed_ranges_size, int unpacked_ranges_size, int index)
{
    log_assert(AST_INTERNAL::current_ast_mod);
    log_assert(AST_INTERNAL::current_scope.count(id->str));
    AST::AstNode *wire_node = AST_INTERNAL::current_scope[id->str];
    log_assert(!wire_node->multirange_dimensions.empty());
    std::vector<AST::AstNode *> ranges = get_ranges(id);
    // Order of ranges evaluation (IEEE 7.4.5):
    // logic [A:B][C:D] wire [E:F][G:H];
    //         |    |          |    |
    //         3    4          1    2
    // create vector containing size of single element for given range in evaluation order:
    // [wire_size/(max(E, F) - min(E, F) + 1), (wire_size/(max(E, F) - min(E, F) + 1)) / (max(G, H) - min(G, H) - 1)...]
    std::vector<int> single_elem_size;
    const std::vector<AST::AstNode *> &unpacked_ranges = wire_node->attributes[UhdmAst::unpacked_ranges()]->children;
    const std::vector<AST::AstNode *> &packed_ranges = wire_node->attributes[UhdmAst::packed_ranges()]->children;
    // TODO(krak): maybe there is better way to get size of whole wire?
    log_assert(!wire_node->children.empty());
    int elem_size = wire_node->children[0]->range_left + 1;
    // multirange_dimensions also contains ranges from wiretype, but
    // they should be handled after packed ranges,
    // this is primitive way of calculating how many packed ranges is from wiretype
    // TODO(krak): this is good candidate for refactor
    size_t skip = 0;
    if (wire_node->attributes.count(ID::wiretype)) {
        AST::AstNode *wiretype_node = wire_node->attributes[ID::wiretype]->id2ast;
        if (wiretype_node->type == AST::AST_STRUCT) {
            skip = 1;
        } else if (wiretype_node->type == AST::AST_WIRE) {
            // skip number of dimensions of the object - number of dimensions of the var select
            skip = (wire_node->multirange_dimensions.size() / 2) - id->children.size();
        } else {
            wiretype_node->dumpAst(NULL, "wiretype >");
            log_error("Unhandled case in multirange wiretype!");
        }
    }
    for (auto range = unpacked_ranges.begin(); range != unpacked_ranges.end(); range++) {
        auto range_node = *range;
        // add_multirange_attribute should already make sure there are 2 children nodes in range and they are consts
        const auto low = min(range_node->children[0]->integer, range_node->children[1]->integer);
        const auto high = max(range_node->children[0]->integer, range_node->children[1]->integer);
        elem_size /= high - low + 1;
        single_elem_size.push_back(elem_size);
    }
    for (auto range = packed_ranges.begin() + skip; range != packed_ranges.end(); range++) {
        auto range_node = *range;
        // 'add_multirange_attribute' function should already make sure there are 2 children nodes in range and they are consts
        const auto low = min(range_node->children[0]->integer, range_node->children[1]->integer);
        const auto high = max(range_node->children[0]->integer, range_node->children[1]->integer);
        elem_size /= high - low + 1;
        single_elem_size.push_back(elem_size);
    }
    if (single_elem_size.empty()) {
        // TODO(krak): this needs better support
        // only wiretype ranges
        return make_range(elem_size - 1, 0);
    }
    // Same as above but, for offset
    // start from unpacked ranges
    // TODO(krak): we could also calculate offset while calculating elem_size, good place for refactor
    std::vector<int> range_offset;
    for (auto i = packed_ranges.size(); i < packed_ranges.size() + unpacked_ranges.size(); i++) {
        range_offset.push_back(wire_node->multirange_dimensions[i * 2]);
    }
    // then packed
    for (auto i = skip; i < packed_ranges.size(); i++) {
        range_offset.push_back(wire_node->multirange_dimensions[i * 2]);
    }
    const auto make_node = [](AST::AstNodeType type) {
        auto node = std::make_unique<AST::AstNode>(type);
        return AstNodeBuilder(std::move(node));
    };
    const auto make_const = [make_node](uint32_t value, uint8_t width) {
        log_assert(width <= 32);
        return make_node(AST::AST_CONSTANT).value(value, false, width);
    };
    AST::AstNode *result = nullptr;
    AST::AstNode *range_left = nullptr;
    AST::AstNode *range_right = nullptr;
    for (size_t i = 0; i < ranges.size(); i++) {
        if (i + 1 == ranges.size()) {
            // last range can have 2 children
            log_assert(ranges[i]->children.size() > 0 && ranges[i]->children.size() < 3);
            if (ranges[i]->children.size() == 2) {
                range_left = ranges[i]->children[0]->clone();
                range_right = ranges[i]->children[1]->clone();
            } else {
                range_left = ranges[i]->children[0]->clone();
                range_right = ranges[i]->children[0]->clone();
            }
        } else {
            // other ranges needs to have single child
            log_assert(ranges[i]->children.size() == 1);
            range_left = ranges[i]->children[0]->clone();
            range_right = ranges[i]->children[0]->clone();
        }
        if ((i < range_offset.size()) && (range_offset[i] != 0)) {
            range_left = make_node(AST::AST_SUB)({range_left, make_const(range_offset[i], 32)});
            range_right = make_node(AST::AST_SUB)({range_right, make_const(range_offset[i], 32)});
        }
        int single_elem_size_val = 1;
        if (i < single_elem_size.size()) {
            single_elem_size_val = single_elem_size[i];
        } else if (!single_elem_size.empty()) {
            single_elem_size_val = single_elem_size[0];
        }
        // range_right = range_right * single_elem_size_val
        // range_left  = (((range_left + 1) * single_elem_size_val) - range_right) - 1
        range_right = make_node(AST::AST_MUL)({range_right, make_const(single_elem_size_val, 32)});
        range_left = make_node(AST::AST_SUB)(
          {make_node(AST::AST_SUB)(
             {make_node(AST::AST_MUL)({make_node(AST::AST_ADD)({range_left, make_const(1, 32)}), make_const(single_elem_size_val, 32)}),
              range_right->clone()}),
           make_const(1, 32)});
        if (result) {
            range_right = make_node(AST::AST_ADD)({result->children[1]->clone(), range_right});

            delete result;
            result = nullptr;
        }
        range_left = make_node(AST::AST_ADD)({range_right->clone(), range_left});
        result = make_node(AST::AST_RANGE)({range_left, range_right});
    }
    id->basic_prep = true;
    return result;
}

static void resolve_wiretype(AST::AstNode *wire_node)
{
    AST::AstNode *wiretype_node = nullptr;
    if (!wire_node->children.empty()) {
        if (wire_node->children[0]->type == AST::AST_WIRETYPE) {
            wiretype_node = wire_node->children[0];
        }
    }
    if (wire_node->children.size() > 1) {
        if (wire_node->children[1]->type == AST::AST_WIRETYPE) {
            wiretype_node = wire_node->children[1];
        }
    }
    if (wiretype_node == nullptr)
        return;

    unique_resource<std::vector<AST::AstNode *>> packed_ranges = wire_node->attributes.count(attr_id::packed_ranges)
                                                                   ? std::move(wire_node->attributes[attr_id::packed_ranges]->children)
                                                                   : std::vector<AST::AstNode *>{};
    delete_attribute(wire_node, attr_id::packed_ranges);
    unique_resource<std::vector<AST::AstNode *>> unpacked_ranges = wire_node->attributes.count(attr_id::unpacked_ranges)
                                                                     ? std::move(wire_node->attributes[attr_id::unpacked_ranges]->children)
                                                                     : std::vector<AST::AstNode *>{};
    delete_attribute(wire_node, attr_id::unpacked_ranges);

    AST::AstNode *wiretype_ast = nullptr;
    log_assert(AST_INTERNAL::current_scope.count(wiretype_node->str));
    wiretype_ast = AST_INTERNAL::current_scope[wiretype_node->str];
    // we need to setup current top ast as this simplify
    // needs to have access to all already defined ids
    simplify_sv(wiretype_ast, nullptr);
    while (simplify(wire_node, true, false, false, 1, -1, false, false)) {
    }
    log_assert(!wiretype_ast->children.empty());
    if ((wiretype_ast->children[0]->type == AST::AST_STRUCT || wiretype_ast->children[0]->type == AST::AST_UNION) &&
        wire_node->type == AST::AST_WIRE) {
        auto struct_width = get_max_offset_struct(wiretype_ast->children[0]);
        wire_node->range_left = struct_width;
        wire_node->children[0]->range_left = struct_width;
        wire_node->children[0]->children[0]->integer = struct_width;
    }
    if (wiretype_ast) {
        log_assert(wire_node->attributes.count(ID::wiretype));
        log_assert(wiretype_ast->type == AST::AST_TYPEDEF);
        wire_node->attributes[ID::wiretype]->id2ast = wiretype_ast->children[0];
    }
    if (((wire_node->children.size() > 0 && wire_node->children[0]->type == AST::AST_RANGE) ||
         (wire_node->children.size() > 1 && wire_node->children[1]->type == AST::AST_RANGE)) &&
        wire_node->multirange_dimensions.empty()) {
        // We need to save order in which ranges appear in wiretype and add them before wire range
        // We need to copy this ranges, so create new vector for them
        std::vector<AST::AstNode *> packed_ranges_wiretype;
        std::vector<AST::AstNode *> unpacked_ranges_wiretype;
        if (wiretype_ast && !wiretype_ast->children.empty() && wiretype_ast->children[0]->attributes.count(UhdmAst::packed_ranges()) &&
            wiretype_ast->children[0]->attributes.count(UhdmAst::unpacked_ranges())) {
            for (auto r : wiretype_ast->children[0]->attributes[UhdmAst::packed_ranges()]->children) {
                packed_ranges_wiretype.push_back(r->clone());
            }
            for (auto r : wiretype_ast->children[0]->attributes[UhdmAst::unpacked_ranges()]->children) {
                unpacked_ranges_wiretype.push_back(r->clone());
            }
        } else {
            if (wire_node->children[0]->type == AST::AST_RANGE)
                packed_ranges_wiretype.push_back(wire_node->children[0]->clone());
            else if (wire_node->children[1]->type == AST::AST_RANGE)
                packed_ranges_wiretype.push_back(wire_node->children[1]->clone());
            else
                log_error("Unhandled case in resolve_wiretype!\n");
        }
        // add wiretype range before current wire ranges
        std::reverse(packed_ranges_wiretype.begin(), packed_ranges_wiretype.end());
        std::reverse(unpacked_ranges_wiretype.begin(), unpacked_ranges_wiretype.end());
        std::reverse(packed_ranges->begin(), packed_ranges->end());
        std::reverse(unpacked_ranges->begin(), unpacked_ranges->end());
        packed_ranges->insert(packed_ranges->begin(), packed_ranges_wiretype.begin(), packed_ranges_wiretype.end());
        unpacked_ranges->insert(unpacked_ranges->begin(), unpacked_ranges_wiretype.begin(), unpacked_ranges_wiretype.end());
        AST::AstNode *value = nullptr;
        if (wire_node->children[0]->type != AST::AST_RANGE) {
            value = wire_node->children[0]->clone();
        }
        delete_children(wire_node);
        if (value)
            wire_node->children.push_back(value);
        add_multirange_wire(wire_node, packed_ranges.release(), unpacked_ranges.release());
    }
}

static void add_force_convert_attribute(AST::AstNode *wire_node, uint32_t val = 1)
{
    AST::AstNode *&attr = wire_node->attributes[UhdmAst::force_convert()];
    if (!attr) {
        attr = AST::AstNode::mkconst_int(val, true);
    } else if (attr->integer != val) {
        attr->integer = val;
    }
}

static void check_memories(AST::AstNode *node, std::string scope, std::map<std::string, AST::AstNode *> &memories)
{
    for (auto *child : node->children) {
        if (child->type == AST::AST_FUNCTION) {
            std::map<std::string, AST::AstNode *> memories_in_scope;
            check_memories(child, node->type == AST::AST_GENBLOCK ? scope + "." + node->str : scope, memories_in_scope);
        } else {
            check_memories(child, node->type == AST::AST_GENBLOCK ? scope + "." + node->str : scope, memories);
        }
    }

    if (node->str == "\\$readmemh") {
        if (node->children.size() != 2 || node->children[1]->str.empty() || node->children[1]->type != AST::AST_IDENTIFIER) {
            log_error("%s:%d: Wrong usage of '\\$readmemh'\n", node->filename.c_str(), node->location.first_line);
        }
        // TODO: Look for the memory in all other scope levels, like we do in case of AST::AST_IDENTIFIER,
        // as here the memory can also be defined before before the current scope.
        std::string name = scope + "." + node->children[1]->str;
        const auto iter = memories.find(name);
        if (iter != memories.end()) {
            add_force_convert_attribute(iter->second, 0);
        }
    }

    if (node->type == AST::AST_WIRE) {
        const std::size_t packed_ranges_count =
          node->attributes.count(UhdmAst::packed_ranges()) ? node->attributes[UhdmAst::packed_ranges()]->children.size() : 0;
        const std::size_t unpacked_ranges_count =
          node->attributes.count(UhdmAst::unpacked_ranges()) ? node->attributes[UhdmAst::unpacked_ranges()]->children.size() : 0;

        if (packed_ranges_count == 1 && unpacked_ranges_count == 1) {
            std::string name = scope + "." + node->str;
            auto [iter, did_insert] = memories.insert_or_assign(std::move(name), node);
            log_assert(did_insert);
        }
        return;
    }

    if (node->type == AST::AST_IDENTIFIER) {
        std::string full_id = scope;
        std::size_t scope_end_pos = scope.size();

        for (;;) {
            full_id += "." + node->str;
            const auto iter = memories.find(full_id);
            if (iter != memories.end()) {
                // Memory node found!
                if (!iter->second->attributes.count(UhdmAst::force_convert())) {
                    const bool is_full_memory_access = (node->children.size() == 0);
                    const bool is_slice_memory_access = (node->children.size() == 1 && node->children[0]->children.size() != 1);
                    // convert memory to list of registers
                    // in case of access to whole memory
                    // or slice of memory
                    // e.g.
                    // logic [3:0] mem [8:0];
                    // always_ff @ (posedge clk) begin
                    //   mem <= '{default:0};
                    //   mem[7:1] <= mem[6:0];
                    // end
                    // don't convert in case of accessing
                    // memory using address, e.g.
                    // mem[0] <= '{default:0}
                    if (is_full_memory_access || is_slice_memory_access) {
                        add_force_convert_attribute(iter->second);
                    }
                }
                break;
            } else {
                if (scope_end_pos == 0) {
                    // We reached the top scope and the memory node wasn't found.
                    break;
                } else {
                    // Memory node wasn't found.
                    // Erase node name and last segment of the scope to check the previous scope.
                    // FIXME: This doesn't work with escaped identifiers containing a dot.
                    scope_end_pos = full_id.find_last_of('.', scope_end_pos - 1);
                    if (scope_end_pos == std::string::npos) {
                        scope_end_pos = 0;
                    }
                    full_id.erase(scope_end_pos);
                }
            }
        }
    }
}

static void check_memories(AST::AstNode *node)
{
    std::map<std::string, AST::AstNode *> memories;
    check_memories(node, "", memories);
}

static void warn_start_range(const std::vector<AST::AstNode *> ranges)
{
    for (size_t i = 0; i < ranges.size(); i++) {
        auto start_elem = min(ranges[i]->children[0]->integer, ranges[i]->children[1]->integer);
        if (start_elem != 0) {
            log_file_warning(ranges[i]->filename, ranges[i]->location.first_line, "Limited support for multirange wires that don't start from 0\n");
        }
    }
}

// This function is workaround missing support for multirange (with n-ranges) packed/unpacked nodes
// It converts multirange node to single-range node and translates access to this node
// to correct range
static void convert_packed_unpacked_range(AST::AstNode *wire_node)
{
    resolve_wiretype(wire_node);
    const std::vector<AST::AstNode *> packed_ranges = wire_node->attributes.count(UhdmAst::packed_ranges())
                                                        ? wire_node->attributes[UhdmAst::packed_ranges()]->children
                                                        : std::vector<AST::AstNode *>();
    const std::vector<AST::AstNode *> unpacked_ranges = wire_node->attributes.count(UhdmAst::unpacked_ranges())
                                                          ? wire_node->attributes[UhdmAst::unpacked_ranges()]->children
                                                          : std::vector<AST::AstNode *>();
    if (packed_ranges.empty() && unpacked_ranges.empty()) {
        delete_attribute(wire_node, UhdmAst::packed_ranges());
        delete_attribute(wire_node, UhdmAst::unpacked_ranges());
        wire_node->range_left = 0;
        wire_node->range_right = 0;
        wire_node->range_valid = true;
        return;
    }
    std::vector<AST::AstNode *> ranges;

    // Convert only when node is not a memory and at least 1 of the ranges has more than 1 range
    const bool convert_node = [&]() {
        if (wire_node->type == AST::AST_MEMORY)
            return false;
        if (packed_ranges.size() > 1)
            return true;
        if (unpacked_ranges.size() > 1)
            return true;
        if (wire_node->attributes.count(ID::wiretype))
            return true;
        if (wire_node->type == AST::AST_PARAMETER)
            return true;
        if (wire_node->type == AST::AST_LOCALPARAM)
            return true;
        if ((wire_node->is_input || wire_node->is_output) && (packed_ranges.size() > 0 || unpacked_ranges.size() > 0))
            return true;
        if (wire_node->attributes.count(UhdmAst::force_convert()) && wire_node->attributes[UhdmAst::force_convert()]->integer == 1)
            return true;
        return false;
    }();
    if (convert_node) {
        // if not already converted
        if (wire_node->multirange_dimensions.empty()) {
            const auto [packed_size, unpacked_size] = set_multirange_dimensions(wire_node, packed_ranges, unpacked_ranges);
            if (packed_ranges.size() == 1 && unpacked_ranges.empty()) {
                ranges.push_back(packed_ranges[0]->clone());
            } else if (unpacked_ranges.size() == 1 && packed_ranges.empty()) {
                ranges.push_back(unpacked_ranges[0]->clone());
            } else {
                // currently we have limited support
                // for multirange wires that doesn't start from 0
                warn_start_range(packed_ranges);
                warn_start_range(unpacked_ranges);
                const size_t size = packed_size * unpacked_size;
                log_assert(size >= 1);
                ranges.push_back(make_range(size - 1, 0));
            }
        }
    } else {
        for (auto r : packed_ranges) {
            ranges.push_back(r->clone());
        }
        for (auto r : unpacked_ranges) {
            ranges.push_back(r->clone());
        }
        // if there is only one packed and one unpacked range,
        // and wire is not port wire, change type to AST_MEMORY
        if (wire_node->type == AST::AST_WIRE && packed_ranges.size() == 1 && unpacked_ranges.size() == 1 && !wire_node->is_input &&
            !wire_node->is_output) {
            wire_node->type = AST::AST_MEMORY;
            wire_node->is_logic = true;
        }
    }

    // Insert new range
    wire_node->children.insert(wire_node->children.end(), ranges.begin(), ranges.end());
}

// Assert macro that prints location in C++ code and location of currently processed UHDM object.
// Use only inside UhdmAst methods.
#ifndef NDEBUG
#if __GNUC__
// gcc/clang's __builtin_trap() makes gdb stop on the line containing an assertion.
#define uhdmast_assert(expr)                                                                                                                         \
    if ((expr)) {                                                                                                                                    \
    } else {                                                                                                                                         \
        this->uhdmast_assert_log(#expr, __PRETTY_FUNCTION__, __FILE__, __LINE__);                                                                    \
        __builtin_trap();                                                                                                                            \
    }
#else // #if __GNUC__
// Just abort when using compiler other than gcc/clang.
#define uhdmast_assert(expr)                                                                                                                         \
    if ((expr)) {                                                                                                                                    \
    } else {                                                                                                                                         \
        this->uhdmast_assert_log(#expr, __func__, __FILE__, __LINE__);                                                                               \
        std::abort();                                                                                                                                \
    }
#endif // #if __GNUC__
#else  // #ifndef NDEBUG
#define uhdmast_assert(expr)                                                                                                                         \
    if ((expr)) {                                                                                                                                    \
    } else {                                                                                                                                         \
    }
#endif // #ifndef NDEBUG

void UhdmAst::uhdmast_assert_log(const char *expr_str, const char *func, const char *file, int line) const
{
    std::cerr << file << ':' << line << ": error: Assertion failed: " << expr_str << std::endl;
    std::cerr << file << ':' << line << ": note: In function: " << func << std::endl;
    if (obj_h != 0) {
        const char *const svfile = vpi_get_str(vpiFile, obj_h);
        int svline = vpi_get(vpiLineNo, obj_h);
        int svcolumn = vpi_get(vpiColumnNo, obj_h);
        std::string obj_type_name = UHDM::VpiTypeName(obj_h);
        const char *obj_name = vpi_get_str(vpiName, obj_h);
        std::cerr << svfile << ':' << svline << ':' << svcolumn << ": note: When processing object of type '" << obj_type_name << '\'';
        if (obj_name && obj_name[0] != '\0') {
            std::cerr << " named '" << obj_name << '\'';
        }
        std::cerr << '.' << std::endl;
    }
}

static AST::AstNode *expand_dot(const AST::AstNode *current_struct, const AST::AstNode *search_node)
{
    AST::AstNode *current_struct_elem = nullptr;
    auto search_str = search_node->str.find("\\") == 0 ? search_node->str.substr(1) : search_node->str;
    auto struct_elem_it =
      std::find_if(current_struct->children.begin(), current_struct->children.end(), [&](AST::AstNode *node) { return node->str == search_str; });
    if (struct_elem_it == current_struct->children.end()) {
        current_struct->dumpAst(NULL, "struct >");
        log_error("Couldn't find search elem: %s in struct\n", search_str.c_str());
    }
    current_struct_elem = *struct_elem_it;

    AST::AstNode *sub_dot = nullptr;
    std::vector<AST::AstNode *> struct_ranges;

    for (auto c : search_node->children) {
        if (c->type == static_cast<int>(AST::Extended::AST_DOT)) {
            // There should be only 1 AST_DOT node children
            log_assert(!sub_dot);
            sub_dot = expand_dot(current_struct_elem, c);
        }
        if (c->type == AST::AST_RANGE) {
            struct_ranges.push_back(c);
        }
    }
    AST::AstNode *left = nullptr, *right = nullptr;
    switch (current_struct_elem->type) {
    case AST::AST_STRUCT_ITEM:
        left = AST::AstNode::mkconst_int(current_struct_elem->range_left, true);
        right = AST::AstNode::mkconst_int(current_struct_elem->range_right, true);
        break;
    case AST::AST_STRUCT:
    case AST::AST_UNION:
        // TODO(krak): add proper support for accessing struct/union elements
        // with multirange
        // Currently support only special access to 2 dimensional packed element
        // when selecting single range
        log_assert(current_struct_elem->multirange_dimensions.size() % 2 == 0);
        if (!struct_ranges.empty() && (current_struct_elem->multirange_dimensions.size() / 2) == 2) {
            // get element size in number of bits
            const int single_elem_size = current_struct_elem->children.front()->range_left + 1;
            left = AST::AstNode::mkconst_int(single_elem_size * current_struct_elem->multirange_dimensions.back(), true);
            right =
              AST::AstNode::mkconst_int(current_struct_elem->children.back()->range_right * current_struct_elem->multirange_dimensions.back(), true);
        } else {
            left = AST::AstNode::mkconst_int(current_struct_elem->children.front()->range_left, true);
            right = AST::AstNode::mkconst_int(current_struct_elem->children.back()->range_right, true);
        }
        break;
    default:
        // Structs currently can only have AST_STRUCT, AST_STRUCT_ITEM, or AST_UNION.
        log_file_error(current_struct_elem->filename, current_struct_elem->location.first_line,
                       "Accessing struct member of type %s is unsupported.\n", type2str(current_struct_elem->type).c_str());
    };

    auto elem_size =
      new AST::AstNode(AST::AST_ADD, new AST::AstNode(AST::AST_SUB, left->clone(), right->clone()), AST::AstNode::mkconst_int(1, true));

    if (sub_dot) {
        // First select correct element in first struct
        std::swap(left, sub_dot->children[0]);
        std::swap(right, sub_dot->children[1]);
        delete sub_dot;
    }

    for (size_t i = 0; i < struct_ranges.size(); i++) {
        const auto *struct_range = struct_ranges[i];
        auto const idx = (struct_ranges.size() - i) * 2 - 1;
        auto const range_width_idx = idx;
        auto const range_offset_idx = idx - 1;

        int range_width = 0;
        if (current_struct_elem->multirange_dimensions.empty()) {
            range_width = 1;
        } else if (current_struct_elem->multirange_dimensions.size() > range_width_idx) {
            range_width = current_struct_elem->multirange_dimensions[range_width_idx];
            const auto range_offset = current_struct_elem->multirange_dimensions[range_offset_idx];
            if (range_offset != 0) {
                log_file_error(struct_range->filename, struct_range->location.first_line,
                               "Accessing ranges that do not start from 0 is not supported.");
            }
        } else {
            struct_range->dumpAst(NULL, "range >");
            log_file_error(struct_range->filename, struct_range->location.first_line, "Couldn't find range width.");
        }
        // now we have correct element set,
        // but we still need to set correct struct
        log_assert(!struct_range->children.empty());
        if (current_struct_elem->type == AST::AST_STRUCT_ITEM) {
            // if we selecting range of struct item, just add this range
            // to our current select
            if (current_struct_elem->multirange_dimensions.size() > 2 && struct_range->children.size() == 2) {
                if (i < (struct_ranges.size() - 1))
                    log_error(
                      "Selecting a range of positions from a multirange is not supported in the dot notation, unless it is the last index.\n");
            }
            if (struct_range->children.size() == 2) {
                auto range_size = new AST::AstNode(
                  AST::AST_ADD, new AST::AstNode(AST::AST_SUB, struct_range->children[0]->clone(), struct_range->children[1]->clone()),
                  AST::AstNode::mkconst_int(1, true));
                right = new AST::AstNode(AST::AST_ADD, right, struct_range->children[1]->clone());
                delete left;
                left = new AST::AstNode(AST::AST_ADD, right->clone(), new AST::AstNode(AST::AST_SUB, range_size, AST::AstNode::mkconst_int(1, true)));

            } else if (struct_range->children.size() == 1) {
                // Selected a single position, as in `foo.bar[i]`.
                if (range_width > 1 && range_width_idx > 1) {
                    // if it's not the last dimension.
                    right = new AST::AstNode(
                      AST::AST_ADD, right,
                      new AST::AstNode(AST::AST_MUL, struct_range->children[0]->clone(), AST::AstNode::mkconst_int(range_width, true)));
                    delete left;
                    left = new AST::AstNode(AST::AST_ADD, right->clone(), AST::AstNode::mkconst_int(range_width - 1, true));
                } else {
                    right = new AST::AstNode(AST::AST_ADD, right, struct_range->children[0]->clone());
                    delete left;
                    left = right->clone();
                }
            } else {
                struct_range->dumpAst(NULL, "range >");
                log_error("Unhandled range select (AST_STRUCT_ITEM) in AST_DOT!\n");
            }
        } else if (current_struct_elem->type == AST::AST_STRUCT) {
            if (struct_range->children.size() == 2) {
                right = new AST::AstNode(AST::AST_ADD, right, struct_range->children[1]->clone());
                auto range_size = new AST::AstNode(
                  AST::AST_ADD, new AST::AstNode(AST::AST_SUB, struct_range->children[0]->clone(), struct_range->children[1]->clone()),
                  AST::AstNode::mkconst_int(1, true));
                left = new AST::AstNode(AST::AST_ADD, left, new AST::AstNode(AST::AST_SUB, range_size, elem_size->clone()));
            } else if (struct_range->children.size() == 1) {
                AST::AstNode *mul = new AST::AstNode(AST::AST_MUL, elem_size->clone(), struct_range->children[0]->clone());

                left = new AST::AstNode(AST::AST_ADD, left, mul);
                right = new AST::AstNode(AST::AST_ADD, right, mul->clone());
            } else {
                struct_range->dumpAst(NULL, "range >");
                log_error("Unhandled range select (AST_STRUCT) in AST_DOT!\n");
            }
        } else {
            log_file_error(current_struct_elem->filename, current_struct_elem->location.first_line,
                           "Accessing member of a slice of type %s is unsupported.\n", type2str(current_struct_elem->type).c_str());
        }
    }
    delete elem_size;
    // Return range from the begining of *current* struct
    // When all AST_DOT are expanded it will return range
    // from original wire
    return new AST::AstNode(AST::AST_RANGE, left, right);
}

static AST::AstNode *convert_dot(AST::AstNode *wire_node, AST::AstNode *node, AST::AstNode *dot)
{
    AST::AstNode *struct_node = nullptr;
    if (wire_node->type == AST::AST_STRUCT || wire_node->type == AST::AST_UNION) {
        struct_node = wire_node;
    } else if (wire_node->attributes.count(ID::wiretype)) {
        log_assert(wire_node->attributes[ID::wiretype]->id2ast);
        struct_node = wire_node->attributes[ID::wiretype]->id2ast;
    } else {
        log_file_error(wire_node->filename, wire_node->location.first_line, "Unsupported node type: %s\n", type2str(wire_node->type).c_str());
    }
    log_assert(struct_node);
    auto expanded = expand_dot(struct_node, dot);
    // Now expand ranges that are at instance part of dotted reference
    // `expand_dot` returns AST_RANGE with 2 children that selects member pointed by dotted reference
    // now we need to move this range to select correct struct
    std::vector<AST::AstNode *> struct_ranges = get_ranges(node);
    log_assert(wire_node->attributes.count(UhdmAst::unpacked_ranges()));
    log_assert(wire_node->attributes.count(UhdmAst::packed_ranges()));
    log_assert(struct_ranges.size() <= (wire_node->multirange_dimensions.size() / 2));
    // TODO(krak): wire ranges are sometimes under wiretype node (e.g. in case of typedef)
    // but wiretype ranges contains also struct range that is already expanded in 'expand_dot'
    // we need to find a way to calculate size of wire ranges without struct range here to enable this assert
    // const auto wire_node_unpacked_ranges_size = wire_node->attributes[UhdmAst::unpacked_ranges()]->children.size();
    // const auto wire_node_packed_ranges_size = wire_node->attributes[UhdmAst::packed_ranges()]->children.size();
    // const auto wire_node_ranges_size = wire_node_packed_ranges_size + wire_node_unpacked_ranges_size;
    // log_assert(struct_ranges.size() == (wire_node_ranges_size - 1));

    // Get size of single structure
    int struct_size_int = get_max_offset_struct(struct_node) + 1;
    auto wire_dimension_size_it = wire_node->multirange_dimensions.rbegin();

    if ((wire_node->multirange_dimensions.empty() || wire_node->multirange_dimensions.size() == 2) && (dot->children.size() == 1) &&
        (!dot->children.at(0)->children.empty())) {
        // Example: assign s.vector2x4[0] = a;
        wire_dimension_size_it = struct_node->children[0]->multirange_dimensions.rbegin();
        std::vector<AST::AstNode *> struct_ranges = get_all_ranges(struct_node);
        if (struct_ranges.size() == 2) {
            auto target = struct_ranges.at(1);
            auto target_l = target->children.at(0);
            auto target_r = target->children.at(1);
            auto index = dot->children.at(0)->children.at(0);
            if (index->type == AST::AST_CONSTANT || index->type == AST::AST_IDENTIFIER) {
                // target_size = l - r + 1
                auto target_size = new AST::AstNode(AST::AST_ADD, new AST::AstNode(AST::AST_SUB, target_l->clone(), target_r->clone()),
                                                    AST::AstNode::mkconst_int(1, true, 32));
                // move_offset = target_size * index
                auto move_offset = new AST::AstNode(AST::AST_MUL, target_size, index->clone());
                delete expanded->children[0];
                delete expanded->children[1];
                expanded->children[0] = new AST::AstNode(AST::AST_ADD, move_offset, target_l->clone());
                expanded->children[1] = new AST::AstNode(AST::AST_ADD, move_offset->clone(), target_r->clone());
                return expanded;
            }
        } else {
            return expanded;
        }
    }

    unsigned long range_id = 0;
    for (auto it = struct_ranges.rbegin(); it != struct_ranges.rend(); it++) {
        // in 'dot' context, we need to select specific struct element,
        // so assert that there is only 1 child in struct range (range with single child)
        log_assert((*it)->children.size() == 1);
        // calculate which struct we selected
        auto move_offset = new AST::AstNode(AST::AST_MUL, AST::AstNode::mkconst_int(struct_size_int, true, 32), (*it)->children[0]->clone());
        // move our expanded dot to currently selected struct
        expanded->children[0] = new AST::AstNode(AST::AST_ADD, move_offset->clone(), expanded->children[0]);
        expanded->children[1] = new AST::AstNode(AST::AST_ADD, move_offset, expanded->children[1]);
        struct_size_int *= *wire_dimension_size_it;
        // wire_dimension_size stores interleaved offset and size. Move to next dimension's size
        wire_dimension_size_it += 2;
        range_id++;
    }
    return expanded;
}

static void setup_current_scope(std::unordered_map<std::string, AST::AstNode *> top_nodes, AST::AstNode *current_top_node)
{
    for (auto it = top_nodes.begin(); it != top_nodes.end(); it++) {
        if (!it->second)
            continue;
        if (it->second->type == AST::AST_PACKAGE) {
            for (auto &o : it->second->children) {
                // import only parameters
                if (o->type == AST::AST_TYPEDEF || o->type == AST::AST_PARAMETER || o->type == AST::AST_LOCALPARAM) {
                    // add imported nodes to current scope
                    AST_INTERNAL::current_scope[it->second->str + std::string("::") + o->str.substr(1)] = o;
                    AST_INTERNAL::current_scope[o->str] = o;
                } else if (o->type == AST::AST_ENUM) {
                    AST_INTERNAL::current_scope[o->str] = o;
                    for (auto c : o->children) {
                        AST_INTERNAL::current_scope[c->str] = c;
                    }
                }
            }
        }
    }
    for (auto &o : current_top_node->children) {
        if (o->type == AST::AST_TYPEDEF || o->type == AST::AST_PARAMETER || o->type == AST::AST_LOCALPARAM) {
            AST_INTERNAL::current_scope[o->str] = o;
        } else if (o->type == AST::AST_ENUM) {
            AST_INTERNAL::current_scope[o->str] = o;
            for (auto c : o->children) {
                AST_INTERNAL::current_scope[c->str] = c;
            }
        }
    }
    // hackish way of setting current_ast_mod as it is required
    // for simplify to get references for already defined ids
    AST_INTERNAL::current_ast_mod = current_top_node;
    log_assert(AST_INTERNAL::current_ast_mod != nullptr);
}

static int range_width_local(AST::AstNode *node, AST::AstNode *rnode)
{
    log_assert(rnode->type == AST::AST_RANGE);
    if (!rnode->range_valid) {
        log_file_error(node->filename, node->location.first_line, "Size must be constant in packed struct/union member %s\n", node->str.c_str());
    }
    // note: range swapping has already been checked for
    return rnode->range_left - rnode->range_right + 1;
}

static void save_struct_array_width_local(AST::AstNode *node, int width)
{
    // stash the stride for the array
    node->multirange_dimensions.push_back(width);
}

static int simplify_struct(AST::AstNode *snode, int base_offset, AST::AstNode *parent_node)
{
    // Struct members will be laid out in the structure contiguously from left to right.
    // Union members all have zero offset from the start of the union.
    // Determine total packed size and assign offsets.  Store these in the member node.
    bool is_union = (snode->type == AST::AST_UNION);
    int offset = 0;
    int packed_width = -1;
    for (auto s : snode->children) {
        if (s->type == AST::AST_RANGE) {
            while (simplify(s, true, false, false, 1, -1, false, false)) {
            };
        }
    }
    // embeded struct or union with range?
    auto it = std::remove_if(snode->children.begin(), snode->children.end(), [](AST::AstNode *node) { return node->type == AST::AST_RANGE; });
    std::vector<AST::AstNode *> ranges(it, snode->children.end());
    snode->children.erase(it, snode->children.end());
    if (!ranges.empty()) {
        for (auto range : ranges) {
            snode->multirange_dimensions.push_back(min(range->range_left, range->range_right));
            snode->multirange_dimensions.push_back(max(range->range_left, range->range_right) - min(range->range_left, range->range_right) + 1);
            snode->multirange_swapped.push_back(range->range_swapped);
            delete range;
        }
    }
    // examine members from last to first
    for (auto it = snode->children.rbegin(); it != snode->children.rend(); ++it) {
        auto node = *it;
        int width;
        if (node->type == AST::AST_STRUCT || node->type == AST::AST_UNION) {
            // embedded struct or union
            width = simplify_struct(node, base_offset + offset, parent_node);
            if (!node->multirange_dimensions.empty()) {
                // Multiply widths of all dimensions.
                // `multirange_dimensions` stores (repeating) pairs of [offset, width].
                for (size_t i = 1; i < node->multirange_dimensions.size(); i += 2) {
                    width *= node->multirange_dimensions[i];
                }
            }
            // set range of struct
            node->range_right = base_offset + offset;
            node->range_left = base_offset + offset + width - 1;
            node->range_valid = true;
        } else {
            log_assert(node->type == AST::AST_STRUCT_ITEM);
            if (node->children.size() > 0 && node->children[0]->type == AST::AST_RANGE) {
                // member width e.g. bit [7:0] a
                width = range_width_local(node, node->children[0]);
                if (node->children.size() == 2) {
                    if (node->children[1]->type == AST::AST_RANGE) {
                        // unpacked array e.g. bit [63:0] a [0:3]
                        auto rnode = node->children[1];
                        int array_count = range_width_local(node, rnode);
                        if (array_count == 1) {
                            // C-type array size e.g. bit [63:0] a [4]
                            array_count = rnode->range_left;
                        }
                        save_struct_array_width_local(node, width);
                        width *= array_count;
                    } else {
                        // array element must be single bit for a packed array
                        log_file_error(node->filename, node->location.first_line, "Unpacked array in packed struct/union member %s\n",
                                       node->str.c_str());
                    }
                }
                // range nodes are now redundant
                for (AST::AstNode *child : node->children)
                    delete child;
                node->children.clear();
            } else if (node->children.size() == 1 && node->children[0]->type == AST::AST_MULTIRANGE) {
                // packed 2D array, e.g. bit [3:0][63:0] a
                auto rnode = node->children[0];
                if (rnode->children.size() != 2) {
                    // packed arrays can only be 2D
                    log_file_error(node->filename, node->location.first_line, "Unpacked array in packed struct/union member %s\n", node->str.c_str());
                }
                int array_count = range_width_local(node, rnode->children[0]);
                width = range_width_local(node, rnode->children[1]);
                save_struct_array_width_local(node, width);
                width *= array_count;
                // range nodes are now redundant
                for (AST::AstNode *child : node->children)
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
    if (!snode->str.empty() && parent_node && parent_node->type != AST::AST_TYPEDEF && parent_node->type != AST::AST_STRUCT &&
        AST_INTERNAL::current_scope.count(snode->str) != 0) {
        AST_INTERNAL::current_scope[snode->str]->attributes[ID::wiretype] = AST::AstNode::mkconst_str(snode->str);
        AST_INTERNAL::current_scope[snode->str]->attributes[ID::wiretype]->id2ast = snode;
    }
    return (is_union ? packed_width : offset);
}

static void add_members_to_scope_local(AST::AstNode *snode, std::string name)
{
    // add all the members in a struct or union to local scope
    // in case later referenced in assignments
    log_assert(snode->type == AST::AST_STRUCT || snode->type == AST::AST_UNION);
    for (auto *node : snode->children) {
        auto member_name = name + "." + node->str;
        AST_INTERNAL::current_scope[member_name] = node;
        if (node->type != AST::AST_STRUCT_ITEM) {
            // embedded struct or union
            add_members_to_scope_local(node, name + "." + node->str);
        }
    }
}

static AST::AstNode *make_packed_struct_local(AST::AstNode *template_node, std::string &name)
{
    // create a wire for the packed struct
    auto wnode = new AST::AstNode(AST::AST_WIRE);
    wnode->str = name;
    wnode->is_logic = true;
    wnode->range_valid = true;
    wnode->is_signed = template_node->is_signed;
    int offset = get_max_offset_struct(template_node);
    auto range = make_range(offset, 0);
    copy_packed_unpacked_attribute(template_node, wnode);
    wnode->attributes[UhdmAst::packed_ranges()]->children.insert(wnode->attributes[UhdmAst::packed_ranges()]->children.begin(), range);
    // make sure this node is the one in scope for this name
    AST_INTERNAL::current_scope[name] = wnode;
    // add all the struct members to scope under the wire's name
    add_members_to_scope_local(template_node, name);
    return wnode;
}

static void simplify_format_string(AST::AstNode *current_node)
{
    std::string sformat = current_node->children[0]->str;
    std::string preformatted_string = "";
    int next_arg = 1;
    for (size_t i = 0; i < sformat.length(); i++) {
        if (sformat[i] == '%') {
            AST::AstNode *node_arg = current_node->children[next_arg];
            char cformat = sformat[++i];
            if (cformat == 'b' or cformat == 'B') {
                simplify(node_arg, true, false, false, 1, -1, false, false);
                if (node_arg->type != AST::AST_CONSTANT)
                    log_file_error(current_node->filename, current_node->location.first_line,
                                   "Failed to evaluate system task `%s' with non-constant argument.\n", current_node->str.c_str());

                RTLIL::Const val = node_arg->bitsAsConst();
                for (int j = val.size() - 1; j >= 0; j--) {
                    // We add ACII value of 0 to convert number to character
                    preformatted_string += ('0' + val[j]);
                }
                delete current_node->children[next_arg];
                current_node->children.erase(current_node->children.begin() + next_arg);
            } else {
                next_arg++;
                preformatted_string += std::string("%") + cformat;
            }
        } else {
            preformatted_string += sformat[i];
        }
    }
    delete current_node->children[0];
    current_node->children[0] = AST::AstNode::mkconst_str(preformatted_string);
}

// A wrapper for Yosys simplify function.
// Simplifies AST constructs specific to this plugin to a form understandable by Yosys' simplify and then calls the latter if necessary.
// Since simplify from Yosys has been forked to this codebase, all new code should be added there instead.
static void simplify_sv(AST::AstNode *current_node, AST::AstNode *parent_node)
{
    auto dot_it = std::find_if(current_node->children.begin(), current_node->children.end(),
                               [](auto c) { return c->type == static_cast<int>(AST::Extended::AST_DOT); });
    AST::AstNode *dot = (dot_it != current_node->children.end()) ? *dot_it : nullptr;

    AST::AstNode *expanded = nullptr;
    if (dot) {
        if (!AST_INTERNAL::current_scope.count(current_node->str)) {
            // for accessing elements currently unsupported with AST_DOT
            // fallback to "." notation
            AST::AstNode *prefix_node = nullptr;
            AST::AstNode *parent_node = current_node;
            while (dot && !dot->str.empty()) {
                // it is not possible for AST_RANGE to be after AST::DOT (see process_hier_path function)
                if (parent_node->children[0]->type == AST::AST_RANGE) {
                    if (parent_node->children[1]->type == AST::AST_RANGE)
                        log_error("Multirange in AST_DOT is currently unsupported\n");

                    dot->type = AST::AST_IDENTIFIER;
                    simplify_sv(dot, nullptr);
                    AST::AstNode *range_const = parent_node->children[0]->children[0];
                    prefix_node = new AST::AstNode(AST::AST_PREFIX, range_const->clone(), dot->clone());
                    break;
                } else {
                    current_node->str += "." + dot->str.substr(1);
                    dot_it = std::find_if(dot->children.begin(), dot->children.end(),
                                          [](auto c) { return c->type == static_cast<int>(AST::Extended::AST_DOT); });
                    parent_node = dot;
                    dot = (dot_it != dot->children.end()) ? *dot_it : nullptr;
                }
            }
            delete_children(current_node);
            if (prefix_node != nullptr) {
                current_node->type = AST::AST_PREFIX;
                current_node->children = prefix_node->children;

                prefix_node->children.clear();
                delete prefix_node;
            }
        } else {
            auto wire_node = AST_INTERNAL::current_scope[current_node->str];
            // make sure wire_node is already simplified
            simplify_sv(wire_node, nullptr);
            expanded = convert_dot(wire_node, current_node, dot);
        }
    }
    if (expanded) {
        delete_children(current_node);
        current_node->children.push_back(expanded->clone());
        current_node->basic_prep = true;
        delete expanded;
        expanded = nullptr;
    }
    // First simplify children
    for (size_t i = 0; i < current_node->children.size(); i++) {
        simplify_sv(current_node->children[i], current_node);
    }
    switch (current_node->type) {
    case AST::AST_TYPEDEF:
    case AST::AST_ENUM:
    case AST::AST_FUNCTION:
        AST_INTERNAL::current_scope[current_node->str] = current_node;
        break;
    case AST::AST_WIRE:
    case AST::AST_PARAMETER:
    case AST::AST_LOCALPARAM:
        if (!current_node->attributes.count(UhdmAst::is_simplified_wire())) {
            current_node->attributes[UhdmAst::is_simplified_wire()] = AST::AstNode::mkconst_int(1, true);
            AST_INTERNAL::current_scope[current_node->str] = current_node;
            convert_packed_unpacked_range(current_node);
        }
        break;
    case AST::AST_IDENTIFIER:
        if (!current_node->children.empty() && !current_node->basic_prep) {
            log_assert(AST_INTERNAL::current_ast_mod);
            if (!AST_INTERNAL::current_scope.count(current_node->str)) {
                break;
            }
            AST::AstNode *wire_node = AST_INTERNAL::current_scope[current_node->str];

            // if a wire is simplified multiple times, its ranges may be added multiple times and be redundant as a result
            if (!wire_node->attributes.count(UhdmAst::is_simplified_wire())) {
                simplify_sv(wire_node, nullptr);
            }
            const int packed_ranges_size =
              wire_node->attributes.count(UhdmAst::packed_ranges()) ? wire_node->attributes[UhdmAst::packed_ranges()]->children.size() : 0;
            const int unpacked_ranges_size =
              wire_node->attributes.count(UhdmAst::unpacked_ranges()) ? wire_node->attributes[UhdmAst::unpacked_ranges()]->children.size() : 0;
            if ((wire_node->type == AST::AST_WIRE || wire_node->type == AST::AST_PARAMETER || wire_node->type == AST::AST_LOCALPARAM) &&
                (packed_ranges_size + unpacked_ranges_size > 1)) {
                auto *result = convert_range(current_node, packed_ranges_size, unpacked_ranges_size, 0);
                delete_children(current_node);
                current_node->children.push_back(result);
            }
        }
        break;
    case AST::AST_STRUCT:
    case AST::AST_UNION:
        if (!current_node->attributes.count(UhdmAst::is_simplified_wire())) {
            current_node->attributes[UhdmAst::is_simplified_wire()] = AST::AstNode::mkconst_int(1, true);
            simplify_struct(current_node, 0, parent_node);
            // instance rather than just a type in a typedef or outer struct?
            if (!current_node->str.empty() && current_node->str[0] == '\\') {
                // instance so add a wire for the packed structure
                auto wnode = make_packed_struct_local(current_node, current_node->str);
                if (!wnode->attributes.count(UhdmAst::is_simplified_wire())) {
                    wnode->attributes[UhdmAst::is_simplified_wire()] = AST::AstNode::mkconst_int(1, true);
                    convert_packed_unpacked_range(wnode);
                    log_assert(AST_INTERNAL::current_ast_mod);
                    AST_INTERNAL::current_ast_mod->children.push_back(wnode);
                    AST_INTERNAL::current_scope[wnode->str]->attributes[ID::wiretype] = AST::AstNode::mkconst_str(current_node->str);
                    AST_INTERNAL::current_scope[wnode->str]->attributes[ID::wiretype]->id2ast = current_node;
                }
            }

            current_node->basic_prep = true;
        }
        break;
    case AST::AST_STRUCT_ITEM:
        if (!current_node->attributes.count(UhdmAst::is_simplified_wire())) {
            current_node->attributes[UhdmAst::is_simplified_wire()] = AST::AstNode::mkconst_int(1, true);
            AST_INTERNAL::current_scope[current_node->str] = current_node;
            convert_packed_unpacked_range(current_node);
            while (simplify(current_node, true, false, false, 1, -1, false, false)) {
            };
        }
        break;
    case AST::AST_TCALL:
        if (current_node->str == "$display" || current_node->str == "$write")
            simplify_format_string(current_node);
        break;
    case AST::AST_COND:
    case AST::AST_CONDX:
    case AST::AST_CONDZ:
        // handle custom low high bound
        if (current_node->attributes.count(UhdmAst::low_high_bound())) {
            log_assert(!current_node->children.empty());
            log_assert(current_node->children[0]->type == AST::AST_BLOCK);
            log_assert(current_node->children[0]->children.size() == 2);
            auto low_high_bound = current_node->children[0];
            // this is executed when condition is met
            // save pointer that will be added later again
            // as conditions needs to go before this block
            auto result = current_node->children[1];

            current_node->children[0] = nullptr;
            current_node->children[1] = nullptr;
            delete_children(current_node);
            while (simplify(low_high_bound->children[0], true, false, false, 1, -1, false, false)) {
            };
            while (simplify(low_high_bound->children[1], true, false, false, 1, -1, false, false)) {
            };
            log_assert(low_high_bound->children[0]->type == AST::AST_CONSTANT);
            log_assert(low_high_bound->children[1]->type == AST::AST_CONSTANT);
            const int low = low_high_bound->children[0]->integer;
            const int high = low_high_bound->children[1]->integer;
            const int range = low_high_bound->children[1]->range_valid   ? low_high_bound->children[1]->range_left
                              : low_high_bound->children[0]->range_valid ? low_high_bound->children[0]->range_left
                                                                         : 32;
            delete low_high_bound;
            // According to standard:
            // If the bound to the left of the colon is greater than the
            // bound to the right, the range is empty and contains no values.
            for (int i = low; i >= low && i <= high; i++) {
                current_node->children.push_back(AST::AstNode::mkconst_int(i, false, range));
            }
            current_node->children.push_back(result);
            delete_attribute(current_node, UhdmAst::low_high_bound());
        }
        break;
    case AST::AST_FCALL:
        if (AST_INTERNAL::current_scope.count(current_node->str)) {
            auto *node = AST_INTERNAL::current_scope[current_node->str];
            if (!node->attributes.count(UhdmAst::is_simplified_wire())) {
                node->attributes[UhdmAst::is_simplified_wire()] = AST::AstNode::mkconst_int(1, true);
                simplify_sv(node, nullptr);
            }
        }
        break;
    default:
        break;
    }
}

static void clear_current_scope()
{
    // Remove clear current_scope from package nodes
    AST_INTERNAL::current_scope.clear();
    // unset current_ast_mod
    AST_INTERNAL::current_ast_mod = nullptr;
}

void UhdmAst::visit_one_to_many(const std::vector<int> child_node_types, vpiHandle parent_handle, const std::function<void(AST::AstNode *)> &f)
{
    for (auto child : child_node_types) {
        vpiHandle itr = vpi_iterate(child, parent_handle);
        while (vpiHandle vpi_child_obj = vpi_scan(itr)) {
            UhdmAst uhdm_ast(this, shared, indent + "  ");
            auto *child_node = uhdm_ast.process_object(vpi_child_obj);
            if (child_node)
                f(child_node);
            vpi_release_handle(vpi_child_obj);
        }
        vpi_release_handle(itr);
    }
}

void UhdmAst::iterate_one_to_many(const std::vector<int> child_node_types, vpiHandle parent_handle, const std::function<void(vpiHandle)> &f)
{
    for (auto child : child_node_types) {
        vpiHandle itr = vpi_iterate(child, parent_handle);
        while (vpiHandle vpi_child_obj = vpi_scan(itr)) {
            f(vpi_child_obj);
            vpi_release_handle(vpi_child_obj);
        }
        vpi_release_handle(itr);
    }
}

void UhdmAst::visit_one_to_one(const std::vector<int> child_node_types, vpiHandle parent_handle, const std::function<void(AST::AstNode *)> &f)
{
    for (auto child : child_node_types) {
        vpiHandle itr = vpi_handle(child, parent_handle);
        if (itr && (vpi_get(vpiType, itr) == vpiRefTypespec)) {
            vpiHandle itr_rt = itr;
            itr = vpi_handle(vpiActual, itr);
            vpi_release_handle(itr_rt);
        }
        if (itr) {
            UhdmAst uhdm_ast(this, shared, indent + "  ");
            auto *child_node = uhdm_ast.process_object(itr);
            f(child_node);
        }
        vpi_release_handle(itr);
    }
}

void UhdmAst::visit_range(vpiHandle obj_h, const std::function<void(AST::AstNode *)> &f)
{
    std::vector<AST::AstNode *> range_nodes;
    visit_one_to_many({vpiRange}, obj_h, [&](AST::AstNode *node) { range_nodes.push_back(node); });
    if (range_nodes.size() > 1) {
        auto multirange_node = new AST::AstNode(AST::AST_MULTIRANGE);
        multirange_node->children = range_nodes;
        f(multirange_node);
    } else if (!range_nodes.empty()) {
        f(range_nodes[0]);
    }
}

void UhdmAst::visit_default_expr(vpiHandle obj_h)
{
    UhdmAst initial_ast(parent, shared, indent);
    UhdmAst block_ast(&initial_ast, shared, indent);
    block_ast.visit_one_to_one({vpiExpr}, obj_h, [&](AST::AstNode *expr_node) {
        auto mod = find_ancestor({AST::AST_MODULE});
        AST::AstNode *initial_node = nullptr;
        AST::AstNode *block_node = nullptr;
        auto assign_node = new AST::AstNode(AST::AST_ASSIGN_EQ);
        auto id_node = new AST::AstNode(AST::AST_IDENTIFIER);
        id_node->str = current_node->str;

        for (auto child : mod->children) {
            if (child->type == AST::AST_INITIAL) {
                initial_node = child;
                break;
            }
        }
        // Ensure single AST_INITIAL node is located in AST_MODULE
        // before any AST_ALWAYS
        if (initial_node == nullptr) {
            initial_node = new AST::AstNode(AST::AST_INITIAL);
            auto insert_it = find_if(mod->children.begin(), mod->children.end(), [](AST::AstNode *node) { return (node->type == AST::AST_ALWAYS); });
            mod->children.insert(insert_it, initial_node);
        }
        // Ensure single AST_BLOCK node in AST_INITIAL
        if (!initial_node->children.empty() && initial_node->children[0]) {
            block_node = initial_node->children[0];
        } else {
            block_node = new AST::AstNode(AST::AST_BLOCK);
            initial_node->children.push_back(block_node);
        }
        auto block_child =
          find_if(block_node->children.begin(), block_node->children.end(), [](AST::AstNode *node) { return (node->type == AST::AST_ASSIGN_EQ); });
        // Insert AST_ASSIGN_EQ nodes that came from
        // custom_var or int_var before any other AST_ASSIGN_EQ
        // Especially before ones explicitly placed in initial block in source code
        block_node->children.insert(block_child, assign_node);
        assign_node->children.push_back(id_node);
        initial_ast.current_node = initial_node;
        block_ast.current_node = block_node;
        assign_node->children.push_back(expr_node);
    });
}

void UhdmAst::process_array_expr(const UHDM::BaseClass *object)
{
    current_node = make_ast_node(AST::AST_CONCAT);
    visit_one_to_many({vpiExpr}, obj_h, [&](AST::AstNode *node) {
        if (!node)
            return;
        current_node->children.push_back(node);
    });
}

AST::AstNode *UhdmAst::process_value(vpiHandle obj_h)
{
    s_vpi_value val;
    vpi_get_value(obj_h, &val);
    std::string strValType = "'";
    bool is_signed = false;
    if (vpiHandle ref_typespec_h = vpi_handle(vpiTypespec, obj_h)) {
        if (vpiHandle typespec_h = vpi_handle(vpiActual, ref_typespec_h)) {
            is_signed = vpi_get(vpiSigned, typespec_h);
            if (is_signed) {
                strValType += "s";
            }
            vpi_release_handle(typespec_h);
        }
        vpi_release_handle(ref_typespec_h);
    }
    std::string val_str;
    if (val.format) { // Needed to handle parameter nodes without typespecs and constants
        switch (val.format) {
        case vpiScalarVal:
            return AST::AstNode::mkconst_int(val.value.scalar, false, 1);
        case vpiBinStrVal: {
            strValType += "b";
            val_str = val.value.str;
            break;
        }
        case vpiDecStrVal: {
            strValType += "d";
            val_str = val.value.str;
            break;
        }
        case vpiHexStrVal: {
            strValType += "h";
            val_str = val.value.str;
            break;
        }
        case vpiOctStrVal: {
            strValType += "o";
            val_str = val.value.str;
            break;
        }
        // Surelog reports constant integers as a unsigned, but by default int is signed
        // so we are treating here UInt in the same way as if they would be Int
        case vpiUIntVal:
            if (val.value.uint > std::numeric_limits<std::uint32_t>::max()) {
                // an integer is by default signed, so use 'sd despite the variant vpiUIntVal
                strValType = "'sd";
                val_str = std::to_string(val.value.uint);
                break;
            }
            [[fallthrough]];
        case vpiIntVal: {
            if (val.value.integer > std::numeric_limits<std::int32_t>::max()) {
                strValType = "'sd";
                val_str = std::to_string(val.value.integer);
                break;
            }

            auto size = vpi_get(vpiSize, obj_h);
            // Surelog by default returns 64 bit numbers and stardard says that they shall be at least 32bits
            // yosys is assuming that int/uint is 32 bit, so we are setting here correct size
            // NOTE: it *shouldn't* break on explicite 64 bit const values, as they *should* be handled
            // above by vpi*StrVal
            if (size == 64) {
                size = 32;
                is_signed = true;
            }
            auto c = AST::AstNode::mkconst_int(val.format == vpiUIntVal ? val.value.uint : val.value.integer, is_signed, size > 0 ? size : 32);
            if (size == 0 || size == -1)
                c->is_unsized = true;
            return c;
        }
        case vpiRealVal:
            return mkconst_real(val.value.real);
        case vpiStringVal:
            return AST::AstNode::mkconst_str(val.value.str);
        default: {
            const uhdm_handle *const handle = (const uhdm_handle *)obj_h;
            const UHDM::BaseClass *const object = (const UHDM::BaseClass *)handle->object;
            report_error("%.*s:%d: Encountered unhandled constant format %d\n", (int)object->VpiFile().length(), object->VpiFile().data(),
                         object->VpiLineNo(), val.format);
        }
        }
        // if this constant is under case/casex/casez
        // get current case type
        char caseType = ' ';
        if (vpiHandle caseItem_h = vpi_handle(vpiParent, obj_h)) {
            if (vpiHandle case_h = vpi_handle(vpiParent, caseItem_h)) {
                switch (vpi_get(vpiCaseType, case_h)) {
                case vpiCaseExact:
                    caseType = ' ';
                    break;
                case vpiCaseX:
                    caseType = 'x';
                    break;
                case vpiCaseZ:
                    caseType = 'z';
                    break;
                default: {
                    caseType = ' ';
                    break;
                }
                }
                vpi_release_handle(case_h);
            }
            vpi_release_handle(caseItem_h);
        }
        // handle vpiBinStrVal, vpiDecStrVal and vpiHexStrVal
        if (val_str.find('\'') != std::string::npos) {
            return ::systemverilog_plugin::const2ast(std::move(val_str), caseType, false);
        } else {
            auto size = vpi_get(vpiSize, obj_h);
            std::string size_str;
            if (size > 0) {
                size_str = std::to_string(size);
            } else if (strValType == "\'b") {
                // probably unsized unbased const
                // but to make sure parse vpiDecompile
                auto decompile = vpi_get_str(vpiDecompile, obj_h);
                if (decompile && !std::strchr(decompile, 'b')) {
                    // unsized unbased
                    // we can't left size_str empty, as then yosys parses this const as 32bit value
                    size_str = "1";
                }
            }
            auto c = ::systemverilog_plugin::const2ast(size_str + strValType + val_str, caseType, false);
            if (size <= 0) {
                // unsized unbased const
                c->is_unsized = true;
            }
            return c;
        }
    }
    return nullptr;
}

void UhdmAst::transform_breaks_continues(AST::AstNode *loop, AST::AstNode *decl_block)
{
    AST::AstNode *break_wire = nullptr;
    AST::AstNode *continue_wire = nullptr;
    // Creates a 1-bit wire with the given name
    const auto make_cond_var = [this](const std::string &var_name) {
        auto cond_var =
          make_ast_node(AST::AST_WIRE, {make_ast_node(AST::AST_RANGE, {AST::AstNode::mkconst_int(0, false), AST::AstNode::mkconst_int(0, false)}),
                                        AST::AstNode::mkconst_int(0, false)});
        cond_var->str = var_name;
        cond_var->is_reg = true;
        return cond_var;
    };
    // Creates a conditional like 'if (!casevar) block'
    auto make_case = [this](AST::AstNode *block, const std::string &casevar_name) {
        auto *case_node = make_ast_node(AST::AST_CASE);
        auto *id = make_identifier(casevar_name);
        case_node->children.push_back(id);
        auto *constant = AST::AstNode::mkconst_int(0, false, 1);
        auto *cond_node = make_ast_node(AST::AST_COND);
        cond_node->children.push_back(constant);
        cond_node->children.push_back(block);
        case_node->children.push_back(cond_node);
        return case_node;
    };
    // Pre-declare this function to be able to call it recursively
    std::function<bool(AST::AstNode *)> transform_block;
    // Transforms the given block if it has a break or continue; recurses into child blocks; return true if a break/continue was encountered
    transform_block = [&](AST::AstNode *block) {
        auto wrap_and_transform = [&](decltype(block->children)::iterator it) {
            // Move the (it, end()) statements into a new block under 'if (!continue) {...}'
            auto *new_block = make_ast_node(AST::AST_BLOCK, {it, block->children.end()});
            block->children.erase(it, block->children.end());
            auto *case_node = make_case(new_block, continue_wire->str);
            block->children.push_back(case_node);
            transform_block(new_block);
        };

        for (auto it = block->children.begin(); it != block->children.end(); it++) {
            auto type = static_cast<int>((*it)->type);
            switch (type) {
            case AST::AST_BLOCK: {
                if (transform_block(*it)) {
                    // If there was a break/continue, we need to wrap the rest of the block in an if
                    wrap_and_transform(it + 1);
                    return true;
                }
                break;
            }
            case AST::AST_CASE: {
                // Go over each block in a case
                bool has_jump = false;
                for (auto *node : (*it)->children) {
                    if (node->type == AST::AST_COND)
                        has_jump = has_jump || transform_block(node->children.back());
                }
                if (has_jump) {
                    // If there was a break/continue, we need to wrap the rest of the block in an if
                    wrap_and_transform(it + 1);
                    return true;
                }
                break;
            }
            case AST::Extended::AST_BREAK:
            case AST::Extended::AST_CONTINUE: {
                std::for_each(it, block->children.end(), [](auto *node) { delete node; });
                block->children.erase(it, block->children.end());
                if (!continue_wire)
                    continue_wire = make_cond_var("$continue");
                auto *continue_id = make_identifier(continue_wire->str);
                block->children.push_back(make_ast_node(AST::AST_ASSIGN_EQ, {continue_id, AST::AstNode::mkconst_int(1, false)}));
                if (type == AST::Extended::AST_BREAK) {
                    if (!break_wire)
                        break_wire = make_cond_var("$break");
                    auto *break_id = make_identifier(break_wire->str);
                    block->children.push_back(make_ast_node(AST::AST_ASSIGN_EQ, {break_id, AST::AstNode::mkconst_int(1, false)}));
                }
                return true;
            }
            }
        }
        return false;
    };

    // Actual transformation starts here
    transform_block(loop->children.back());
    if (continue_wire) {
        auto *continue_id = make_identifier(continue_wire->str);
        // Reset $continue each iteration
        auto *continue_assign = make_ast_node(AST::AST_ASSIGN_EQ, {continue_id, AST::AstNode::mkconst_int(0, false)});
        decl_block->children.insert(decl_block->children.begin(), continue_wire);
        loop->children.back()->children.insert(loop->children.back()->children.begin(), continue_assign);
    }
    if (break_wire) {
        auto *break_id = make_identifier(break_wire->str);
        // Reset $break before the loop
        auto *break_assign = make_ast_node(AST::AST_ASSIGN_EQ, {break_id, AST::AstNode::mkconst_int(0, false)});
        decl_block->children.insert(decl_block->children.begin(), break_assign);
        decl_block->children.insert(decl_block->children.begin(), break_wire);
        if (loop->type == AST::AST_REPEAT || loop->type == AST::AST_FOR) {
            // Wrap loop body in 'if (!break) {...}'
            // Changing the for loop condition won't work here,
            // as then simplify fails with error "2nd expression of procedural for-loop is not constant!"
            auto *case_node = make_case(loop->children.back(), break_wire->str);
            auto *new_block = make_ast_node(AST::AST_BLOCK);
            new_block->children.push_back(case_node);
            new_block->str = loop->children.back()->str;
            loop->children.back() = new_block;
        } else if (loop->type == AST::AST_WHILE) {
            // Add the break var to the loop condition
            auto *break_id = make_identifier(break_wire->str);
            AST::AstNode *&loop_cond = loop->children[0];
            loop_cond = make_ast_node(AST::AST_LOGIC_AND, {make_ast_node(AST::AST_LOGIC_NOT, {break_id}), loop_cond});
        } else {
            log_error("break unsupported for this loop type");
        }
    }
}

void UhdmAst::apply_location_from_current_obj(AST::AstNode &target_node) const
{
    if (auto filename = vpi_get_str(vpiFile, obj_h)) {
        target_node.filename = filename;
    }
    if (unsigned int first_line = vpi_get(vpiLineNo, obj_h)) {
        target_node.location.first_line = first_line;
    }
    if (unsigned int last_line = vpi_get(vpiEndLineNo, obj_h)) {
        target_node.location.last_line = last_line;
    } else {
        target_node.location.last_line = target_node.location.first_line;
    }
    if (unsigned int first_col = vpi_get(vpiColumnNo, obj_h)) {
        target_node.location.first_column = first_col;
    }
    if (unsigned int last_col = vpi_get(vpiEndColumnNo, obj_h)) {
        target_node.location.last_column = last_col;
    } else {
        target_node.location.last_column = target_node.location.first_column;
    }
}

void UhdmAst::apply_name_from_current_obj(AST::AstNode &target_node) const
{
    target_node.str = get_name(obj_h);
    auto it = node_renames.find(target_node.str);
    if (it != node_renames.end())
        target_node.str = it->second;
}

AstNodeBuilder UhdmAst::make_node(AST::AstNodeType type) const
{
    auto node = std::make_unique<AST::AstNode>(type);
    apply_location_from_current_obj(*node);
    return AstNodeBuilder(std::move(node));
};

AstNodeBuilder UhdmAst::make_named_node(AST::AstNodeType type) const
{
    auto node = std::make_unique<AST::AstNode>(type);
    apply_location_from_current_obj(*node);
    apply_name_from_current_obj(*node);
    return AstNodeBuilder(std::move(node));
};

AstNodeBuilder UhdmAst::make_ident(std::string id) const { return make_node(::Yosys::AST::AST_IDENTIFIER).str(std::move(id)); };

AstNodeBuilder UhdmAst::make_const(int32_t value, uint8_t width) const
{
    // Limited to width of the `value` argument.
    log_assert(width <= 32);
    return make_node(AST::AST_CONSTANT).value(value, true, width);
};

AstNodeBuilder UhdmAst::make_const(uint32_t value, uint8_t width) const
{
    // Limited to width of the `value` argument.
    log_assert(width <= 32);
    return make_node(AST::AST_CONSTANT).value(value, false, width);
};

AST::AstNode *UhdmAst::make_ast_node(AST::AstNodeType type, std::vector<AST::AstNode *> children)
{
    auto node = new AST::AstNode(type);
    apply_name_from_current_obj(*node);
    apply_location_from_current_obj(*node);
    node->children = children;
    return node;
}

AST::AstNode *UhdmAst::make_identifier(std::string name)
{
    auto *node = make_ast_node(AST::AST_IDENTIFIER);
    node->str = std::move(name);
    return node;
}

void UhdmAst::process_packed_array_typespec()
{
    std::vector<AST::AstNode *> packed_ranges;
    std::vector<AST::AstNode *> unpacked_ranges;
    current_node = make_ast_node(AST::AST_WIRE);
    visit_one_to_many({vpiRange}, obj_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
    visit_one_to_one({vpiElemTypespec}, obj_h, [&](AST::AstNode *node) {
        if (node && node->type == AST::AST_STRUCT) {
            auto str = current_node->str;
            // unnamed array of named (struct) array
            if (str.empty() && !node->str.empty())
                str = node->str;
            node->cloneInto(current_node);
            current_node->str = str;
            delete node;
        } else if (node && (node->type == AST::AST_ENUM)) {
            AST::AstNode *const wiretype_node = make_named_node(AST::AST_WIRETYPE);
            wiretype_node->str = node->str;
            current_node->children.push_back(wiretype_node);
            current_node->is_custom_type = true;
            current_node->str = node->str;
            delete node;
        } else if (node) {
            if (!node->str.empty()) {
                AST::AstNode *const wiretype_node = make_named_node(AST::AST_WIRETYPE);
                wiretype_node->str = node->str;
                current_node->children.push_back(wiretype_node);
                current_node->is_custom_type = true;
                auto it = shared.param_types.find(wiretype_node->str);
                if (it == shared.param_types.end())
                    shared.param_types.insert(std::make_pair(wiretype_node->str, node));
                else
                    delete node;
            } else {
                delete node;
            }
        }
    });
    add_multirange_wire(current_node, std::move(packed_ranges), std::move(unpacked_ranges));
}

static void add_or_replace_child(AST::AstNode *parent, AST::AstNode *child)
{
    if (!child->str.empty()) {
        auto it = std::find_if(parent->children.begin(), parent->children.end(),
                               [child](AST::AstNode *existing_child) { return existing_child->str == child->str; });
        if (it != parent->children.end()) {
            // If port direction is already set, copy it to replaced child node
            if ((*it)->is_input || (*it)->is_output) {
                child->is_input = (*it)->is_input;
                child->is_output = (*it)->is_output;
                child->port_id = (*it)->port_id;
                if (child->type == AST::AST_MEMORY)
                    child->type = AST::AST_WIRE;
            }
            child->is_signed = child->is_signed || (*it)->is_signed;
            if (!(*it)->children.empty() && child->children.empty()) {
                // This is a bit ugly, but if the child we're replacing has children and
                // our node doesn't, we copy its children to not lose any information
                for (auto grandchild : (*it)->children) {
                    child->children.push_back(grandchild->clone());
                    if (child->type == AST::AST_WIRE && grandchild->type == AST::AST_WIRETYPE)
                        child->is_custom_type = true;
                }
            }
            if ((*it)->attributes.count(UhdmAst::packed_ranges()) && child->attributes.count(UhdmAst::packed_ranges())) {
                if ((!(*it)->attributes[UhdmAst::packed_ranges()]->children.empty() &&
                     child->attributes[UhdmAst::packed_ranges()]->children.empty())) {

                    delete_attribute(child, UhdmAst::packed_ranges());
                    child->attributes[UhdmAst::packed_ranges()] = (*it)->attributes[UhdmAst::packed_ranges()]->clone();
                }
            }
            if ((*it)->attributes.count(UhdmAst::unpacked_ranges()) && child->attributes.count(UhdmAst::unpacked_ranges())) {
                if ((!(*it)->attributes[UhdmAst::unpacked_ranges()]->children.empty() &&
                     child->attributes[UhdmAst::unpacked_ranges()]->children.empty())) {

                    delete_attribute(child, UhdmAst::unpacked_ranges());
                    child->attributes[UhdmAst::unpacked_ranges()] = (*it)->attributes[UhdmAst::unpacked_ranges()]->clone();
                }
            }
            // Surelog doesn't report correct sign value for param_assign nodes
            // and only default vpiParameter node have correct sign value, so
            // if we are overriding parameter, copy sign value from current node to the new node
            if (((*it)->type == AST::AST_PARAMETER || (*it)->type == AST::AST_LOCALPARAM) && child->children.size() && (*it)->children.size()) {
                child->children[0]->is_signed = (*it)->children[0]->is_signed;
            }
            delete *it;
            *it = child;
            return;
        }
        parent->children.push_back(child);
    } else if (child->type == AST::AST_INITIAL) {
        // Special case for initials
        // Ensure that there is only one AST_INITIAL in the design
        // And there is only one AST_BLOCK inside that initial
        // Copy nodes from child initial to parent initial
        auto initial_node_it =
          find_if(parent->children.begin(), parent->children.end(), [](AST::AstNode *node) { return (node->type == AST::AST_INITIAL); });
        if (initial_node_it != parent->children.end()) {
            AST::AstNode *initial_node = *initial_node_it;

            // simplify assumes that initial has a block under it
            // In case we don't have one (there were no statements under the initial), let's add it
            if (initial_node->children.empty()) {
                initial_node->children.push_back(new AST::AstNode(AST::AST_BLOCK));
            }

            log_assert(initial_node->children[0]->type == AST::AST_BLOCK);
            log_assert(!(child->children.empty()));
            log_assert(child->children[0]->type == AST::AST_BLOCK);

            AST::AstNode *block_node = initial_node->children[0];
            AST::AstNode *child_block_node = child->children[0];

            // Place the contents of child block node inside parent block
            for (auto child_block_child : child_block_node->children)
                block_node->children.push_back(child_block_child->clone());
            // Place the remaining contents of child initial node inside the parent initial
            for (auto initial_child = child->children.begin() + 1; initial_child != child->children.end(); ++initial_child) {
                initial_node->children.push_back((*initial_child)->clone());
            }
            delete child;
        } else {
            // Parent AST_INITIAL does not exist
            // Place child AST_INITIAL before AST_ALWAYS if found
            auto insert_it =
              find_if(parent->children.begin(), parent->children.end(), [](AST::AstNode *node) { return (node->type == AST::AST_ALWAYS); });
            parent->children.insert(insert_it, 1, child);
        }
    } else {
        parent->children.push_back(child);
    }
}

void UhdmAst::make_cell(vpiHandle obj_h, AST::AstNode *cell_node, std::string type)
{
    if (cell_node->children.empty() || (!cell_node->children.empty() && cell_node->children[0]->type != AST::AST_CELLTYPE)) {
        auto typeNode = new AST::AstNode(AST::AST_CELLTYPE);
        typeNode->str = type;
        cell_node->children.insert(cell_node->children.begin(), typeNode);
    }
    // Add port connections as arguments
    vpiHandle port_itr = vpi_iterate(vpiPort, obj_h);
    while (vpiHandle port_h = vpi_scan(port_itr)) {
        std::string arg_name;
        if (auto s = vpi_get_str(vpiName, port_h)) {
            arg_name = s;
            sanitize_symbol_name(arg_name);
        }
        auto arg_node = new AST::AstNode(AST::AST_ARGUMENT);
        arg_node->str = arg_name;
        arg_node->filename = cell_node->filename;
        arg_node->location = cell_node->location;
        visit_one_to_one({vpiHighConn}, port_h, [&](AST::AstNode *node) {
            if (node) {
                if (node->type == AST::AST_PARAMETER || node->type == AST::AST_LOCALPARAM) {
                    node->type = AST::AST_IDENTIFIER;
                }
                arg_node->children.push_back(node);
            }
        });
        cell_node->children.push_back(arg_node);
        vpi_release_handle(port_h);
    }
    vpi_release_handle(port_itr);
}

void UhdmAst::move_type_to_new_typedef(AST::AstNode *current_node, AST::AstNode *type_node)
{
    auto typedef_node = new AST::AstNode(AST::AST_TYPEDEF);
    typedef_node->location = type_node->location;
    typedef_node->filename = type_node->filename;
    typedef_node->str = strip_package_name(type_node->str);
    for (auto c : current_node->children) {
        if (c->str == typedef_node->str) {
            delete typedef_node;
            delete type_node;
            return;
        }
    }
    if (type_node->type == AST::AST_STRUCT) {
        type_node->str.clear();
        typedef_node->children.push_back(type_node);
        current_node->children.push_back(typedef_node);
    } else if (type_node->type == AST::AST_ENUM) {
        if (type_node->attributes.count("\\enum_base_type")) {
            auto base_type = type_node->attributes["\\enum_base_type"];
            auto wire_node = new AST::AstNode(AST::AST_WIRE);
            wire_node->is_reg = true;
            for (auto c : base_type->children) {
                std::string enum_item_str = "\\enum_value_";
                log_assert(!c->children.empty());
                log_assert(c->children[0]->type == AST::AST_CONSTANT);
                int width = 1;
                bool is_signed = c->children[0]->is_signed;
                if (c->children.size() == 2) {
                    width = c->children[1]->children[0]->integer + 1;
                }
                RTLIL::Const val = c->children[0]->bitsAsConst(width, is_signed);
                enum_item_str.append(val.as_string());
                wire_node->attributes[enum_item_str.c_str()] = AST::AstNode::mkconst_str(c->str);
            }
            typedef_node->children.push_back(wire_node);
            current_node->children.push_back(typedef_node);
            delete type_node;
        } else {
            type_node->str = "$enum" + std::to_string(shared.next_enum_id());
            std::vector<AST::AstNode *> packed_ranges;
            auto wire_node = new AST::AstNode(AST::AST_WIRE);
            wire_node->is_reg = true;
            wire_node->attributes["\\enum_type"] = AST::AstNode::mkconst_str(type_node->str);
            if (!type_node->children.empty() && type_node->children[0]->children.size() > 1) {
                packed_ranges.push_back(type_node->children[0]->children[1]->clone());
            } else {
                // Add default range
                packed_ranges.push_back(make_range(31, 0));
            }
            add_multirange_wire(wire_node, std::move(packed_ranges), {});
            typedef_node->children.push_back(wire_node);
            current_node->children.push_back(type_node);
            current_node->children.push_back(typedef_node);
        }
    } else {
        type_node->str.clear();
        typedef_node->children.push_back(type_node);
        current_node->children.push_back(typedef_node);
    }
}

AST::AstNode *UhdmAst::find_ancestor(const std::unordered_set<AST::AstNodeType> &types)
{
    auto searched_node = this;
    while (searched_node) {
        if (searched_node->current_node) {
            if (types.find(searched_node->current_node->type) != types.end()) {
                return searched_node->current_node;
            }
        }
        searched_node = searched_node->parent;
    }
    return nullptr;
}

void UhdmAst::process_design()
{
    current_node = make_ast_node(AST::AST_DESIGN);
    AST::AstNode *old_design = shared.current_design;
    shared.current_design = current_node;
    visit_one_to_many({UHDM::uhdmallInterfaces, UHDM::uhdmtopPackages, UHDM::uhdmtopModules, vpiTaskFunc}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            shared.top_nodes[node->str] = node;
        }
    });
    visit_one_to_many({vpiTypedef}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            for (auto pair : shared.top_nodes) {
                move_type_to_new_typedef(pair.second, node->clone());
            }
            delete node;
        }
    });
    visit_one_to_many({vpiParameter, vpiParamAssign}, obj_h, [&](AST::AstNode *node) {
        if (!get_attribute(node, attr_id::is_type_parameter)) {
            // Don't process type parameters.
            for (auto pair : shared.top_nodes) {
                add_or_replace_child(pair.second, node->clone());
            }
        }
        delete node;
    });
    // Add top level typedefs and params to scope
    setup_current_scope(shared.top_nodes, current_node);
    for (auto pair : shared.top_nodes) {
        if (!pair.second)
            continue;
        if (pair.second->type == AST::AST_PACKAGE) {
            check_memories(pair.second);
            clear_current_scope();
            setup_current_scope(shared.top_nodes, pair.second);
            simplify_sv(pair.second, nullptr);
            clear_current_scope();
        }
    }
    setup_current_scope(shared.top_nodes, current_node);
    // Once we walked everything, unroll that as children of this node
    for (auto &pair : shared.top_nodes) {
        if (!pair.second)
            continue;
        if (!pair.second->get_bool_attribute(ID::blackbox)) {
            if (pair.second->type == AST::AST_PACKAGE)
                current_node->children.insert(current_node->children.begin(), pair.second);
            else {
                check_memories(pair.second);
                setup_current_scope(shared.top_nodes, pair.second);
                simplify_sv(pair.second, nullptr);
                clear_current_scope();
                current_node->children.push_back(pair.second);
            }
        } else {
            // TODO: This should be properly erased from the module, but it seems that it's
            // needed to resolve scope
            delete pair.second;
            pair.second = nullptr;
        }
    }
    shared.current_design = old_design;
}

void UhdmAst::simplify_parameter(AST::AstNode *parameter, const std::vector<::Yosys::AST::AstNode *> &parameter_scopes)
{
    setup_current_scope(shared.top_nodes, shared.current_top_node);
    visitEachDescendant(shared.current_top_node, [&](AST::AstNode *current_scope_node) {
        if (current_scope_node->type == AST::AST_TYPEDEF || current_scope_node->type == AST::AST_PARAMETER ||
            current_scope_node->type == AST::AST_LOCALPARAM || current_scope_node->type == AST::AST_FUNCTION) {
            AST_INTERNAL::current_scope[current_scope_node->str] = current_scope_node;
        }
    });
    for (AST::AstNode *const scope : parameter_scopes) {
        visitEachDescendant(scope, [&](AST::AstNode *current_scope_node) {
            if (current_scope_node->type == AST::AST_TYPEDEF || current_scope_node->type == AST::AST_PARAMETER ||
                current_scope_node->type == AST::AST_LOCALPARAM || current_scope_node->type == AST::AST_FUNCTION) {
                AST_INTERNAL::current_scope[current_scope_node->str] = current_scope_node;
            }
        });
    }
    // first apply custom simplification step if needed
    simplify_sv(parameter, nullptr);
    // workaround for yosys sometimes not simplifying parameters children
    // parameters can have 2 children:
    // first child should be parameter value
    // second child should be parameter range (optional)
    log_assert(!parameter->children.empty());
    simplify_sv(parameter->children[0], parameter);
    while (simplify(parameter->children[0], true, false, false, 1, -1, false, false)) {
    }
    // follow id2ast as yosys doesn't do it by default
    if (parameter->children[0]->id2ast) {
        simplify_sv(parameter->children[0]->id2ast, parameter);
        while (simplify(parameter->children[0]->id2ast, true, false, false, 1, -1, false, false)) {
        }
    }
    if (parameter->children.size() > 1) {
        simplify_sv(parameter->children[1], parameter);
        while (simplify(parameter->children[1], true, false, false, 1, -1, false, false)) {
        }
        if (parameter->children[1]->id2ast) {
            simplify_sv(parameter->children[1]->id2ast, parameter);
            while (simplify(parameter->children[1]->id2ast, true, false, false, 1, -1, false, false)) {
            }
        }
    }
    // then simplify parameter to AST_CONSTANT or AST_REALVALUE
    while (simplify(parameter, true, false, false, 1, -1, false, false)) {
    }
    clear_current_scope();
}

void UhdmAst::process_module()
{
    std::string type = vpi_get_str(vpiDefName, obj_h);
    std::string name = vpi_get_str(vpiName, obj_h) ? vpi_get_str(vpiName, obj_h) : type;
    // when Surelog doesn't have definition of module while parsing design
    // it sets type to work@top_module::cell_type, otherwise it is just work@cell_type
    bool is_blackbox = type.find("::") != std::string::npos;
    bool is_top_module = type == name;
    sanitize_symbol_name(type);
    sanitize_symbol_name(name);
    type = strip_package_name(type);
    name = strip_package_name(name);
    if (is_blackbox) {
        current_node = make_ast_node(AST::AST_CELL);
        visit_one_to_many({vpiParamAssign}, obj_h, [&](AST::AstNode *node) {
            node->type = AST::AST_PARASET;
            current_node->children.push_back(node);
        });
        make_cell(obj_h, current_node, type);
        return;
    }
    current_node = make_ast_node(AST::AST_MODULE);
    AST::AstNode *module_node = current_node;
    const uhdm_handle *const handle = (const uhdm_handle *)obj_h;
    const auto *const uhdm_obj = (const UHDM::any *)handle->object;
    const auto current_instance_changer = ScopedValueChanger(shared.current_instance, uhdm_obj);
    // process nodes for parameter evaluation
    std::vector<std::pair<RTLIL::IdString, RTLIL::Const>> parameters;
    auto parameter_typedefs = make_unique_resource<std::vector<AST::AstNode *>>();

    visit_one_to_many({vpiTypedef}, obj_h, [&](AST::AstNode *node) { move_type_to_new_typedef(current_node, node); });
    visit_one_to_many({vpiTaskFunc}, obj_h, [&](AST::AstNode *node) { add_or_replace_child(current_node, node); });
    visit_one_to_many({vpiParameter}, obj_h, [&](AST::AstNode *node) {
        auto attr = get_attribute(node, attr_id::is_type_parameter);
        if (!attr) {
            // process only type parameters
            delete node;
            return;
        }
        if (node->children.size() == 0) {
            log_assert(!attr->str.empty());
            // Anonymous types have no children, and store the parameter name in attr->str.
            parameters.push_back(std::make_pair(node->str, attr->str));
            delete node;
            return;
        }

        for (auto child : node->children) {
            if (child->type == AST::AST_TYPEDEF && !child->str.empty()) {
                // process_type_parameter should have created a node with the parameter name
                //   and a child with the name of the value assigned to the parameter.
                parameters.push_back(std::make_pair(node->str, child->str));
            }

            if (child->type == AST::AST_TYPEDEF || child->type == AST::AST_ENUM) {
                // Copy definition of the type provided as parameter.
                parameter_typedefs->push_back(child->clone());
            }
        }
        delete node;
    });
    visit_one_to_many({vpiParamAssign}, obj_h, [&](AST::AstNode *node) {
        if (node->children[0]->type != AST::AST_CONSTANT) {
            simplify_parameter(node, {current_node, shared.current_top_node});
        }
        log_assert(node->children[0]->type == AST::AST_CONSTANT || node->children[0]->type == AST::AST_REALVALUE);
        parameters.push_back(std::make_pair(node->str, node->children[0]->asParaConst()));
        add_or_replace_child(current_node, node);
    });
    if (!is_top_module) {
        std::string module_name = ((!parameters.empty()) && (!is_blackbox)) ? AST::derived_module_name(type, parameters).c_str() : type;
        type = module_name;
        current_node->str = type;
        if (shared.top_nodes.find(type) != shared.top_nodes.end()) {
            delete current_node;
            current_node = make_ast_node(AST::AST_CELL);
            make_cell(obj_h, current_node, type);
            return;
        }
        module_node->children.insert(std::end(module_node->children), std::begin(*parameter_typedefs), std::end(*parameter_typedefs));
        parameter_typedefs->clear();
        parameter_typedefs.reset();
    }
    const auto old_top = shared.current_top_node;
    const auto current_top_node_changer = ScopedValueChanger(shared.current_top_node, current_node);
    shared.top_nodes[type] = current_node;
    visit_one_to_many({vpiInterface, vpiTaskFunc, vpiVariables, vpiPort, vpiNet, vpiArrayNet, vpiGenScopeArray, vpiProcess, vpiContAssign, vpiModule},
                      obj_h, [&](AST::AstNode *node) { add_or_replace_child(current_node, node); });
    // move process to the end of the module
    auto process_it = std::find_if(current_node->children.begin(), current_node->children.end(),
                                   [](auto node) { return node->type == AST::AST_INITIAL || node->type == AST::AST_ALWAYS; });
    if (process_it != current_node->children.end()) {
        auto proc = *process_it;
        current_node->children.erase(process_it);
        current_node->children.insert(current_node->children.end(), proc);
    }
    iterate_one_to_many({vpiAttribute}, obj_h, [&](vpiHandle h) {
        std::string name = vpi_get_str(vpiName, h);
        if (name == "blackbox")
            current_node->attributes[ID::blackbox] = AST::AstNode::mkconst_int(1, false, 32);
    });

    // Primitives will have the same names (like "and"), so we need to make sure we don't replace them
    visit_one_to_many({vpiPrimitive}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->children.push_back(node);
        }
    });

    if (!is_top_module) {
        current_node = make_ast_node(AST::AST_CELL);
        make_cell(obj_h, current_node, module_node->str);
    }
}

void UhdmAst::process_struct_typespec()
{
    current_node = make_ast_node(AST::AST_STRUCT);
    visit_one_to_many({vpiTypespecMember}, obj_h, [&](AST::AstNode *node) {
        if (node->children.size() > 0 && node->children[0]->type == AST::AST_ENUM) {
            log_assert(node->children.size() == 1);
            log_assert(!node->children[0]->children.empty());
            log_assert(!node->children[0]->children[0]->children.empty());
            // TODO: add missing enum_type attribute
            AST::AstNode *range = nullptr;
            // check if single enum element is larger than 1 bit
            if (node->children[0]->children[0]->children.size() == 2) {
                range = node->children[0]->children[0]->children[1]->clone();
            } else {
                range = make_range(0, 0);
            }
            delete_children(node);
            node->children.push_back(range);
        }
        current_node->children.push_back(node);
    });
}

void UhdmAst::process_union_typespec()
{
    current_node = make_ast_node(AST::AST_UNION);
    visit_one_to_many({vpiTypespecMember}, obj_h, [&](AST::AstNode *node) {
        if (node->children.size() > 0 && node->children[0]->type == AST::AST_ENUM) {
            log_assert(node->children.size() == 1);
            log_assert(!node->children[0]->children.empty());
            log_assert(!node->children[0]->children[0]->children.empty());
            // TODO: add missing enum_type attribute
            AST::AstNode *range = nullptr;
            // check if single enum element is larger than 1 bit
            if (node->children[0]->children[0]->children.size() == 2) {
                range = node->children[0]->children[0]->children[1]->clone();
            } else {
                range = make_range(0, 0);
            }
            delete_children(node);
            node->children.push_back(range);
        }
        current_node->children.push_back(node);
    });
}

void UhdmAst::process_array_typespec()
{
    current_node = make_ast_node(AST::AST_WIRE);
    std::vector<AST::AstNode *> packed_ranges;
    std::vector<AST::AstNode *> unpacked_ranges;
    visit_one_to_one({vpiElemTypespec}, obj_h, [&](AST::AstNode *node) {
        if (node && node->type == AST::AST_STRUCT) {
            auto str = current_node->str;
            node->cloneInto(current_node);
            current_node->str = str;
            delete node;
        }
    });
    if (auto ref_elemtypespec_h = vpi_handle(vpiElemTypespec, obj_h)) {
        if (auto elemtypespec_h = vpi_handle(vpiActual, ref_elemtypespec_h)) {
            visit_one_to_many({vpiRange}, elemtypespec_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
            vpi_release_handle(elemtypespec_h);
        }
        vpi_release_handle(ref_elemtypespec_h);
    }
    visit_one_to_many({vpiRange}, obj_h, [&](AST::AstNode *node) { unpacked_ranges.push_back(node); });
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
}

void UhdmAst::process_typespec_member()
{
    std::vector<AST::AstNode *> packed_ranges;
    std::vector<AST::AstNode *> unpacked_ranges;
    current_node = make_ast_node(AST::AST_STRUCT_ITEM);
    current_node->str = current_node->str.substr(1);
    vpiHandle ref_typespec_h = vpi_handle(vpiTypespec, obj_h);
    vpiHandle typespec_h = vpi_handle(vpiActual, ref_typespec_h);
    int typespec_type = vpi_get(vpiType, typespec_h);
    const uhdm_handle *const handle = (const uhdm_handle *)typespec_h;
    const UHDM::BaseClass *const object = (const UHDM::BaseClass *)handle->object;
    switch (typespec_type) {
    case vpiBitTypespec:
    case vpiLogicTypespec: {
        current_node->is_logic = true;
        visit_one_to_many({vpiRange}, typespec_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
        if (auto ref_elemtypespec_h = vpi_handle(vpiElemTypespec, typespec_h)) {
            if (auto elemtypespec_h = vpi_handle(vpiActual, ref_elemtypespec_h)) {
                visit_one_to_many({vpiRange}, elemtypespec_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
                vpi_release_handle(elemtypespec_h);
            }
            vpi_release_handle(ref_elemtypespec_h);
        }
        break;
    }
    case vpiByteTypespec: {
        current_node->is_signed = vpi_get(vpiSigned, typespec_h);
        packed_ranges.push_back(make_range(7, 0));
        break;
    }
    case vpiShortIntTypespec: {
        current_node->is_signed = vpi_get(vpiSigned, typespec_h);
        packed_ranges.push_back(make_range(15, 0));
        break;
    }
    case vpiIntTypespec:
    case vpiIntegerTypespec: {
        current_node->is_signed = vpi_get(vpiSigned, typespec_h);
        packed_ranges.push_back(make_range(31, 0));
        break;
    }
    case vpiTimeTypespec:
    case vpiLongIntTypespec: {
        current_node->is_signed = vpi_get(vpiSigned, typespec_h);
        packed_ranges.push_back(make_range(63, 0));
        break;
    }
    case vpiStructTypespec:
    case vpiUnionTypespec:
    case vpiEnumTypespec: {
        visit_one_to_one({vpiTypespec}, obj_h, [&](AST::AstNode *node) {
            if (typespec_type == vpiStructTypespec || typespec_type == vpiUnionTypespec) {
                auto str = current_node->str;
                node->cloneInto(current_node);
                current_node->str = str;
                delete node;
            } else if (typespec_type == vpiEnumTypespec) {
                current_node->children.push_back(node);
            } else {
                delete node;
            }
        });
        break;
    }
    case vpiPackedArrayTypespec:
        visit_one_to_one({vpiTypespec}, obj_h, [&](AST::AstNode *node) {
            if (node && node->type == AST::AST_STRUCT) {
                auto str = current_node->str;
                if (node->attributes.count(UhdmAst::packed_ranges())) {
                    for (auto r : node->attributes[UhdmAst::packed_ranges()]->children) {
                        packed_ranges.push_back(r->clone());
                    }
                    delete_attribute(node, UhdmAst::packed_ranges());
                }
                if (node->attributes.count(UhdmAst::unpacked_ranges())) {
                    for (auto r : node->attributes[UhdmAst::unpacked_ranges()]->children) {
                        unpacked_ranges.push_back(r->clone());
                    }
                    delete_attribute(node, UhdmAst::unpacked_ranges());
                }
                node->cloneInto(current_node);
                current_node->str = str;
                current_node->children.insert(current_node->children.end(), packed_ranges.begin(), packed_ranges.end());
                packed_ranges.clear();
                delete node;
            } else if (node) {
                auto str = current_node->str;
                if (node->attributes.count(UhdmAst::packed_ranges())) {
                    for (auto r : node->attributes[UhdmAst::packed_ranges()]->children) {
                        packed_ranges.push_back(r->clone());
                    }
                    delete_attribute(node, UhdmAst::packed_ranges());
                }
                if (node->attributes.count(UhdmAst::unpacked_ranges())) {
                    for (auto r : node->attributes[UhdmAst::unpacked_ranges()]->children) {
                        unpacked_ranges.push_back(r->clone());
                    }
                    delete_attribute(node, UhdmAst::unpacked_ranges());
                }
                node->cloneInto(current_node);
                current_node->str = str;
                current_node->type = AST::AST_STRUCT_ITEM;
                delete node;
            }
        });
        break;
    case vpiVoidTypespec: {
        report_error("%.*s:%d: Void typespecs are currently unsupported", (int)object->VpiFile().length(), object->VpiFile().data(),
                     object->VpiLineNo());
        break;
    }
    case vpiClassTypespec: {
        report_error("%.*s:%d: Class typespecs are unsupported", (int)object->VpiFile().length(), object->VpiFile().data(), object->VpiLineNo());
        break;
    }
    default: {
        report_error("%.*s:%d: Encountered unhandled typespec in process_typespec_member: '%.*s' of type '%s'\n", (int)object->VpiFile().length(),
                     object->VpiFile().data(), object->VpiLineNo(), (int)object->VpiName().length(), object->VpiName().data(),
                     UHDM::VpiTypeName(typespec_h).c_str());
        break;
    }
    }
    vpi_release_handle(typespec_h);
    vpi_release_handle(ref_typespec_h);
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
}

static UHDM::expr *reduce_expression(const UHDM::any *expr, const UHDM::any *inst, const UHDM::any *pexpr)
{
    log_assert(expr);
    log_assert(inst);

    bool invalidvalue = false;
    UHDM::ExprEval eval;
    UHDM::expr *resolved_operation = eval.reduceExpr(expr, invalidvalue, inst, pexpr);
    if (invalidvalue) {
        log_file_warning(std::string(expr->VpiFile()), expr->VpiLineNo(), "Could not reduce expression.\n");
    }
    return resolved_operation;
}

void UhdmAst::process_enum_typespec()
{
    // BaseTypespec specifies underlying type of the enum.
    // The BaseTypespec has at most one explicit packed dimension (range).
    // When base type is not specified in SystemVerilog code, it is assumed to be an int.
    // Type of enum items (constants) is the same as the enum type.
    current_node = make_ast_node(AST::AST_ENUM);

    const uhdm_handle *const handle = (const uhdm_handle *)obj_h;
    const auto *enum_object = (const UHDM::enum_typespec *)handle->object;
    const auto *ref_typespec = enum_object->Base_typespec();
    const auto *typespec = ref_typespec ? ref_typespec->Actual_typespec() : nullptr;

    if (current_node->str.empty()) {
        // anonymous typespec, check if not already created
        log_assert(shared.current_top_node);
        auto check_created_anonymous_enums = [enum_object, this](std::string top_module_name) -> bool {
            for (auto pair : shared.anonymous_enums[top_module_name]) {
                UHDM::CompareContext ctx;
                if (pair.first->Compare(enum_object, &ctx) == 0) {
                    // we already created typedef for this.
                    delete current_node;
                    current_node = make_node(AST::AST_WIRETYPE);
                    current_node->str = pair.second;
                    return true;
                }
            }
            return false;
        };
        std::string top_module_name = shared.current_top_node->str;
        if (check_created_anonymous_enums(top_module_name)) {
            return;
        }
        // in case of parametrized module, also check unparametrized top module
        // as we could add this enum there and then copy it to parametrized
        // version
        if (top_module_name.find("$paramod") != std::string::npos) {
            // possible names:
            // $paramod\module_name\PARAM=VAL
            // $paramod$81af6bf473845aee480c993b90a1ed0117ae9091\module_name
            top_module_name = top_module_name.substr(top_module_name.find("\\"));
            if (auto params = top_module_name.find("\\", 1 /* skip first \ */) != std::string::npos)
                top_module_name = top_module_name.substr(0, params);
        }
        if (check_created_anonymous_enums(top_module_name)) {
            return;
        }
    }

    if (typespec && typespec->UhdmType() == UHDM::uhdmlogic_typespec) {
        // If it's a logic_typespec, try to reduce expressions inside of it.
        // The `reduceExpr` function needs the whole context of the enum typespec
        //   so it's called here instead of `process_operation` or any other more specific function.

        const UHDM::logic_typespec *logic_typespec_obj = enum_object->Base_typespec()->Actual_typespec()->Cast<const UHDM::logic_typespec *>();
        std::vector<UHDM::range *> ranges;
        // Check if ranges exist, as Ranges() returns a pointer to std::vector.
        if (logic_typespec_obj->Ranges()) {
            ranges = *(logic_typespec_obj->Ranges());
        }
        for (UHDM::range *range_obj : ranges) {
            // For each range, take both left and right and reduce them if they're of type uhdmoperation.
            const auto *leftrange_obj = range_obj->Left_expr();
            const auto *rightrange_obj = range_obj->Right_expr();
            log_assert(leftrange_obj);
            log_assert(rightrange_obj);

            if (leftrange_obj->UhdmType() == UHDM::uhdmoperation) {
                // Substitute the previous leftrange with the resolved operation result.
                const UHDM::any *const instance = enum_object->Instance()    ? enum_object->Instance()
                                                  : enum_object->VpiParent() ? enum_object->VpiParent()
                                                                             : shared.current_instance;

                range_obj->Left_expr(reduce_expression(leftrange_obj, instance, enum_object->VpiParent()));
            }
            if (rightrange_obj->UhdmType() == UHDM::uhdmoperation) {
                // Substitute the previous rightrange with the resolved operation result.
                const UHDM::any *const instance = enum_object->Instance()    ? enum_object->Instance()
                                                  : enum_object->VpiParent() ? enum_object->VpiParent()
                                                                             : shared.current_instance;

                range_obj->Right_expr(reduce_expression(rightrange_obj, instance, enum_object->VpiParent()));
            }
        }
    }

    bool has_base_type = false;
    visit_one_to_one({vpiBaseTypespec}, obj_h, [&](AST::AstNode *node) {
        has_base_type = true;
        current_node->children = std::move(node->children);
        current_node->attributes = std::move(node->attributes);
        current_node->is_signed = node->is_signed;
        current_node->is_logic = node->is_logic;
        delete node;
    });
    if (!has_base_type) {
        // Base typespec is `int` by default
        // TODO (mglb): This is almost the same code as in `process_int_typespec()`. Put common code in dedicated function.
        std::vector<AST::AstNode *> packed_ranges;
        packed_ranges.push_back(make_range(31, 0));
        add_multirange_wire(current_node, std::move(packed_ranges), {});
        current_node->is_signed = true;
    }
    // We have to restore node's range_* properties if there's no range.
    const auto range_left = current_node->range_left;
    const auto range_right = current_node->range_right;
    const auto range_valid = current_node->range_valid;
    // Create a range from the typespec just for the purpose of copying it to consts.
    convert_packed_unpacked_range(current_node);
    const auto range_it = std::find_if(current_node->children.cbegin(), current_node->children.cend(),
                                       [](const AST::AstNode *n) { return n->type == AST::AST_RANGE || n->type == AST::AST_MULTIRANGE; });
    const auto *const range = range_it != current_node->children.cend() ? *range_it : nullptr;
    if (range) {
        current_node->children.erase(range_it);
    } else {
        current_node->range_left = range_left;
        current_node->range_right = range_right;
        current_node->range_valid = range_valid;
    }

    visit_one_to_one({vpiTypedefAlias}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->attributes["\\enum_base_type"] = node;
        }
    });
    visit_one_to_many({vpiEnumConst}, obj_h, [&](AST::AstNode *node) {
        // Enum const must have the same type and ranges as the enum.
        node->is_logic = current_node->is_logic;
        node->is_signed = current_node->is_signed;
        if (range) {
            node->children.push_back(range->clone());
            node->range_valid = true;
        } else {
            node->range_left = range_left;
            node->range_right = range_right;
            node->range_valid = range_valid;
        }
        // IMPORTANT: invalidates `range_it`!
        current_node->children.push_back(node);
    });
    if (range) {
        delete range;
    }
    if (current_node->str.empty()) {
        // anonymous typespec
        std::string typedef_name = "$systemverilog_plugin$anonymous_enum" + std::to_string(shared.next_anonymous_enum_typedef_id());
        current_node->str = typedef_name;
        uhdmast_assert(shared.current_top_node != nullptr);
        move_type_to_new_typedef(shared.current_top_node, current_node);
        current_node = make_node(AST::AST_WIRETYPE);
        current_node->str = typedef_name;
        shared.anonymous_enums[shared.current_top_node->str][enum_object] = std::move(typedef_name);
    }
}

void UhdmAst::process_enum_const()
{
    current_node = make_ast_node(AST::AST_ENUM_ITEM);
    AST::AstNode *constant_node = process_value(obj_h);
    if (constant_node) {
        constant_node->filename = current_node->filename;
        constant_node->location = current_node->location;
        current_node->children.push_back(constant_node);
    }
}

void UhdmAst::process_custom_var()
{
    current_node = make_ast_node(AST::AST_WIRE);
    visit_one_to_one({vpiTypespec}, obj_h, [&](AST::AstNode *node) {
        if (node->str.empty()) {
            // anonymous typespec, move the children to variable
            current_node->type = node->type;
            copy_packed_unpacked_attribute(node, current_node);
            current_node->children = std::move(node->children);
        } else {
            auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
            wiretype_node->str = node->str;
            current_node->children.push_back(wiretype_node);
        }
        delete node;
    });
    auto type = vpi_get(vpiType, obj_h);
    if (type == vpiEnumVar || type == vpiStructVar || type == vpiUnionVar) {
        visit_default_expr(obj_h);
    }
    current_node->is_custom_type = true;
}

void UhdmAst::process_int_var()
{
    current_node = make_ast_node(AST::AST_WIRE);
    std::vector<AST::AstNode *> packed_ranges;
    std::vector<AST::AstNode *> unpacked_ranges;
    packed_ranges.push_back(make_range(31, 0));
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
    visit_default_expr(obj_h);
}

void UhdmAst::process_real_var()
{
    auto module_node = find_ancestor({AST::AST_MODULE});
    auto wire_node = make_ast_node(AST::AST_WIRE);
    auto left_const = AST::AstNode::mkconst_int(63, true);
    auto right_const = AST::AstNode::mkconst_int(0, true);
    auto range = new AST::AstNode(AST::AST_RANGE, left_const, right_const);
    wire_node->children.push_back(range);
    wire_node->is_signed = true;
    module_node->children.push_back(wire_node);
    current_node = make_ast_node(AST::AST_IDENTIFIER);
    visit_default_expr(obj_h);
}

void UhdmAst::process_array_var()
{
    current_node = make_ast_node(AST::AST_WIRE);
    std::vector<AST::AstNode *> packed_ranges;
    std::vector<AST::AstNode *> unpacked_ranges;
    visit_one_to_one({vpiTypespec}, obj_h, [&](AST::AstNode *node) {
        if (node->str.empty()) {
            // anonymous typespec, move the children to variable
            copy_packed_unpacked_attribute(node, current_node);
        } else {
            auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
            wiretype_node->str = node->str;
            //  wiretype needs to be 1st node
            current_node->children.insert(current_node->children.begin(), wiretype_node);
            current_node->is_custom_type = true;
        }
        delete node;
    });
    iterate_one_to_many({vpiAttribute}, obj_h, [&](vpiHandle h) {
        std::string name = vpi_get_str(vpiName, h);
        if (name == "keep")
            current_node->attributes[ID::keep] = AST::AstNode::mkconst_int(1, false, 32);
    });
    vpiHandle itr = vpi_iterate(vpi_get(vpiType, obj_h) == vpiArrayVar ? vpiReg : vpiElement, obj_h);
    while (vpiHandle reg_h = vpi_scan(itr)) {
        if (vpi_get(vpiType, reg_h) == vpiStructVar || vpi_get(vpiType, reg_h) == vpiEnumVar) {
            visit_one_to_one({vpiTypespec}, reg_h, [&](AST::AstNode *node) {
                if (node->str.empty()) {
                    // anonymous typespec, move the children to variable
                    current_node->type = node->type;
                    current_node->children = std::move(node->children);
                } else {
                    auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
                    wiretype_node->str = node->str;
                    current_node->children.push_back(wiretype_node);
                    current_node->is_custom_type = true;
                }
                delete node;
            });
        } else if (vpi_get(vpiType, reg_h) == vpiLogicVar) {
            current_node->is_logic = true;
            visit_one_to_one({vpiTypespec}, reg_h, [&](AST::AstNode *node) {
                if (node->str.empty()) {
                    // anonymous typespec, move the children to variable
                    current_node->type = node->type;
                    current_node->children = std::move(node->children);
                    if (node->attributes.count(UhdmAst::packed_ranges())) {
                        for (auto r : node->attributes[UhdmAst::packed_ranges()]->children) {
                            packed_ranges.push_back(r->clone());
                        }
                    }
                } else {
                    auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
                    wiretype_node->str = node->str;
                    current_node->children.push_back(wiretype_node);
                    current_node->is_custom_type = true;
                }
                delete node;
            });
            visit_one_to_many({vpiRange}, reg_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
        } else if (vpi_get(vpiType, reg_h) == vpiIntVar) {
            packed_ranges.push_back(make_range(31, 0));
            visit_default_expr(reg_h);
        } else if (vpi_get(vpiType, reg_h) == vpiPackedArrayVar) {
            vpiHandle itr2 = vpi_iterate(vpi_get(vpiType, reg_h) == vpiArrayVar ? vpiReg : vpiElement, reg_h);
            while (vpiHandle reg_h2 = vpi_scan(itr2)) {
                auto vpi_obj = vpi_get(vpiType, reg_h2);
                if (vpi_obj == vpiStructVar || vpi_obj == vpiEnumVar || vpi_obj == vpiLogicVar) {
                    if (vpi_obj == vpiLogicVar)
                        current_node->is_logic = true;
                    visit_one_to_one({vpiTypespec}, reg_h2, [&](AST::AstNode *node) {
                        if (node->str.empty()) {
                            // anonymous typespec, move the children to variable
                            current_node->type = node->type;
                            current_node->children = std::move(node->children);
                        } else {
                            auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
                            wiretype_node->str = node->str;
                            current_node->children.push_back(wiretype_node);
                            current_node->is_custom_type = true;
                        }
                        delete node;
                    });
                }
                vpi_release_handle(reg_h2);
                visit_one_to_many({vpiRange}, reg_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
            }
            vpi_release_handle(itr2);
        }
        vpi_release_handle(reg_h);
    }
    vpi_release_handle(itr);
    visit_one_to_many({vpiRange}, obj_h, [&](AST::AstNode *node) { unpacked_ranges.push_back(node); });
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
    visit_default_expr(obj_h);
}

void UhdmAst::process_packed_array_var()
{
    current_node = make_ast_node(AST::AST_WIRE);
    std::vector<AST::AstNode *> packed_ranges;
    std::vector<AST::AstNode *> unpacked_ranges;
    visit_one_to_one({vpiTypespec}, obj_h, [&](AST::AstNode *node) {
        if (node->str.empty()) {
            // anonymous typespec, move the children to variable
            current_node->type = node->type;
            current_node->children = std::move(node->children);
        } else {
            auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
            wiretype_node->str = node->str;
            current_node->children.push_back(wiretype_node);
            current_node->is_custom_type = true;
        }
        delete node;
    });
    vpiHandle itr = vpi_iterate(vpi_get(vpiType, obj_h) == vpiArrayVar ? vpiReg : vpiElement, obj_h);
    while (vpiHandle reg_h = vpi_scan(itr)) {
        if (vpi_get(vpiType, reg_h) == vpiStructVar || vpi_get(vpiType, reg_h) == vpiEnumVar) {
            visit_one_to_one({vpiTypespec}, reg_h, [&](AST::AstNode *node) {
                if (node->str.empty()) {
                    // anonymous typespec, move the children to variable
                    current_node->type = node->type;
                    current_node->children = std::move(node->children);
                } else {
                    auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
                    wiretype_node->str = node->str;
                    current_node->children.push_back(wiretype_node);
                    current_node->is_custom_type = true;
                }
                delete node;
            });
        } else if (vpi_get(vpiType, reg_h) == vpiLogicVar) {
            current_node->is_logic = true;
            visit_one_to_one({vpiTypespec}, reg_h, [&](AST::AstNode *node) {
                if (node->str.empty()) {
                    // anonymous typespec, move the children to variable
                    current_node->type = node->type;
                    current_node->children = std::move(node->children);
                } else {
                    auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
                    wiretype_node->str = node->str;
                    current_node->children.push_back(wiretype_node);
                    current_node->is_custom_type = true;
                }
                delete node;
            });
            visit_one_to_many({vpiRange}, reg_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
        } else if (vpi_get(vpiType, reg_h) == vpiIntVar) {
            packed_ranges.push_back(make_range(31, 0));
            visit_default_expr(reg_h);
        }
        vpi_release_handle(reg_h);
    }
    vpi_release_handle(itr);
    visit_one_to_many({vpiRange}, obj_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
    visit_default_expr(obj_h);
}

void UhdmAst::process_param_assign()
{
    current_node = make_ast_node(AST::AST_PARAMETER);
    visit_one_to_one({vpiLhs}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->type = node->type;
            current_node->str = node->str;
            // Here we need to copy any ranges that is already present in lhs,
            // but we want to skip actual value, as it is set in rhs
            for (auto *c : node->children) {
                if (c->type != AST::AST_CONSTANT) {
                    current_node->children.push_back(c->clone());
                }
            }
            delete_children(node);
            copy_packed_unpacked_attribute(node, current_node);
            current_node->is_custom_type = node->is_custom_type;
            auto it = shared.param_types.find(current_node->str);
            if (it == shared.param_types.end())
                shared.param_types[current_node->str] = shared.param_types[node->str];
            delete node;
        }
    });
    visit_one_to_one({vpiRhs}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (node->children.size() > 1 && (node->children[1]->type == AST::AST_PARAMETER || node->children[1]->type == AST::AST_LOCALPARAM)) {
                node->children[1]->type = AST::AST_IDENTIFIER;
            }
            current_node->children.insert(current_node->children.begin(), node);
        }
    });
}

void UhdmAst::process_cont_assign_var_init()
{
    current_node = make_ast_node(AST::AST_INITIAL);
    auto block_node = make_ast_node(AST::AST_BLOCK);
    auto assign_node = make_ast_node(AST::AST_ASSIGN_LE);
    block_node->children.push_back(assign_node);
    current_node->children.push_back(block_node);

    visit_one_to_one({vpiLhs, vpiRhs}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (node->type == AST::AST_WIRE || node->type == AST::AST_PARAMETER || node->type == AST::AST_LOCALPARAM) {
                assign_node->children.push_back(new AST::AstNode(AST::AST_IDENTIFIER));
                assign_node->children.back()->str = node->str;
                delete node;
            } else {
                assign_node->children.push_back(node);
            }
        }
    });
}

void UhdmAst::process_cont_assign_net()
{
    current_node = make_ast_node(AST::AST_ASSIGN);

    visit_one_to_one({vpiLhs, vpiRhs}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (node->type == AST::AST_WIRE || node->type == AST::AST_PARAMETER || node->type == AST::AST_LOCALPARAM) {
                current_node->children.push_back(new AST::AstNode(AST::AST_IDENTIFIER));
                current_node->children.back()->str = node->str;
            } else {
                current_node->children.push_back(node->clone());
            }
            delete node;
        }
    });
}

void UhdmAst::process_cont_assign()
{
    auto net_decl_assign = vpi_get(vpiNetDeclAssign, obj_h);
    vpiHandle node_lhs_h = vpi_handle(vpiLhs, obj_h);
    auto lhs_net_type = vpi_get(vpiNetType, node_lhs_h);
    vpi_release_handle(node_lhs_h);

    // Check if lhs is a subtype of a net
    bool isNet;
    if (lhs_net_type >= vpiWire && lhs_net_type <= vpiUwire)
        isNet = true;
    else
        // lhs is a variable
        isNet = false;
    if (net_decl_assign && !isNet)
        process_cont_assign_var_init();
    else
        process_cont_assign_net();
}

void UhdmAst::process_assignment(const UHDM::BaseClass *object)
{
    auto type = vpi_get(vpiBlocking, obj_h) == 1 ? AST::AST_ASSIGN_EQ : AST::AST_ASSIGN_LE;
    bool shift_unsigned = false;
    int op_type = vpi_get(vpiOpType, obj_h);
    AST::AstNodeType node_type;
    current_node = make_ast_node(type);

    visit_one_to_one({vpiLhs, vpiRhs}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            // fix node types for some assignments
            // yosys requires that declaration of variable
            // and assignment are separated
            switch (node->type) {
            case AST::AST_WIRE:
                // wires can be declarated inside initialization block of for block
                if (AST::AstNode *for_block = find_ancestor({AST::AST_BLOCK})) {
                    if (for_block->str.find("$fordecl_block") != std::string::npos)
                        break;
                }
                [[fallthrough]];
            case AST::AST_PARAMETER:
            case AST::AST_LOCALPARAM:
                node->type = AST::AST_IDENTIFIER;
                delete_children(node);
                delete_attribute(node, UhdmAst::packed_ranges());
                delete_attribute(node, UhdmAst::unpacked_ranges());
                break;
            default:
                break;
            };
            current_node->children.push_back(node);
        }
    });
    if (op_type && op_type != vpiAssignmentOp) {
        switch (op_type) {
        case vpiSubOp:
            node_type = AST::AST_SUB;
            break;
        case vpiDivOp:
            node_type = AST::AST_DIV;
            break;
        case vpiModOp:
            node_type = AST::AST_MOD;
            break;
        case vpiLShiftOp:
            node_type = AST::AST_SHIFT_LEFT;
            shift_unsigned = true;
            break;
        case vpiRShiftOp:
            node_type = AST::AST_SHIFT_RIGHT;
            shift_unsigned = true;
            break;
        case vpiAddOp:
            node_type = AST::AST_ADD;
            break;
        case vpiMultOp:
            node_type = AST::AST_MUL;
            break;
        case vpiBitAndOp:
            node_type = AST::AST_BIT_AND;
            break;
        case vpiBitOrOp:
            node_type = AST::AST_BIT_OR;
            break;
        case vpiBitXorOp:
            node_type = AST::AST_BIT_XOR;
            break;
        case vpiArithLShiftOp:
            node_type = AST::AST_SHIFT_SLEFT;
            shift_unsigned = true;
            break;
        case vpiArithRShiftOp:
            node_type = AST::AST_SHIFT_SRIGHT;
            shift_unsigned = true;
            break;
        default:
            delete current_node;
            current_node = nullptr;
            report_error("%.*s:%d: Encountered unhandled compound assignment with operation type %d\n", (int)object->VpiFile().length(),
                         object->VpiFile().data(), object->VpiLineNo(), op_type);
            return;
        }
        log_assert(current_node->children.size() == 2);
        auto child_node = new AST::AstNode(node_type, current_node->children[0]->clone(), current_node->children[1]);
        current_node->children[1] = child_node;
        if (shift_unsigned) {
            log_assert(current_node->children[1]->children.size() == 2);
            auto unsigned_node = new AST::AstNode(AST::AST_TO_UNSIGNED, current_node->children[1]->children[1]);
            current_node->children[1]->children[1] = unsigned_node;
        }
    }
    if (current_node->children.size() == 1 && current_node->children[0]->type == AST::AST_WIRE) {
        auto top_node = find_ancestor({AST::AST_MODULE});
        if (!top_node)
            return;
        top_node->children.push_back(std::move(current_node->children[0]));
        delete current_node;
        current_node = nullptr;
    }
}

void UhdmAst::process_packed_array_net()
{
    std::vector<AST::AstNode *> packed_ranges;
    std::vector<AST::AstNode *> unpacked_ranges;
    current_node = make_ast_node(AST::AST_WIRE);
    visit_one_to_many({vpiElement}, obj_h, [&](AST::AstNode *node) {
        if (node && GetSize(node->children) == 1)
            current_node->children.push_back(node->children[0]->clone());
        current_node->is_custom_type = node->is_custom_type;
        delete node;
    });
    visit_one_to_many({vpiRange}, obj_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
}

void UhdmAst::process_array_net(const UHDM::BaseClass *object)
{
    current_node = make_ast_node(AST::AST_WIRE);
    vpiHandle itr = vpi_iterate(vpiNet, obj_h);
    std::vector<AST::AstNode *> packed_ranges;
    std::vector<AST::AstNode *> unpacked_ranges;
    while (vpiHandle net_h = vpi_scan(itr)) {
        auto net_type = vpi_get(vpiType, net_h);
        if (net_type == vpiLogicNet) {
            current_node->is_logic = true;
            current_node->is_signed = vpi_get(vpiSigned, net_h);
            vpiHandle ref_typespec_h = vpi_handle(vpiTypespec, net_h);
            if (!ref_typespec_h) {
                ref_typespec_h = vpi_handle(vpiTypespec, obj_h);
            }
            if (ref_typespec_h) {
                if (vpiHandle typespec_h = vpi_handle(vpiActual, ref_typespec_h)) {
                    visit_one_to_many({vpiRange}, typespec_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
                    vpi_release_handle(typespec_h);
                } else {
                    visit_one_to_many({vpiRange}, net_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
                }
                vpi_release_handle(ref_typespec_h);
            }
        } else if (net_type == vpiStructNet) {
            visit_one_to_one({vpiTypespec}, net_h, [&](AST::AstNode *node) {
                if (node->str.empty()) {
                    // anonymous typespec, move the children to variable
                    current_node->type = node->type;
                    current_node->children = std::move(node->children);
                } else {
                    auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
                    wiretype_node->str = node->str;
                    current_node->children.push_back(wiretype_node);
                    current_node->is_custom_type = true;
                }
                delete node;
            });
        }
        vpi_release_handle(net_h);
    }
    vpi_release_handle(itr);
    iterate_one_to_many({vpiAttribute}, obj_h, [&](vpiHandle h) {
        std::string name = vpi_get_str(vpiName, h);
        if (name == "keep")
            current_node->attributes[ID::keep] = AST::AstNode::mkconst_int(1, false, 32);
    });
    visit_one_to_many({vpiRange}, obj_h, [&](AST::AstNode *node) { unpacked_ranges.push_back(node); });
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
}

void UhdmAst::process_package()
{
    current_node = make_ast_node(AST::AST_PACKAGE);
    shared.current_top_node = current_node;
    visit_one_to_many({vpiTypedef}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            move_type_to_new_typedef(current_node, node);
        }
    });
    visit_one_to_many({vpiParameter, vpiParamAssign}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (get_attribute(node, attr_id::is_type_parameter)) {
                // Don't process type parameters.
                delete node;
                return;
            }
            node->str = strip_package_name(node->str);
            for (auto c : node->children) {
                c->str = strip_package_name(c->str);
            }
            add_or_replace_child(current_node, node);
        }
    });
    visit_one_to_many({vpiTaskFunc}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->children.push_back(node);
        }
    });
}

void UhdmAst::process_interface()
{
    std::string type = vpi_get_str(vpiDefName, obj_h);
    std::string name = vpi_get_str(vpiName, obj_h) ? vpi_get_str(vpiName, obj_h) : type;
    sanitize_symbol_name(type);
    sanitize_symbol_name(name);
    AST::AstNode *elaboratedInterface;
    // Check if we have encountered this object before
    if (shared.top_nodes.find(type) != shared.top_nodes.end()) {
        // Was created before, fill missing
        elaboratedInterface = shared.top_nodes[type];
        visit_one_to_many({vpiPort, vpiVariables}, obj_h, [&](AST::AstNode *node) {
            if (node) {
                add_or_replace_child(elaboratedInterface, node);
            }
        });
    } else {
        // Encountered for the first time
        elaboratedInterface = new AST::AstNode(AST::AST_INTERFACE);
        elaboratedInterface->str = name;
        visit_one_to_many({vpiNet, vpiPort, vpiModport}, obj_h, [&](AST::AstNode *node) {
            if (node) {
                add_or_replace_child(elaboratedInterface, node);
            }
        });
    }
    shared.top_nodes[elaboratedInterface->str] = elaboratedInterface;
    if (name != type) {
        // Not a top module, create instance
        current_node = make_ast_node(AST::AST_CELL);
        make_cell(obj_h, current_node, elaboratedInterface->str);
    } else {
        current_node = elaboratedInterface;
    }
}

void UhdmAst::process_modport()
{
    current_node = make_ast_node(AST::AST_MODPORT);
    visit_one_to_many({vpiIODecl}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->children.push_back(node);
        }
    });
}

void UhdmAst::process_io_decl()
{
    current_node = nullptr;
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    visit_one_to_one({vpiExpr}, obj_h, [&](AST::AstNode *node) { current_node = node; });
    if (current_node == nullptr) {
        current_node = make_ast_node(AST::AST_MODPORTMEMBER);
        visit_one_to_many({vpiRange}, obj_h, [&](AST::AstNode *node) { unpacked_ranges.push_back(node); });
    }

    visit_one_to_one({vpiTypedef}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (!node->str.empty()) {
                auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
                wiretype_node->str = node->str;
                // wiretype needs to be 1st node (if port have also another range nodes)
                current_node->children.insert(current_node->children.begin(), wiretype_node);
                current_node->is_custom_type = true;
            } else {
                // anonymous typedef, just move children
                for (auto child : node->children) {
                    current_node->children.push_back(child->clone());
                }
                if (node->attributes.count(UhdmAst::packed_ranges())) {
                    for (auto r : node->attributes[UhdmAst::packed_ranges()]->children) {
                        packed_ranges.push_back(r->clone());
                    }
                }
                if (node->attributes.count(UhdmAst::unpacked_ranges())) {
                    for (auto r : node->attributes[UhdmAst::unpacked_ranges()]->children) {
                        unpacked_ranges.push_back(r->clone());
                    }
                }
                current_node->is_logic = node->is_logic;
                current_node->is_reg = node->is_reg;
            }
            current_node->is_signed = node->is_signed;
            delete node;
        }
    });
    if (const int n = vpi_get(vpiDirection, obj_h)) {
        if (n == vpiInput) {
            current_node->is_input = true;
        } else if (n == vpiOutput) {
            current_node->is_output = true;
        } else if (n == vpiInout) {
            current_node->is_input = true;
            current_node->is_output = true;
        }
    }
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
}

void UhdmAst::process_always()
{
    current_node = make_ast_node(AST::AST_ALWAYS);
    visit_one_to_one({vpiStmt}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (node->type != AST::AST_BLOCK) {
                // Create implicit block.
                AST::AstNode *block = make_ast_node(AST::AST_BLOCK);
                // There are (at least) two cases where something could have been inserted into AST_ALWAYS node when `node` is not an AST_BLOCK:
                // - stream_op inserts a block.
                // - event_control inserts a non-block statement.
                // Move the block inserted by a stream_op into an implicit group. Everything else stays where it is.
                if (!current_node->children.empty() && current_node->children.back()->type == AST::AST_BLOCK) {
                    block->children.push_back(current_node->children.back());
                    current_node->children.pop_back();
                }
                block->children.push_back(node);
                current_node->children.push_back(block);
            } else {
                // Child is an explicit block.
                current_node->children.push_back(node);
            }
        } else {
            // TODO (mglb): This branch is probably unreachable? Is it possible to have empty `always`?
            // No children, so nothing should have been inserted into the always node during visitation.
            log_assert(current_node->children.empty());
            // Create implicit empty block.
            current_node->children.push_back(make_ast_node(AST::AST_BLOCK));
        }
    });
    switch (vpi_get(vpiAlwaysType, obj_h)) {
    case vpiAlwaysComb:
        current_node->attributes[ID::always_comb] = AST::AstNode::mkconst_int(1, false);
        break;
    case vpiAlwaysFF:
        current_node->attributes[ID::always_ff] = AST::AstNode::mkconst_int(1, false);
        break;
    case vpiAlwaysLatch:
        current_node->attributes[ID::always_latch] = AST::AstNode::mkconst_int(1, false);
        break;
    default:
        break;
    }
}

void UhdmAst::process_event_control(const UHDM::BaseClass *object)
{
    current_node = make_ast_node(AST::AST_BLOCK);
    visit_one_to_one({vpiCondition}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            auto process_node = find_ancestor({AST::AST_ALWAYS});
            if (!process_node) {
                log_error("%.*s:%d: Currently supports only event control stmts inside 'always'\n", (int)object->VpiFile().length(),
                          object->VpiFile().data(), object->VpiLineNo());
            }
            process_node->children.push_back(node);
        }
        // is added inside vpiOperation
    });
    visit_one_to_one({vpiStmt}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->children.push_back(node);
        }
    });
}

void UhdmAst::process_initial()
{
    current_node = make_ast_node(AST::AST_INITIAL);
    // TODO (mglb): handler below is identical as in `process_always`. Extract it to avoid duplication.
    visit_one_to_one({vpiStmt}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (node->type != AST::AST_BLOCK) {
                // Create an implicit block.
                AST::AstNode *block = make_ast_node(AST::AST_BLOCK);
                // There is (at least) one case where something could have been inserted into AST_INITIAL node when `node` is not an AST_BLOCK:
                // - stream_op inserts a block.
                // Move the block inserted by a stream_op into an implicit group.
                if (!current_node->children.empty() && current_node->children.back()->type == AST::AST_BLOCK) {
                    block->children.push_back(current_node->children.back());
                    current_node->children.pop_back();
                }
                block->children.push_back(node);
                current_node->children.push_back(block);
            } else {
                // Child is an explicit block.
                current_node->children.push_back(node);
            }
        } else {
            // TODO (mglb): This branch is probably unreachable? Is it possible to have empty `initial`?
            // No children, so nothing should have been inserted into the always node during visitation.
            log_assert(current_node->children.empty());
            // Create implicit empty block.
            current_node->children.push_back(make_ast_node(AST::AST_BLOCK));
        }
    });
}

void UhdmAst::process_begin(bool is_named)
{
    current_node = make_ast_node(AST::AST_BLOCK);
    if (!is_named) {
        // for unnamed block, reset block name
        current_node->str = "";
    }
    AST::AstNode *hierarchy_node = nullptr;
    static int unnamed_block_idx = 0;
    visit_one_to_many({vpiVariables}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (!is_named) {
                if (!hierarchy_node) {
                    // Create an implicit hierarchy scope
                    // simplify checks if sv_mode is set to true when wire is declared inside unnamed block
                    VERILOG_FRONTEND::sv_mode = true;
                    hierarchy_node = make_ast_node(AST::AST_BLOCK);
                    hierarchy_node->str = "$unnamed_block$" + std::to_string(unnamed_block_idx++);
                }
                hierarchy_node->children.push_back(node);
            } else {
                current_node->children.push_back(node);
            }
        }
    });
    visit_one_to_many({vpiStmt}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if ((node->type == AST::AST_ASSIGN_EQ || node->type == AST::AST_ASSIGN_LE) && node->children.size() == 1) {
                auto func_node = find_ancestor({AST::AST_FUNCTION, AST::AST_TASK});
                if (!func_node) {
                    delete node;
                    return;
                }
                auto wire_node = new AST::AstNode(AST::AST_WIRE);
                wire_node->type = AST::AST_WIRE;
                wire_node->str = node->children[0]->str;
                func_node->children.push_back(wire_node);
                delete node;
            } else {
                if (hierarchy_node)
                    hierarchy_node->children.push_back(node);
                else
                    current_node->children.push_back(node);
            }
        }
    });
    if (hierarchy_node)
        current_node->children.push_back(hierarchy_node);
}

void UhdmAst::process_operation(const UHDM::BaseClass *object)
{
    auto operation = vpi_get(vpiOpType, obj_h);
    switch (operation) {
    case vpiStreamRLOp:
        process_stream_op();
        break;
    case vpiEventOrOp:
    case vpiListOp:
        process_list_op();
        break;
    case vpiCastOp:
        process_cast_op();
        break;
    case vpiInsideOp:
        process_inside_op();
        break;
    case vpiAssignmentPatternOp:
        process_assignment_pattern_op();
        break;
    case vpiWildEqOp:
    case vpiWildNeqOp: {
        report_error("%.*s:%d: Wildcard operators are not supported yet\n", (int)object->VpiFile().length(), object->VpiFile().data(),
                     object->VpiLineNo());
        break;
    }
    default: {
        current_node = make_ast_node(AST::AST_NONE);
        visit_one_to_many({vpiOperand}, obj_h, [&](AST::AstNode *node) {
            if (node) {
                current_node->children.push_back(node);
            }
        });
        switch (operation) {
        case vpiMinusOp:
            current_node->type = AST::AST_NEG;
            break;
        case vpiPlusOp:
            current_node->type = AST::AST_POS;
            break;
        case vpiPosedgeOp:
            current_node->type = AST::AST_POSEDGE;
            // first child in event is condition
            if (current_node->children.size() > 0) {
                // condition needs to be single bit, but Surelog
                // defaults to 64 bit for constants
                // make sure it is single bit
                auto single_bit_node = make_ast_node(AST::AST_CAST_SIZE);
                single_bit_node->children.push_back(AST::AstNode::mkconst_int(1, true));
                single_bit_node->children.push_back(current_node->children[0]);
                current_node->children[0] = single_bit_node;
            }
            break;
        case vpiNegedgeOp:
            current_node->type = AST::AST_NEGEDGE;
            // first child in event is condition
            if (current_node->children.size() > 0) {
                // condition needs to be single bit, but Surelog
                // defaults to 64 bit for constants
                // make sure it is single bit
                auto single_bit_node = make_ast_node(AST::AST_CAST_SIZE);
                single_bit_node->children.push_back(AST::AstNode::mkconst_int(1, true));
                single_bit_node->children.push_back(current_node->children[0]);
                current_node->children[0] = single_bit_node;
            }
            break;
        case vpiUnaryAndOp:
            current_node->type = AST::AST_REDUCE_AND;
            break;
        case vpiUnaryOrOp:
            current_node->type = AST::AST_REDUCE_OR;
            break;
        case vpiUnaryXorOp:
            current_node->type = AST::AST_REDUCE_XOR;
            break;
        case vpiUnaryXNorOp:
            current_node->type = AST::AST_REDUCE_XNOR;
            break;
        case vpiUnaryNandOp: {
            auto not_node = new AST::AstNode(AST::AST_NONE, current_node);
            if (current_node->children.size() == 2) {
                current_node->type = AST::AST_BIT_AND;
                not_node->type = AST::AST_BIT_NOT;
            } else {
                current_node->type = AST::AST_REDUCE_AND;
                not_node->type = AST::AST_LOGIC_NOT;
            }
            current_node = not_node;
            break;
        }
        case vpiUnaryNorOp: {
            auto not_node = new AST::AstNode(AST::AST_NONE, current_node);
            if (current_node->children.size() == 2) {
                current_node->type = AST::AST_BIT_OR;
                not_node->type = AST::AST_BIT_NOT;
            } else {
                current_node->type = AST::AST_REDUCE_OR;
                not_node->type = AST::AST_LOGIC_NOT;
            }
            current_node = not_node;
            break;
        }
        case vpiBitNegOp:
            current_node->type = AST::AST_BIT_NOT;
            break;
        case vpiBitAndOp:
            current_node->type = AST::AST_BIT_AND;
            break;
        case vpiBitOrOp:
            current_node->type = AST::AST_BIT_OR;
            break;
        case vpiBitXorOp:
            current_node->type = AST::AST_BIT_XOR;
            break;
        case vpiBitXnorOp:
            current_node->type = AST::AST_BIT_XNOR;
            break;
        case vpiLShiftOp: {
            current_node->type = AST::AST_SHIFT_LEFT;
            log_assert(current_node->children.size() == 2);
            auto unsigned_node = new AST::AstNode(AST::AST_TO_UNSIGNED, current_node->children[1]);
            current_node->children[1] = unsigned_node;
            break;
        }
        case vpiRShiftOp: {
            current_node->type = AST::AST_SHIFT_RIGHT;
            log_assert(current_node->children.size() == 2);
            auto unsigned_node = new AST::AstNode(AST::AST_TO_UNSIGNED, current_node->children[1]);
            current_node->children[1] = unsigned_node;
            break;
        }
        case vpiNotOp:
            current_node->type = AST::AST_LOGIC_NOT;
            break;
        case vpiLogAndOp:
            current_node->type = AST::AST_LOGIC_AND;
            break;
        case vpiLogOrOp:
            current_node->type = AST::AST_LOGIC_OR;
            break;
        case vpiEqOp:
            current_node->type = AST::AST_EQ;
            break;
        case vpiNeqOp:
            current_node->type = AST::AST_NE;
            break;
        case vpiCaseEqOp:
            current_node->type = AST::AST_EQX;
            break;
        case vpiCaseNeqOp:
            current_node->type = AST::AST_NEX;
            break;
        case vpiGtOp:
            current_node->type = AST::AST_GT;
            break;
        case vpiGeOp:
            current_node->type = AST::AST_GE;
            break;
        case vpiLtOp:
            current_node->type = AST::AST_LT;
            break;
        case vpiLeOp:
            current_node->type = AST::AST_LE;
            break;
        case vpiSubOp:
            current_node->type = AST::AST_SUB;
            if (!current_node->children.empty() && current_node->children[0]->type == AST::AST_LOCALPARAM) {
                current_node->children[0]->type = AST::AST_IDENTIFIER;
            }
            break;
        case vpiAddOp:
            current_node->type = AST::AST_ADD;
            break;
        case vpiMultOp:
            current_node->type = AST::AST_MUL;
            break;
        case vpiDivOp:
            current_node->type = AST::AST_DIV;
            break;
        case vpiModOp:
            current_node->type = AST::AST_MOD;
            break;
        case vpiArithLShiftOp: {
            current_node->type = AST::AST_SHIFT_SLEFT;
            log_assert(current_node->children.size() == 2);
            auto unsigned_node = new AST::AstNode(AST::AST_TO_UNSIGNED, current_node->children[1]);
            current_node->children[1] = unsigned_node;
            break;
        }
        case vpiArithRShiftOp: {
            current_node->type = AST::AST_SHIFT_SRIGHT;
            log_assert(current_node->children.size() == 2);
            auto unsigned_node = new AST::AstNode(AST::AST_TO_UNSIGNED, current_node->children[1]);
            current_node->children[1] = unsigned_node;
            break;
        }
        case vpiPowerOp:
            current_node->type = AST::AST_POW;
            break;
        case vpiPostIncOp: {
            // TODO: Make this an actual post-increment op (currently it's a pre-increment)
            log_warning("%.*s:%d: Post-incrementation operations are handled as pre-incrementation.\n", (int)object->VpiFile().length(),
                        object->VpiFile().data(), object->VpiLineNo());
            [[fallthrough]];
        }
        case vpiPreIncOp: {
            current_node->type = AST::AST_ASSIGN_EQ;
            auto id = current_node->children[0]->clone();
            auto add_node = new AST::AstNode(AST::AST_ADD, id, AST::AstNode::mkconst_int(1, true));
            add_node->filename = current_node->filename;
            add_node->location = current_node->location;
            current_node->children.push_back(add_node);
            break;
        }
        case vpiPostDecOp: {
            // TODO: Make this an actual post-decrement op (currently it's a pre-decrement)
            log_warning("%.*s:%d: Post-decrementation operations are handled as pre-decrementation.\n", (int)object->VpiFile().length(),
                        object->VpiFile().data(), object->VpiLineNo());
            [[fallthrough]];
        }
        case vpiPreDecOp: {
            current_node->type = AST::AST_ASSIGN_EQ;
            auto id = current_node->children[0]->clone();
            auto add_node = new AST::AstNode(AST::AST_SUB, id, AST::AstNode::mkconst_int(1, true));
            add_node->filename = current_node->filename;
            add_node->location = current_node->location;
            current_node->children.push_back(add_node);
            break;
        }
        case vpiConditionOp:
            current_node->type = AST::AST_TERNARY;
            break;
        case vpiConcatOp: {
            current_node->type = AST::AST_CONCAT;
            std::reverse(current_node->children.begin(), current_node->children.end());
            break;
        }
        case vpiMultiConcatOp:
        case vpiMultiAssignmentPatternOp:
            current_node->type = AST::AST_REPLICATE;
            break;
        case vpiAssignmentOp:
            current_node->type = AST::AST_ASSIGN_EQ;
            break;
        case vpiStreamLROp: {
            auto concat_node = current_node->children.back();
            current_node->children.pop_back();
            delete current_node;
            current_node = concat_node;
            break;
        }
        case vpiNullOp: {
            delete current_node;
            current_node = nullptr;
            break;
        }
        case vpiMinTypMaxOp: {
            // ignore min and max and set only typ
            log_assert(current_node->children.size() == 3);
            auto tmp = current_node->children[1]->clone();
            delete current_node;
            current_node = tmp;
            break;
        }
        default: {
            delete current_node;
            current_node = nullptr;
            report_error("%.*s:%d: Encountered unhandled operation type %d\n", (int)object->VpiFile().length(), object->VpiFile().data(),
                         object->VpiLineNo(), operation);
        }
        }
    }
    }
}

void UhdmAst::process_stream_op()
{
    // Closest ancestor where new statements can be inserted.
    AST::AstNode *stmt_list_node = find_ancestor({
      AST::AST_MODULE,
      AST::AST_PACKAGE,
      AST::AST_BLOCK,
      AST::AST_INITIAL,
      AST::AST_ALWAYS,
      AST::AST_FUNCTION,
    });
    uhdmast_assert(stmt_list_node != nullptr);

    // Detect whether we're in a procedural context. If yes, `for` loop will be generated, and `generate for` otherwise.
    const AST::AstNode *const proc_ctx = find_ancestor({AST::AST_ALWAYS, AST::AST_INITIAL, AST::AST_FUNCTION});
    const bool is_proc_ctx = (proc_ctx != nullptr);

    // Get a prefix for internal identifiers.
    const auto stream_op_id = shared.next_loop_id();
    const auto make_id_str = [stream_op_id](const char *suffix) {
        return std::string("$systemverilog_plugin$stream_op_") + std::to_string(stream_op_id) + "_" + suffix;
    };

    if (is_proc_ctx) {
        // Put logic inside a sub-block to avoid issues with declarations not being at the beginning of a block.
        AST::AstNode *block = make_node(Yosys::AST::AST_BLOCK).str(make_id_str("impl"));
        stmt_list_node->children.push_back(block);
        stmt_list_node = block;
    }

    // TODO (mglb): Only concat expression's size factors are supported as a slice size. Add support for other slice sizes as well.
    AST::AstNode *slice_size_arg = nullptr;
    AST::AstNode *stream_concat_arg = nullptr;
    {
        std::vector<AST::AstNode *> operands;
        // Expected operands: [slice_size] stream_concatenation
        visit_one_to_many({vpiOperand}, obj_h, [&](AST::AstNode *node) {
            uhdmast_assert(node != nullptr);
            uhdmast_assert(operands.size() < 2);
            operands.push_back(node);
        });
        uhdmast_assert(operands.size() > 0);

        if (operands.size() == 2) {
            slice_size_arg = operands.at(0);
            // SV spec says slice_size can be a constant or a type. However, Surelog converts type to its width, so we always expect a const.
            uhdmast_assert(slice_size_arg->type == AST::AST_CONSTANT);
        } else {
            slice_size_arg = make_const(1u);
        }
        stream_concat_arg = operands.back();
    }

    AST::AstNode *const stream_concat_width_lp = //
      (make_node(AST::AST_LOCALPARAM).str(make_id_str("width")))({
        (make_node(AST::AST_FCALL).str("\\$bits"))({
          (stream_concat_arg->clone()),
        }),
        (make_range(31, 0, true)),
      });

    // TODO (mglb): src_wire and dst_wire should probably take argument signedness and logicness into account.
    AST::AstNode *const src_wire = //
      (make_node(AST::AST_WIRE).str(make_id_str("src")).is_reg(is_proc_ctx))({
        (make_node(AST::AST_RANGE))({
          (make_const(0)),
          (make_node(AST::AST_SUB))({
            (make_ident(stream_concat_width_lp->str)),
            (make_const(1)),
          }),
        }),
      });

    AST::AstNode *const dst_wire = //
      (make_node(AST::AST_WIRE).str(make_id_str("dst")).is_reg(is_proc_ctx))({
        (make_node(AST::AST_RANGE))({
          (make_node(AST::AST_SUB))({
            (make_ident(stream_concat_width_lp->str)),
            (make_const(1)),
          }),
          (make_const(0)),
        }),
      });

    AST::AstNode *const assign_stream_concat_to_src_wire = //
      (make_node(is_proc_ctx ? AST::AST_ASSIGN_EQ : AST::AST_ASSIGN))({
        (make_ident(src_wire->str)),
        (stream_concat_arg),
      });

    AST::AstNode *const loop_counter = //
      (make_node(is_proc_ctx ? AST::AST_WIRE : AST::AST_GENVAR).str(make_id_str("counter")).is_reg(true))({
        (make_range(31, 0, true)),
      });

    AST::AstNode *const for_loop = //
      (make_node(is_proc_ctx ? AST::AST_FOR : AST::AST_GENFOR))({
        // init statement
        (make_node(AST::AST_ASSIGN_EQ))({
          (make_ident(loop_counter->str)),
          (make_const(0)),
        }),
        // condition
        (make_node(AST::AST_LT))({
          (make_ident(loop_counter->str)),
          (make_ident(stream_concat_width_lp->str)),
        }),
        // iteration expression
        (make_node(AST::AST_ASSIGN_EQ))({
          (make_ident(loop_counter->str)),
          (make_node(Yosys::AST::AST_ADD))({
            (make_ident(loop_counter->str)),
            (slice_size_arg->clone()),
          }),
        }),
        // loop body
        (make_node(is_proc_ctx ? AST::AST_BLOCK : AST::AST_GENBLOCK).str(make_id_str("loop_body")))({
          (make_node(is_proc_ctx ? AST::AST_ASSIGN_EQ : AST::AST_ASSIGN))({
            (make_ident(dst_wire->str))({
              (make_node(AST::AST_RANGE))({
                (make_node(Yosys::AST::AST_SUB))({
                  (make_node(Yosys::AST::AST_ADD))({
                    (make_node(Yosys::AST::AST_SELFSZ))({
                      (make_ident(loop_counter->str)),
                    }),
                    (slice_size_arg->clone()),
                  }),
                  (make_const(1)),
                }),
                (make_node(Yosys::AST::AST_ADD))({
                  (make_node(Yosys::AST::AST_SELFSZ))({
                    (make_ident(loop_counter->str)),
                  }),
                  (make_const(0)),
                }),
              }),
            }),
            (make_ident(src_wire->str))({
              (make_node(AST::AST_RANGE))({
                (make_node(Yosys::AST::AST_SUB))({
                  (make_node(Yosys::AST::AST_ADD))({
                    (make_node(Yosys::AST::AST_SELFSZ))({
                      (make_ident(loop_counter->str)),
                    }),
                    (slice_size_arg),
                  }),
                  (make_const(1)),
                }),
                (make_node(Yosys::AST::AST_ADD))({
                  (make_node(Yosys::AST::AST_SELFSZ))({
                    (make_ident(loop_counter->str)),
                  }),
                  (make_const(0)),
                }),
              }),
            }),
          }),
        }),
      });

    stmt_list_node->children.insert(stmt_list_node->children.end(), {
                                                                      stream_concat_width_lp,
                                                                      src_wire,
                                                                      dst_wire,
                                                                      assign_stream_concat_to_src_wire,
                                                                      loop_counter,
                                                                      for_loop,
                                                                    });

    current_node = make_ident(is_proc_ctx ? (stmt_list_node->str + '.' + dst_wire->str) : dst_wire->str);
}

void UhdmAst::process_list_op()
{
    // Add all operands as children of process node
    if (auto parent_node = find_ancestor({AST::AST_ALWAYS, AST::AST_COND})) {
        visit_one_to_many({vpiOperand}, obj_h, [&](AST::AstNode *node) {
            // add directly to process/cond node
            if (node) {
                if ((node->type == AST::AST_IDENTIFIER) && (parent_node->type == AST::AST_ALWAYS)) {
                    // No edge (pos/neg) sensitivity list
                    AST::AstNode *edge = new AST::AstNode(AST::AST_EDGE);
                    edge->children.push_back(node);
                    node = edge;
                }
                parent_node->children.push_back(node);
            }
        });
    } else {
        log_error("Unhandled list op, couldn't find parent node.");
    }
    // Do not create a node
}

void UhdmAst::process_cast_op()
{
    current_node = make_ast_node(AST::AST_NONE);
    visit_one_to_many({vpiOperand}, obj_h, [&](AST::AstNode *node) {
        node->cloneInto(current_node);
        delete node;
    });
    vpiHandle ref_typespec_h = vpi_handle(vpiTypespec, obj_h);
    vpi_release_handle(ref_typespec_h);
}

void UhdmAst::process_inside_op()
{
    current_node = make_ast_node(AST::AST_EQ);
    AST::AstNode *lhs = nullptr;
    visit_one_to_many({vpiOperand}, obj_h, [&](AST::AstNode *node) {
        if (!lhs) {
            lhs = node;
        }
        if (current_node->children.size() < 2) {
            current_node->children.push_back(node);
        } else {
            auto or_node = new AST::AstNode(AST::AST_LOGIC_OR);
            or_node->filename = current_node->filename;
            or_node->location = current_node->location;
            auto eq_node = new AST::AstNode(AST::AST_EQ);
            eq_node->filename = current_node->filename;
            eq_node->location = current_node->location;
            or_node->children.push_back(current_node);
            or_node->children.push_back(eq_node);
            eq_node->children.push_back(lhs->clone());
            eq_node->children.push_back(node);
            current_node = or_node;
        }
    });
}

void UhdmAst::process_assignment_pattern_op()
{
    current_node = make_ast_node(AST::AST_CONCAT);
    if (auto param_node = find_ancestor({AST::AST_PARAMETER, AST::AST_LOCALPARAM})) {
        std::map<size_t, AST::AstNode *> ordered_children;
        visit_one_to_many({vpiOperand}, obj_h, [&](AST::AstNode *node) {
            if (node->type == AST::AST_ASSIGN || node->type == AST::AST_ASSIGN_EQ || node->type == AST::AST_ASSIGN_LE) {
                // Get the name of the parameter or it's child, to which the pattern is assigned.
                std::string key;
                if (!node->children.empty() && !node->children[0]->children.empty() &&
                    node->children[0]->children[0]->type == static_cast<AST::AstNodeType>(AST::Extended::AST_DOT)) {
                    key = node->children[0]->children[0]->str;
                } else if (!node->children.empty()) {
                    key = node->children[0]->str;
                } else {
                    log_file_error(node->filename, node->location.first_line, "Couldn't find `key` in assignment pattern.\n");
                }
                auto param_type = shared.param_types[param_node->str];
                if (!param_type) {
                    log_error("Couldn't find parameter type for node: %s\n", param_node->str.c_str());
                }
                // Place the child node holding the value assigned in the pattern, in the right order,
                // so the overall value of the param_node is correct.
                size_t pos =
                  std::find_if(param_type->children.begin(), param_type->children.end(), [key](AST::AstNode *child) { return child->str == key; }) -
                  param_type->children.begin();
                ordered_children.insert(std::make_pair(pos, node->children[1]->clone()));
                delete node;
            } else {
                current_node->children.push_back(node);
            }
        });
        for (auto p : ordered_children) {
            current_node->children.push_back(p.second);
        }
        std::reverse(current_node->children.begin(), current_node->children.end());
        return;
    }
    auto assign_node = find_ancestor({AST::AST_ASSIGN, AST::AST_ASSIGN_EQ, AST::AST_ASSIGN_LE});

    auto proc_node =
      find_ancestor({AST::AST_BLOCK, AST::AST_GENBLOCK, AST::AST_ALWAYS, AST::AST_INITIAL, AST::AST_MODULE, AST::AST_PACKAGE, AST::AST_CELL});
    if (proc_node && proc_node->type == AST::AST_CELL && shared.top_nodes.count(proc_node->children[0]->str)) {
        proc_node = shared.top_nodes[proc_node->children[0]->str];
    }
    std::vector<AST::AstNode *> assignments;
    visit_one_to_many({vpiOperand}, obj_h, [&](AST::AstNode *node) {
        if (node->type == AST::AST_ASSIGN || node->type == AST::AST_ASSIGN_EQ || node->type == AST::AST_ASSIGN_LE) {
            if (assign_node == nullptr) {
                // Parameter assigns are not assigns per-se, the find_ancestor returns nullptr, but an assign is created in the visit_one_to_many,
                // selecting this assign for the downstream processing
                assign_node = node;
            }
            assignments.push_back(node);
        } else {
            current_node->children.push_back(node);
        }
    });
    std::reverse(current_node->children.begin(), current_node->children.end());
    if (!assignments.empty()) {
        if (current_node->children.empty()) {
            delete assign_node->children[0];
            assign_node->children[0] = assignments[0]->children[0];
            delete current_node;
            current_node = assignments[0]->children[1];
            assignments[0]->children.clear();
            delete assignments[0];
            proc_node->children.insert(proc_node->children.end(), assignments.begin() + 1, assignments.end());
        } else {
            proc_node->children.insert(proc_node->children.end(), assignments.begin(), assignments.end());
        }
    }
}

void UhdmAst::process_bit_select()
{
    current_node = make_ast_node(AST::AST_IDENTIFIER);
    visit_one_to_one({vpiIndex}, obj_h, [&](AST::AstNode *node) { current_node->children.push_back(make_node(AST::AST_RANGE)({node})); });
}

void UhdmAst::process_part_select()
{
    current_node = make_ast_node(AST::AST_IDENTIFIER);
    AST::AstNode *range_node = make_node(AST::AST_RANGE);
    visit_one_to_one({vpiLeftRange, vpiRightRange}, obj_h, [&](AST::AstNode *node) { range_node->children.push_back(node); });
    current_node->children.push_back(range_node);
}

void UhdmAst::process_indexed_part_select()
{
    current_node = make_ast_node(AST::AST_IDENTIFIER);
    AST::AstNode *range_node = make_node(AST::AST_RANGE);

    AST::AstNode *width = nullptr;
    visit_one_to_one({vpiWidthExpr}, obj_h, [&](AST::AstNode *node) { width = node; });

    if (vpi_get(vpiIndexedPartSelectType, obj_h) == vpiPosIndexed) {
        visit_one_to_one({vpiBaseExpr}, obj_h, [&](AST::AstNode *node) {
            AST::AstNode *left_range_node = make_node(AST::AST_SUB);
            AST::AstNode *add = make_node(AST::AST_ADD);
            left_range_node->children.push_back(add);
            left_range_node->children.push_back(AST::AstNode::mkconst_int(1, false, 32));
            AST::AstNode *self_size = make_node(AST::AST_SELFSZ);
            add->children.push_back(self_size);
            add->children.push_back(width);
            self_size->children.push_back(node);
            range_node->children.push_back(left_range_node);

            AST::AstNode *right_range_node = make_node(AST::AST_ADD);
            self_size = make_node(AST::AST_SELFSZ);
            self_size->children.push_back(node->clone());
            right_range_node->children.push_back(self_size);
            right_range_node->children.push_back(AST::AstNode::mkconst_int(0, false, 32));
            range_node->children.push_back(right_range_node);
        });
    } else {
        visit_one_to_one({vpiBaseExpr}, obj_h, [&](AST::AstNode *node) {
            AST::AstNode *left_range_node = make_node(AST::AST_ADD);
            AST::AstNode *self_size = make_node(AST::AST_SELFSZ);
            self_size->children.push_back(node);
            left_range_node->children.push_back(self_size);
            left_range_node->children.push_back(AST::AstNode::mkconst_int(0, false, 32));
            range_node->children.push_back(left_range_node);

            AST::AstNode *right_range_node = make_node(AST::AST_SUB);
            AST::AstNode *add = make_node(AST::AST_ADD);
            right_range_node->children.push_back(add);
            right_range_node->children.push_back(width);
            self_size = make_node(AST::AST_SELFSZ);
            add->children.push_back(self_size);
            self_size->children.push_back(node->clone());
            add->children.push_back(AST::AstNode::mkconst_int(1, false, 32));
            range_node->children.push_back(right_range_node);
        });
    }

    current_node->children.push_back(range_node);
}

void UhdmAst::process_if_else()
{
    current_node = make_ast_node(AST::AST_CASE);
    visit_one_to_one({vpiCondition}, obj_h, [&](AST::AstNode *node) {
        if (!node) {
            log_error("Couldn't find node in if stmt. This can happend if unsupported '$value$plusargs' function is used inside if.\n");
        }
        auto reduce_node = new AST::AstNode(AST::AST_REDUCE_BOOL, node);
        current_node->children.push_back(reduce_node);
    });
    // If true:
    auto *condition = new AST::AstNode(AST::AST_COND);
    auto *constant = AST::AstNode::mkconst_int(1, false, 1);
    condition->children.push_back(constant);
    visit_one_to_one({vpiStmt}, obj_h, [&](AST::AstNode *node) {
        auto *statements = new AST::AstNode(AST::AST_BLOCK);
        if (node)
            statements->children.push_back(node);
        condition->children.push_back(statements);
    });
    current_node->children.push_back(condition);
    // Else:
    if (vpi_get(vpiType, obj_h) == vpiIfElse) {
        auto *condition = new AST::AstNode(AST::AST_COND);
        auto *elseBlock = new AST::AstNode(AST::AST_DEFAULT);
        condition->children.push_back(elseBlock);
        visit_one_to_one({vpiElseStmt}, obj_h, [&](AST::AstNode *node) {
            auto *statements = new AST::AstNode(AST::AST_BLOCK);
            if (node)
                statements->children.push_back(node);
            condition->children.push_back(statements);
        });
        current_node->children.push_back(condition);
    }
}

void UhdmAst::process_for()
{
    current_node = make_ast_node(AST::AST_BLOCK);
    auto loop_id = shared.next_loop_id();
    current_node->str = "$fordecl_block" + std::to_string(loop_id);
    auto loop = make_ast_node(AST::AST_FOR);
    loop->str = "$loop" + std::to_string(loop_id);
    visit_one_to_many({vpiForInitStmt}, obj_h, [&](AST::AstNode *node) {
        if (node->type == AST::AST_ASSIGN_LE)
            node->type = AST::AST_ASSIGN_EQ;
        auto lhs = node->children[0];
        if (lhs->type == AST::AST_WIRE) {
            auto *wire = lhs->clone();
            wire->is_logic = true;
            current_node->children.push_back(wire);
            lhs->type = AST::AST_IDENTIFIER;
            lhs->is_signed = false;
            lhs->delete_children();
        }
        loop->children.push_back(node);
    });
    visit_one_to_one({vpiCondition}, obj_h, [&](AST::AstNode *node) { loop->children.push_back(node); });
    visit_one_to_many({vpiForIncStmt}, obj_h, [&](AST::AstNode *node) {
        if (node->type == AST::AST_ASSIGN_LE)
            node->type = AST::AST_ASSIGN_EQ;
        loop->children.push_back(node);
    });
    visit_one_to_one({vpiStmt}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (node->type != AST::AST_BLOCK) {
                auto *statements = make_ast_node(AST::AST_BLOCK);
                statements->str = current_node->str; // Needed in simplify step
                statements->children.push_back(node);
                loop->children.push_back(statements);
            } else {
                if (node->str == "") {
                    node->str = loop->str;
                }
                loop->children.push_back(node);
            }
        }
    });
    current_node->children.push_back(loop);
    transform_breaks_continues(loop, current_node);
}

void UhdmAst::process_gen_scope()
{
    current_node = make_ast_node(AST::AST_GENBLOCK);
    visit_one_to_many({vpiTypedef}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            move_type_to_new_typedef(current_node, node);
        }
    });

    visit_one_to_many(
      {vpiParameter, vpiParamAssign, vpiNet, vpiArrayNet, vpiVariables, vpiContAssign, vpiProcess, vpiModule, vpiGenScopeArray, vpiTaskFunc}, obj_h,
      [&](AST::AstNode *node) {
          if (node) {
              if (get_attribute(node, attr_id::is_type_parameter)) {
                  // Don't process type parameters.
                  delete node;
                  return;
              }
              add_or_replace_child(current_node, node);
          }
      });
}

void UhdmAst::process_case()
{
    current_node = make_ast_node(AST::AST_CASE);
    visit_one_to_one({vpiCondition}, obj_h, [&](AST::AstNode *node) { current_node->children.push_back(node); });
    visit_one_to_many({vpiCaseItem}, obj_h, [&](AST::AstNode *node) { current_node->children.push_back(node); });
}

void UhdmAst::process_case_item()
{
    auto cond_type = AST::AST_COND;
    if (vpiHandle parent_h = vpi_handle(vpiParent, obj_h)) {
        switch (vpi_get(vpiCaseType, parent_h)) {
        case vpiCaseExact:
            cond_type = AST::AST_COND;
            break;
        case vpiCaseX:
            cond_type = AST::AST_CONDX;
            break;
        case vpiCaseZ:
            cond_type = AST::AST_CONDZ;
            break;
        default: {
            const uhdm_handle *const handle = (const uhdm_handle *)obj_h;
            const UHDM::BaseClass *const object = (const UHDM::BaseClass *)handle->object;
            report_error("%.*s:%d: Unknown case type", (int)object->VpiFile().length(), object->VpiFile().data(), object->VpiLineNo());
        }
        }
        vpi_release_handle(parent_h);
    }
    current_node = make_ast_node(cond_type);
    vpiHandle itr = vpi_iterate(vpiExpr, obj_h);
    while (vpiHandle expr_h = vpi_scan(itr)) {
        // case ... inside statement, the operation is stored in UHDM inside case items
        // Retrieve just the InsideOp arguments here, we don't add any special handling
        if (vpi_get(vpiType, expr_h) == vpiOperation && vpi_get(vpiOpType, expr_h) == vpiInsideOp) {
            visit_one_to_many({vpiOperand}, expr_h, [&](AST::AstNode *node) {
                // Currently we are adding nodes directly to ancestor
                // inside process_list_op, so after this function, we have
                // nodes already in `current_node`.
                // We should probably refactor this to return node instead.
                // For now, make sure this function doesn't return any nodes.
                log_assert(node == nullptr);
            });
            // vpiListOp is returned in 2 cases:
            // a, b, c ... -> multiple vpiListOp with single item
            // [a : b] -> single vpiListOp with 2 items
            // single item is handled by default,
            // here handle 2 items with custom low_high_bound attribute
            if (current_node->children.size() == 2) {
                auto block = make_ast_node(AST::AST_BLOCK);
                block->children = std::move(current_node->children);
                current_node->children.clear();
                current_node->children.push_back(block);
                current_node->attributes[UhdmAst::low_high_bound()] = AST::AstNode::mkconst_int(1, false, 1);
            }
        } else {
            UhdmAst uhdm_ast(this, shared, indent + "  ");
            auto *node = uhdm_ast.process_object(expr_h);
            if (node) {
                current_node->children.push_back(node);
            }
        }
        vpi_release_handle(expr_h);
    }
    vpi_release_handle(itr);
    if (current_node->children.empty()) {
        current_node->children.push_back(new AST::AstNode(AST::AST_DEFAULT));
    }
    visit_one_to_one({vpiStmt}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (node->type != AST::AST_BLOCK) {
                auto block_node = new AST::AstNode(AST::AST_BLOCK);
                block_node->children.push_back(node);
                node = block_node;
            }
            current_node->children.push_back(node);
        }
    });
}

void UhdmAst::process_range(const UHDM::BaseClass *object)
{
    current_node = make_ast_node(AST::AST_RANGE);
    visit_one_to_one({vpiLeftRange, vpiRightRange}, obj_h, [&](AST::AstNode *node) { current_node->children.push_back(node); });
    if (current_node->children.size() > 0) {
        if (current_node->children[0]->str == "unsized") {
            log_error("%.*s:%d: Currently not supported object of type 'unsized range'\n", (int)object->VpiFile().length(), object->VpiFile().data(),
                      object->VpiLineNo());
        }
    }
    if (current_node->children.size() > 1) {
        if (current_node->children[1]->str == "unsized") {
            log_error("%.*s:%d: Currently not supported object of type 'unsized range'\n", (int)object->VpiFile().length(), object->VpiFile().data(),
                      object->VpiLineNo());
        }
    }
}

void UhdmAst::process_return()
{
    current_node = make_ast_node(AST::AST_ASSIGN_EQ);
    auto func_node = find_ancestor({AST::AST_FUNCTION, AST::AST_TASK});
    if (!func_node->children.empty()) {
        auto lhs = new AST::AstNode(AST::AST_IDENTIFIER);
        lhs->str = func_node->children[0]->str;
        current_node->children.push_back(lhs);
    }
    visit_one_to_one({vpiCondition}, obj_h, [&](AST::AstNode *node) { current_node->children.push_back(node); });
}

void UhdmAst::process_function()
{
    current_node = make_ast_node(vpi_get(vpiType, obj_h) == vpiFunction ? AST::AST_FUNCTION : AST::AST_TASK);
    visit_one_to_one({vpiReturn}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            auto net_type = vpi_get(vpiNetType, obj_h);
            node->is_reg = net_type == vpiReg;
            node->str = current_node->str;
            current_node->children.push_back(node);
        }
    });
    visit_one_to_many({vpiParameter, vpiParamAssign}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (get_attribute(node, attr_id::is_type_parameter)) {
                // Don't process type parameters.
                delete node;
                return;
            }
            add_or_replace_child(current_node, node);
        }
    });
    visit_one_to_many({vpiIODecl}, obj_h, [&](AST::AstNode *node) {
        node->type = AST::AST_WIRE;
        node->port_id = shared.next_port_id();
        current_node->children.push_back(node);
    });
    visit_one_to_many({vpiVariables}, obj_h, [&](AST::AstNode *node) { current_node->children.push_back(node); });
    visit_one_to_one({vpiStmt}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->children.push_back(node);
        }
    });
}

void UhdmAst::process_hier_path()
{
    AST::AstNode *top_node = nullptr;
    visit_one_to_many({vpiActual}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (node->str.find('[') != std::string::npos)
                node->str = node->str.substr(0, node->str.find('['));
            // for first node, just set correct string and move any children
            if (!top_node) {
                current_node = node;
                top_node = current_node;
            } else {
                if (node->type == AST::AST_IDENTIFIER && !node->str.empty()) {
                    node->type = static_cast<AST::AstNodeType>(AST::Extended::AST_DOT);
                    top_node->children.push_back(node);
                    top_node = node;
                } else {
                    top_node->children.push_back(node->children[0]);
                    node->children.erase(node->children.begin());
                    delete node;
                }
            }
        }
    });
}

void UhdmAst::process_gen_scope_array()
{
    current_node = make_ast_node(AST::AST_GENBLOCK);
    visit_one_to_many({vpiGenScope}, obj_h, [&](AST::AstNode *genscope_node) {
        for (auto *child : genscope_node->children) {
            if (child->type == AST::AST_PARAMETER || child->type == AST::AST_LOCALPARAM) {
                auto param_str = child->str.substr(1);
                auto array_str = "[" + param_str + "]";
                visitEachDescendant(genscope_node, [&](AST::AstNode *node) {
                    auto pos = node->str.find(array_str);
                    if (pos != std::string::npos) {
                        node->type = AST::AST_PREFIX;
                        auto *param = new AST::AstNode(AST::AST_IDENTIFIER);
                        param->str = child->str;
                        node->children.push_back(param);
                        auto bracket = node->str.rfind(']');
                        if (bracket + 2 <= node->str.size()) {
                            auto *field = new AST::AstNode(AST::AST_IDENTIFIER);
                            field->str = "\\" + node->str.substr(bracket + 2);
                            node->children.push_back(field);
                        }
                        node->str = node->str.substr(0, node->str.find('['));
                    }
                });
            }
        }
        current_node->children.insert(current_node->children.end(), genscope_node->children.begin(), genscope_node->children.end());
        genscope_node->children.clear();
        delete genscope_node;
    });
}

void UhdmAst::process_tagged_pattern()
{
    auto assign_node = find_ancestor({AST::AST_ASSIGN, AST::AST_ASSIGN_EQ, AST::AST_ASSIGN_LE});
    auto assign_type = AST::AST_ASSIGN;
    AST::AstNode *lhs_node = nullptr;
    if (assign_node) {
        assign_type = assign_node->type;
        lhs_node = assign_node->children[0]->clone();
    } else {
        lhs_node = new AST::AstNode(AST::AST_IDENTIFIER);
        auto ancestor = find_ancestor({AST::AST_WIRE, AST::AST_MEMORY, AST::AST_PARAMETER, AST::AST_LOCALPARAM});
        if (!ancestor) {
            const uhdm_handle *const handle = (const uhdm_handle *)obj_h;
            const UHDM::BaseClass *const object = (const UHDM::BaseClass *)handle->object;
            report_error("%.*s:%d: Couldn't find ancestor for tagged pattern!\n", (int)object->VpiFile().length(), object->VpiFile().data(),
                         object->VpiLineNo());
        }
        lhs_node->str = ancestor->str;
    }
    current_node = new AST::AstNode(assign_type);
    current_node->children.push_back(lhs_node);
    if (auto ref_typespec_h = vpi_handle(vpiTypespec, obj_h)) {
        if (auto typespec_h = vpi_handle(vpiActual, ref_typespec_h)) {
            if (vpi_get(vpiType, typespec_h) == vpiStringTypespec) {
                std::string field_name = vpi_get_str(vpiName, typespec_h);
                if (field_name != "default") { // TODO: better support of the default keyword
                    auto field = new AST::AstNode(static_cast<AST::AstNodeType>(AST::Extended::AST_DOT));
                    field->str = field_name;
                    current_node->children[0]->children.push_back(field);
                }
            } else if (vpi_get(vpiType, typespec_h) == vpiIntegerTypespec) {
                s_vpi_value val;
                vpi_get_value(typespec_h, &val);
                auto range = new AST::AstNode(AST::AST_RANGE);
                auto index = AST::AstNode::mkconst_int(val.value.integer, false);
                range->children.push_back(index);
                current_node->children[0]->children.push_back(range);
            }
            vpi_release_handle(typespec_h);
        }
        vpi_release_handle(ref_typespec_h);
    }
    visit_one_to_one({vpiPattern}, obj_h, [&](AST::AstNode *node) { current_node->children.push_back(node); });
}

void UhdmAst::process_logic_var()
{
    current_node = make_ast_node(AST::AST_WIRE);
    current_node->is_logic = true;
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    // TODO: add const attribute, but it seems it is little more
    // then just setting boolean value
    // current_node->is_const = vpi_get(vpiConstantVariable, obj_h);
    visit_one_to_one({vpiTypespec}, obj_h, [&](AST::AstNode *node) {
        if (node->str.empty()) {
            // anonymous typespec, move the children to variable
            current_node->type = node->type;
            current_node->children = std::move(node->children);
            copy_packed_unpacked_attribute(node, current_node);
        } else {
            auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
            wiretype_node->str = node->str;
            current_node->children.push_back(wiretype_node);
            current_node->is_custom_type = true;
        }
        current_node->is_signed = node->is_signed;
        delete node;
    });
    visit_default_expr(obj_h);
}

void UhdmAst::process_sys_func_call()
{
    current_node = make_ast_node(AST::AST_FCALL);

    std::string task_calls[] = {"\\$display", "\\$monitor", "\\$write", "\\$time", "\\$readmemh", "\\$readmemb", "\\$finish", "\\$stop"};

    if (current_node->str == "\\$signed") {
        current_node->type = AST::AST_TO_SIGNED;
    } else if (current_node->str == "\\$unsigned") {
        current_node->type = AST::AST_TO_UNSIGNED;
    } else if (std::find(std::begin(task_calls), std::end(task_calls), current_node->str) != std::end(task_calls)) {
        current_node->type = AST::AST_TCALL;
    }

    visit_one_to_many({vpiArgument}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->children.push_back(node);
        }
    });

    if (current_node->str == "\\$display" || current_node->str == "\\$write") {
        // According to standard, %h and %x mean the same, but %h is currently unsupported by mainline yosys
        std::string replaced_string = std::regex_replace(current_node->children[0]->str, std::regex("%[h|H]"), "%x");
        delete current_node->children[0];
        current_node->children[0] = AST::AstNode::mkconst_str(replaced_string);
    }

    std::string remove_backslash[] = {"\\$display", "\\$strobe",   "\\$write",    "\\$monitor", "\\$time",    "\\$finish",
                                      "\\$stop",    "\\$dumpfile", "\\$dumpvars", "\\$dumpon",  "\\$dumpoff", "\\$dumpall"};

    if (std::find(std::begin(remove_backslash), std::end(remove_backslash), current_node->str) != std::end(remove_backslash))
        current_node->str = current_node->str.substr(1);
}

void UhdmAst::process_tf_call(AST::AstNodeType type)
{
    current_node = make_ast_node(type);
    visit_one_to_many({vpiArgument}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (node->type == AST::AST_PARAMETER || node->type == AST::AST_LOCALPARAM) {
                node->type = AST::AST_IDENTIFIER;
                node->children.clear();
            }
            current_node->children.push_back(node);
        }
    });

    // Calls to functions imported from packages do not contain package name in vpiName. A full function name, containing package name,
    // is necessary e.g. when call to a function is used as a value assigned to a port of a module instantiated inside generate for loop.
    // However, we can't use full function name when it refers to a module's local function.
    // To make it work the called function name is used instead of vpiName from the call object only when it contains package name (detected here
    // by presence of "::").
    // TODO(mglb): This can fail when "::" is just a part of an escaped identifier. Handle such cases properly here and in other places.
    const uhdm_handle *const handle = (const uhdm_handle *)obj_h;
    if (handle->type == UHDM::uhdmfunc_call) {
        const auto *const base_object = (const UHDM::BaseClass *)handle->object;
        const auto *const fcall = base_object->Cast<const UHDM::func_call *>();
        if (fcall->Function()) {
            auto fname = fcall->Function()->VpiFullName();
            if (fname.find("::") != std::string_view::npos) {
                current_node->str = fname;
                sanitize_symbol_name(current_node->str);
            }
        }
    }
}

void UhdmAst::process_immediate_assert()
{
    current_node = make_ast_node(AST::AST_ASSERT);
    visit_one_to_one({vpiExpr}, obj_h, [&](AST::AstNode *n) {
        if (n) {
            current_node->children.push_back(n);
        }
    });
}

void UhdmAst::process_logic_typespec()
{
    current_node = make_ast_node(AST::AST_WIRE);
    current_node->is_logic = true;
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    if (!current_node->str.empty() && current_node->str.find("::") == std::string::npos) {
        std::string package_name = "";
        if (vpiHandle instance_h = vpi_handle(vpiInstance, obj_h)) {
            if (vpi_get(vpiType, instance_h) == vpiPackage) {
                package_name = get_object_name(instance_h, {vpiDefName});
                current_node->str = package_name + "::" + current_node->str.substr(1);
            }
            vpi_release_handle(instance_h);
        }
    }
    visit_one_to_many({vpiRange}, obj_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
    if (auto ref_elemtypespec_h = vpi_handle(vpiElemTypespec, obj_h)) {
        if (auto elemtypespec_h = vpi_handle(vpiActual, ref_elemtypespec_h)) {
            visit_one_to_many({vpiRange}, elemtypespec_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
            vpi_release_handle(elemtypespec_h);
        }
        vpi_release_handle(ref_elemtypespec_h);
    }

    if (packed_ranges.empty())
        packed_ranges.push_back(make_range(0, 0));
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
}

void UhdmAst::process_int_typespec()
{
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    current_node = make_ast_node(AST::AST_WIRE);
    packed_ranges.push_back(make_range(31, 0));
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
}

void UhdmAst::process_shortint_typespec()
{
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    current_node = make_ast_node(AST::AST_WIRE);
    packed_ranges.push_back(make_range(15, 0));
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
}

void UhdmAst::process_longint_typespec()
{
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    current_node = make_ast_node(AST::AST_WIRE);
    packed_ranges.push_back(make_range(63, 0));
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
}

void UhdmAst::process_shortreal_typespec()
{
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    current_node = make_ast_node(AST::AST_WIRE);
    packed_ranges.push_back(make_range(31, 0));
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
}

void UhdmAst::process_byte_typespec()
{
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    current_node = make_ast_node(AST::AST_WIRE);
    packed_ranges.push_back(make_range(7, 0));
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
}

void UhdmAst::process_time_typespec()
{
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    current_node = make_ast_node(AST::AST_WIRE);
    packed_ranges.push_back(make_range(63, 0));
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
    current_node->is_signed = false;
}

void UhdmAst::process_string_var()
{
    current_node = make_ast_node(AST::AST_WIRE);
    current_node->is_string = true;
    // FIXME:
    // this is only basic support for strings,
    // currently yosys doesn't support dynamic resize of wire
    // based on string size
    // here we try to get size of string based on provided const string
    // if it is not available, we are setting size to explicite 64 bits
    visit_one_to_one({vpiExpr}, obj_h, [&](AST::AstNode *expr_node) {
        if (expr_node->type == AST::AST_CONSTANT) {
            auto left_const = AST::AstNode::mkconst_int(expr_node->range_left, true);
            auto right_const = AST::AstNode::mkconst_int(expr_node->range_right, true);
            auto range = make_ast_node(AST::AST_RANGE, {left_const, right_const});
            current_node->children.push_back(range);
        }
    });
    if (current_node->children.empty()) {
        auto left_const = AST::AstNode::mkconst_int(64, true);
        auto right_const = AST::AstNode::mkconst_int(0, true);
        auto range = make_ast_node(AST::AST_RANGE, {left_const, right_const});
        current_node->children.push_back(range);
    }
    visit_default_expr(obj_h);
}

void UhdmAst::process_string_typespec()
{
    current_node = make_ast_node(AST::AST_WIRE);
    current_node->is_string = true;
    // FIXME:
    // this is only basic support for strings,
    // currently yosys doesn't support dynamic resize of wire
    // based on string size
    // here, we are setting size to explicite 64 bits
    auto left_const = AST::AstNode::mkconst_int(64, true);
    auto right_const = AST::AstNode::mkconst_int(0, true);
    auto range = make_ast_node(AST::AST_RANGE, {left_const, right_const});
    current_node->children.push_back(range);
}

void UhdmAst::process_bit_typespec()
{
    current_node = make_ast_node(AST::AST_WIRE);
    visit_range(obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->children.push_back(node);
        }
    });
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
}

void UhdmAst::process_repeat()
{
    auto loop_id = shared.next_loop_id();
    current_node = make_ast_node(AST::AST_BLOCK);
    current_node->str = "$repeatdecl_block" + std::to_string(loop_id);
    auto *loop = make_ast_node(AST::AST_REPEAT);
    loop->str = "$loop" + std::to_string(loop_id);
    current_node->children.push_back(loop);
    visit_one_to_one({vpiCondition}, obj_h, [&](AST::AstNode *node) { loop->children.push_back(node); });
    visit_one_to_one({vpiStmt}, obj_h, [&](AST::AstNode *node) {
        if (node->type != AST::AST_BLOCK) {
            node = new AST::AstNode(AST::AST_BLOCK, node);
        }
        if (node->str.empty()) {
            node->str = loop->str; // Needed in simplify step
        }
        loop->children.push_back(node);
    });
    transform_breaks_continues(loop, current_node);
}

void UhdmAst::process_var_select()
{
    current_node = make_ast_node(AST::AST_IDENTIFIER);
    visit_one_to_many({vpiIndex}, obj_h, [&](AST::AstNode *node) {
        if (node->str == current_node->str) {
            for (auto child : node->children) {
                current_node->children.push_back(child);
            }
            node->children.clear();
            delete node;
        } else {
            auto range_node = new AST::AstNode(AST::AST_RANGE);
            range_node->filename = current_node->filename;
            range_node->location = current_node->location;
            range_node->children.push_back(node);
            current_node->children.push_back(range_node);
        }
    });
}

void UhdmAst::process_port()
{
    current_node = make_ast_node(AST::AST_WIRE);
    current_node->port_id = shared.next_port_id();
    vpiHandle lowConn_h = vpi_handle(vpiLowConn, obj_h);
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    if (lowConn_h) {
        vpiHandle actual_h = vpi_handle(vpiActual, lowConn_h);
        auto actual_type = vpi_get(vpiType, actual_h);
        switch (actual_type) {
        case vpiModport: {
            vpiHandle iface_h = vpi_handle(vpiInterface, actual_h);
            if (iface_h) {
                std::string cellName, ifaceName;
                if (auto s = vpi_get_str(vpiName, actual_h)) {
                    cellName = s;
                    sanitize_symbol_name(cellName);
                }
                if (auto s = vpi_get_str(vpiDefName, iface_h)) {
                    ifaceName = s;
                    sanitize_symbol_name(ifaceName);
                }
                current_node->type = AST::AST_INTERFACEPORT;
                auto typeNode = new AST::AstNode(AST::AST_INTERFACEPORTTYPE);
                // Skip '\' in cellName
                typeNode->str = ifaceName + '.' + cellName.substr(1, cellName.length());
                current_node->children.push_back(typeNode);
                vpi_release_handle(iface_h);
            }
            break;
        }
        case vpiInterface: {
            auto typeNode = new AST::AstNode(AST::AST_INTERFACEPORTTYPE);
            if (auto s = vpi_get_str(vpiDefName, actual_h)) {
                typeNode->str = s;
                sanitize_symbol_name(typeNode->str);
            }
            current_node->type = AST::AST_INTERFACEPORT;
            current_node->children.push_back(typeNode);
            break;
        }
        case vpiLogicVar:
        case vpiLogicNet: {
            current_node->is_logic = true;
            current_node->is_signed = vpi_get(vpiSigned, actual_h);
            visit_one_to_many({vpiRange}, actual_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
            break;
        }
        case vpiPackedArrayVar:
            visit_one_to_many({vpiElement}, actual_h, [&](AST::AstNode *node) {
                if (node && GetSize(node->children) == 1) {
                    current_node->children.push_back(node->children[0]->clone());
                    if (node->children[0]->type == AST::AST_WIRETYPE) {
                        current_node->is_custom_type = true;
                    }
                }
                delete node;
            });
            visit_one_to_many({vpiRange}, actual_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
            break;
        case vpiPackedArrayNet:
            visit_one_to_many({vpiRange}, actual_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
            break;
        case vpiArrayVar:
            visit_one_to_many({vpiElement}, actual_h, [&](AST::AstNode *node) {
                if (node && GetSize(node->children) == 1) {
                    current_node->children.push_back(node->children[0]->clone());
                    if (node->children[0]->type == AST::AST_WIRETYPE) {
                        current_node->is_custom_type = true;
                    }
                }
                delete node;
            });
            visit_one_to_many({vpiRange}, actual_h, [&](AST::AstNode *node) { unpacked_ranges.push_back(node); });
            break;
        case vpiEnumNet:
        case vpiStructNet:
        case vpiArrayNet:
        case vpiStructVar:
        case vpiUnionVar:
        case vpiEnumVar:
        case vpiBitVar:
        case vpiByteVar:
        case vpiShortIntVar:
        case vpiLongIntVar:
        case vpiIntVar:
        case vpiIntegerVar:
            break;
        default: {
            const uhdm_handle *const handle = (const uhdm_handle *)actual_h;
            const UHDM::BaseClass *const object = (const UHDM::BaseClass *)handle->object;
            report_error("%.*s:%d: Encountered unhandled type in process_port: %s\n", (int)object->VpiFile().length(), object->VpiFile().data(),
                         object->VpiLineNo(), UHDM::VpiTypeName(actual_h).c_str());
            break;
        }
        }
        vpi_release_handle(actual_h);
        vpi_release_handle(lowConn_h);
    }
    visit_one_to_one({vpiTypedef}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            if (current_node->children.empty() || current_node->children[0]->type != AST::AST_WIRETYPE) {
                if (!node->str.empty()) {
                    auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
                    wiretype_node->str = node->str;
                    // wiretype needs to be 1st node (if port have also another range nodes)
                    current_node->children.insert(current_node->children.begin(), wiretype_node);
                    current_node->is_custom_type = true;
                } else {
                    // anonymous typedef, just move children
                    current_node->children = std::move(node->children);
                }
            }
            current_node->is_signed = current_node->is_signed || node->is_signed;
            delete node;
        }
    });
    if (const int n = vpi_get(vpiDirection, obj_h)) {
        if (n == vpiInput) {
            current_node->is_input = true;
        } else if (n == vpiOutput) {
            current_node->is_output = true;
        } else if (n == vpiInout) {
            current_node->is_input = true;
            current_node->is_output = true;
        }
    }
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
}

void UhdmAst::process_net()
{
    current_node = make_ast_node(AST::AST_WIRE);
    auto net_type = vpi_get(vpiNetType, obj_h);
    current_node->is_reg = net_type == vpiReg;
    current_node->is_output = net_type == vpiOutput;
    current_node->is_logic = !current_node->is_reg;
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
    visit_one_to_one({vpiTypespec}, obj_h, [&](AST::AstNode *node) {
        if (!node)
            return;
        if (!node->str.empty()) {
            auto wiretype_node = new AST::AstNode(AST::AST_WIRETYPE);
            wiretype_node->str = node->str;
            // wiretype needs to be 1st node
            current_node->children.insert(current_node->children.begin(), wiretype_node);
            current_node->is_custom_type = true;
        } else {
            // Ranges from the typespec are copied to the current node as attributes.
            // So that multiranges can be replaced with a single range as a node later.
            copy_packed_unpacked_attribute(node, current_node);
        }
        delete node;
    });
    iterate_one_to_many({vpiAttribute}, obj_h, [&](vpiHandle h) {
        std::string name = vpi_get_str(vpiName, h);
        if (name == "keep")
            current_node->attributes[ID::keep] = AST::AstNode::mkconst_int(1, false, 32);
    });
}

void UhdmAst::process_parameter()
{
    auto type = vpi_get(vpiLocalParam, obj_h) == 1 ? AST::AST_LOCALPARAM : AST::AST_PARAMETER;
    current_node = make_ast_node(type);
    std::vector<AST::AstNode *> packed_ranges;   // comes before wire name
    std::vector<AST::AstNode *> unpacked_ranges; // comes after wire name
    visit_one_to_many({vpiRange}, obj_h, [&](AST::AstNode *node) { unpacked_ranges.push_back(node); });
    if (vpiHandle ref_typespec_h = vpi_handle(vpiTypespec, obj_h)) {
        if (vpiHandle typespec_h = vpi_handle(vpiActual, ref_typespec_h)) {
            int typespec_type = vpi_get(vpiType, typespec_h);
            switch (typespec_type) {
            case vpiBitTypespec:
            case vpiLogicTypespec: {
                current_node->is_logic = true;
                visit_one_to_many({vpiRange}, typespec_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
                break;
            }
            case vpiByteTypespec: {
                packed_ranges.push_back(make_range(7, 0));
                break;
            }
            case vpiEnumTypespec:
            case vpiRealTypespec:
            case vpiStringTypespec: {
                break;
            }
            case vpiIntTypespec:
            case vpiIntegerTypespec: {
                visit_one_to_many({vpiRange}, typespec_h, [&](AST::AstNode *node) { packed_ranges.push_back(node); });
                if (packed_ranges.empty()) {
                    packed_ranges.push_back(make_range(31, 0));
                }
                break;
            }
            case vpiShortIntTypespec: {
                packed_ranges.push_back(make_range(15, 0));
                break;
            }
            case vpiTimeTypespec:
            case vpiLongIntTypespec: {
                packed_ranges.push_back(make_range(63, 0));
                break;
            }
            case vpiUnionTypespec:
            case vpiStructTypespec: {
                visit_one_to_one({vpiTypespec}, obj_h, [&](AST::AstNode *node) {
                    if (node && !node->str.empty()) {
                        auto wiretype_node = make_ast_node(AST::AST_WIRETYPE);
                        wiretype_node->str = node->str;
                        current_node->children.push_back(wiretype_node);
                    }
                    current_node->is_custom_type = true;
                    auto it = shared.param_types.find(current_node->str);
                    if (it == shared.param_types.end()) {
                        shared.param_types.insert(std::make_pair(current_node->str, node));
                    } else {
                        delete node;
                    }
                });
                break;
            }
            case vpiPackedArrayTypespec:
            case vpiArrayTypespec: {
                visit_one_to_one({vpiElemTypespec}, typespec_h, [&](AST::AstNode *node) {
                    if (!node->str.empty()) {
                        auto wiretype_node = make_ast_node(AST::AST_WIRETYPE);
                        wiretype_node->str = node->str;
                        current_node->children.push_back(wiretype_node);
                        current_node->is_custom_type = true;
                        auto it = shared.param_types.find(current_node->str);
                        if (it == shared.param_types.end())
                            shared.param_types.insert(std::make_pair(current_node->str, node->clone()));
                    } else {
                        // parameter type
                        auto it = shared.param_types.find(current_node->str);
                        if (it == shared.param_types.end())
                            shared.param_types.insert(std::make_pair(current_node->str, node->clone()));
                    }
                    if (node && node->attributes.count(UhdmAst::packed_ranges())) {
                        for (auto r : node->attributes[UhdmAst::packed_ranges()]->children) {
                            packed_ranges.push_back(r->clone());
                        }
                    }
                    delete node;
                });
                break;
            }
            default: {
                const uhdm_handle *const handle = (const uhdm_handle *)typespec_h;
                const UHDM::BaseClass *const object = (const UHDM::BaseClass *)handle->object;
                report_error("%.*s:%d: Encountered unhandled typespec in process_parameter: '%.*s' of type '%s'\n", (int)object->VpiFile().length(),
                             object->VpiFile().data(), object->VpiLineNo(), (int)object->VpiName().length(), object->VpiName().data(),
                             UHDM::VpiTypeName(typespec_h).c_str());
                break;
            }
            }
            vpi_release_handle(typespec_h);
        }
        vpi_release_handle(ref_typespec_h);
    }
    AST::AstNode *constant_node = process_value(obj_h);
    if (constant_node) {
        constant_node->filename = current_node->filename;
        constant_node->location = current_node->location;
        current_node->children.push_back(constant_node);
    }
    add_multirange_wire(current_node, packed_ranges, unpacked_ranges);
}

void UhdmAst::process_byte_var()
{
    current_node = make_ast_node(AST::AST_WIRE);
    current_node->children.push_back(make_range(7, 0));
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
}

void UhdmAst::process_long_int_var()
{
    current_node = make_ast_node(AST::AST_WIRE);
    current_node->children.push_back(make_range(63, 0));
    current_node->is_signed = vpi_get(vpiSigned, obj_h);
}

void UhdmAst::process_immediate_cover()
{
    current_node = make_ast_node(AST::AST_COVER);
    visit_one_to_one({vpiExpr}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->children.push_back(node);
        }
    });
}

void UhdmAst::process_immediate_assume()
{
    current_node = make_ast_node(AST::AST_ASSUME);
    visit_one_to_one({vpiExpr}, obj_h, [&](AST::AstNode *node) {
        if (node) {
            current_node->children.push_back(node);
        }
    });
}

void UhdmAst::process_while()
{
    auto loop_id = shared.next_loop_id();
    current_node = make_ast_node(AST::AST_BLOCK);
    current_node->str = "$whiledecl_block" + std::to_string(loop_id);
    auto *loop = make_ast_node(AST::AST_WHILE);
    loop->str = "$loop" + std::to_string(loop_id);
    current_node->children.push_back(loop);
    visit_one_to_one({vpiCondition}, obj_h, [&](AST::AstNode *node) { loop->children.push_back(node); });
    visit_one_to_one({vpiStmt}, obj_h, [&](AST::AstNode *node) {
        if (node->type != AST::AST_BLOCK) {
            node = make_ast_node(AST::AST_BLOCK, {node});
        }
        if (node->str.empty()) {
            node->str = loop->str; // Needed in simplify step
        }
        loop->children.push_back(node);
    });
    transform_breaks_continues(loop, current_node);
}

void UhdmAst::process_gate()
{
    current_node = make_ast_node(AST::AST_PRIMITIVE);
    switch (vpi_get(vpiPrimType, obj_h)) {
    case vpiAndPrim:
        current_node->str = "and";
        break;
    case vpiNandPrim:
        current_node->str = "nand";
        break;
    case vpiNorPrim:
        current_node->str = "nor";
        break;
    case vpiOrPrim:
        current_node->str = "or";
        break;
    case vpiXorPrim:
        current_node->str = "xor";
        break;
    case vpiXnorPrim:
        current_node->str = "xnor";
        break;
    case vpiBufPrim:
        current_node->str = "buf";
        break;
    case vpiNotPrim:
        current_node->str = "not";
        break;
    default:
        log_file_error(current_node->filename, current_node->location.first_line, "Encountered unhandled gate type: %s", current_node->str.c_str());
        break;
    }
    visit_one_to_many({vpiPrimTerm}, obj_h, [&](AST::AstNode *node) { current_node->children.push_back(node); });
}

void UhdmAst::process_primterm()
{
    current_node = make_ast_node(AST::AST_ARGUMENT);
    visit_one_to_one({vpiExpr}, obj_h, [&](AST::AstNode *node) { current_node->children.push_back(node); });
}

void UhdmAst::process_unsupported_stmt(const UHDM::BaseClass *object, bool is_error)
{
    const auto log_func = is_error ? log_error : log_warning;
    std::string prefix = object->VpiLineNo() ? (std::string(object->VpiFile()) + ":" + std::to_string(object->VpiLineNo()) + ": ") : "";
    log_func("%sCurrently not supported object of type '%s'\n", prefix.c_str(), UHDM::VpiTypeName(obj_h).c_str());
}

void UhdmAst::process_type_parameter()
{
    current_node = make_ast_node(AST::AST_PARAMETER);

    // Use an attribute to distinguish "type parameters" from other parameters
    set_attribute(current_node, attr_id::is_type_parameter, AST::AstNode::mkconst_int(1, false, 1));
    std::string renamed_enum;

    visit_one_to_one({vpiTypespec}, obj_h, [&](AST::AstNode *node) {
        if (!node)
            return;

        if (node->type == AST::AST_WIRE && node->str.empty()) {
            // anonymous type
            get_attribute(current_node, attr_id::is_type_parameter)->str = "anonymous_parameter" + std::to_string(shared.next_anonymous_type_id());
            delete node;
            return;
        }

        if (node->type == AST::AST_ENUM) {
            // Enum typedefs are composed of AST_ENUM and AST_TYPEDEF where the enum shall be renamed,
            // so that the original name used in code is assigned to the AST_TYPEDEF node,
            // and a mangled name is assigned to the AST_ENUM node.
            renamed_enum = node->str + "$enum" + std::to_string(shared.next_enum_id());
        }

        current_node->children.push_back(node->clone());

        // The child stores information about the type assigned to the parameter
        //   this information will be used to rename the module

        // find the typedef for `node` in the upper scope and copy it to .children of the AST_PARAMETER node
        // if unable to find the typedef, continue without error as this could be a globally available type

        if (shared.current_top_node) {
            for (auto child : shared.current_top_node->children) {
                // name of the type we're looking for
                if (child->str == node->str && child->type == AST::AST_TYPEDEF) {
                    current_node->children.push_back(child->clone());
                    break;
                }
            }
        }
        delete node;
    });

    if (!renamed_enum.empty()) {
        for (auto child : current_node->children) {
            if (child->type == AST::AST_TYPEDEF) {
                log_assert(child->children.size() > 0);
                set_attribute(child->children[0], ID::enum_type, AST::AstNode::mkconst_str(renamed_enum));
            }
            if (child->type == AST::AST_ENUM) {
                child->str = renamed_enum;
                // Names of enum variants need to be unique even accross Enums, otherwise Yosys fails.
                for (auto grandchild : child->children) {
                    grandchild->str = renamed_enum + "." + grandchild->str;
                }
            }
        }
    }
}

AST::AstNode *UhdmAst::process_object(vpiHandle obj_handle)
{
    obj_h = obj_handle;
    const unsigned object_type = vpi_get(vpiType, obj_h);
    const uhdm_handle *const handle = (const uhdm_handle *)obj_h;
    const UHDM::BaseClass *const object = (const UHDM::BaseClass *)handle->object;
    for (auto *obj : shared.nonSynthesizableObjects) {
        UHDM::CompareContext ctx;
        if (!object->Compare(obj, &ctx)) {
            log_warning("%.*s:%d: Skipping non-synthesizable object of type '%s'\n", (int)object->VpiFile().length(), object->VpiFile().data(),
                        object->VpiLineNo(), UHDM::VpiTypeName(obj_h).c_str());
            return nullptr;
        }
    }

    if (shared.debug_flag) {
        std::cout << indent << "Object '" << object->VpiName() << "' of type '" << UHDM::VpiTypeName(obj_h) << '\'' << std::endl;
    }

    switch (object_type) {
    case vpiDesign:
        process_design();
        break;
    case vpiParameter:
        process_parameter();
        break;
    case vpiPort:
        process_port();
        break;
    case vpiModule:
        process_module();
        break;
    case vpiStructTypespec:
        process_struct_typespec();
        break;
    case vpiUnionTypespec:
        process_union_typespec();
        break;
    case vpiPackedArrayTypespec:
        process_packed_array_typespec();
        break;
    case vpiArrayTypespec:
        process_array_typespec();
        break;
    case vpiTypespecMember:
        process_typespec_member();
        break;
    case vpiEnumTypespec:
        process_enum_typespec();
        break;
    case vpiEnumConst:
        process_enum_const();
        break;
    case vpiEnumVar:
    case vpiEnumNet:
    case vpiStructVar:
    case vpiStructNet:
    case vpiUnionVar:
        process_custom_var();
        break;
    case vpiShortIntVar:
    case vpiIntVar:
    case vpiIntegerVar:
        process_int_var();
        break;
    case vpiShortRealVar:
    case vpiRealVar:
        process_real_var();
        break;
    case vpiPackedArrayVar:
        process_packed_array_var();
        break;
    case vpiArrayVar:
        process_array_var();
        break;
    case vpiParamAssign:
        process_param_assign();
        break;
    case vpiContAssign:
        process_cont_assign();
        break;
    case vpiAssignStmt:
    case vpiAssignment:
        process_assignment(object);
        break;
    case vpiInterfaceTypespec:
    case vpiRefVar:
    case vpiRefObj:
    case vpiRefTypespec:
        current_node = make_ast_node(AST::AST_IDENTIFIER);
        break;
    case vpiNet:
        process_net();
        break;
    case vpiArrayNet:
        process_array_net(object);
        break;
    case vpiPackedArrayNet:
        process_packed_array_net();
        break;
    case vpiPackage:
        process_package();
        break;
    case vpiInterface:
        process_interface();
        break;
    case vpiModport:
        process_modport();
        break;
    case vpiIODecl:
        process_io_decl();
        break;
    case vpiAlways:
        process_always();
        break;
    case vpiEventControl:
        process_event_control(object);
        break;
    case vpiInitial:
        process_initial();
        break;
    case vpiFinal:
        process_unsupported_stmt(object, false);
        break;
    case vpiNamedBegin:
        process_begin(true);
        break;
    case vpiBegin:
        process_begin(false);
        break;
    case vpiCondition:
    case vpiOperation:
        process_operation(object);
        break;
    case vpiTaggedPattern:
        process_tagged_pattern();
        break;
    case vpiBitSelect:
        process_bit_select();
        break;
    case vpiPartSelect:
        process_part_select();
        break;
    case vpiIndexedPartSelect:
        process_indexed_part_select();
        break;
    case vpiVarSelect:
        process_var_select();
        break;
    case vpiIf:
    case vpiIfElse:
        process_if_else();
        break;
    case vpiFor:
        process_for();
        break;
    case vpiBreak:
        // Will be resolved later by loop processor
        current_node = make_ast_node(static_cast<AST::AstNodeType>(AST::Extended::AST_BREAK));
        break;
    case vpiContinue:
        // Will be resolved later by loop processor
        current_node = make_ast_node(static_cast<AST::AstNodeType>(AST::Extended::AST_CONTINUE));
        break;
    case vpiGenScopeArray:
        process_gen_scope_array();
        break;
    case vpiGenScope:
        process_gen_scope();
        break;
    case vpiCase:
        process_case();
        break;
    case vpiCaseItem:
        process_case_item();
        break;
    case vpiConstant:
        current_node = process_value(obj_h);
        break;
    case vpiRange:
        process_range(object);
        break;
    case vpiReturn:
        process_return();
        break;
    case vpiFunction:
    case vpiTask:
        process_function();
        break;
    case vpiBitVar:
    case vpiLogicVar:
        process_logic_var();
        break;
    case vpiSysFuncCall:
        process_sys_func_call();
        break;
    case vpiFuncCall:
        process_tf_call(AST::AST_FCALL);
        break;
    case vpiTaskCall:
        process_tf_call(AST::AST_TCALL);
        break;
    case vpiImmediateAssert:
        if (!shared.no_assert)
            process_immediate_assert();
        break;
    case vpiAssert:
        if (!shared.no_assert)
            process_unsupported_stmt(object);
        break;
    case vpiHierPath:
        process_hier_path();
        break;
    case UHDM::uhdmimport_typespec:
        break;
    case vpiLogicTypespec:
        process_logic_typespec();
        break;
    case vpiIntTypespec:
    case vpiIntegerTypespec:
        process_int_typespec();
        break;
    case vpiShortIntTypespec:
        process_shortint_typespec();
        break;
    case vpiLongIntTypespec:
        process_longint_typespec();
        break;
    case vpiShortRealTypespec:
        process_shortreal_typespec();
        break;
    case vpiTimeTypespec:
        process_time_typespec();
        break;
    case vpiBitTypespec:
        process_bit_typespec();
        break;
    case vpiByteTypespec:
        process_byte_typespec();
        break;
    case vpiStringVar:
        process_string_var();
        break;
    case vpiStringTypespec:
        process_string_typespec();
        break;
    case vpiRepeat:
        process_repeat();
        break;
    case vpiByteVar:
        process_byte_var();
        break;
    case vpiLongIntVar:
        process_long_int_var();
        break;
    case vpiImmediateCover:
        process_immediate_cover();
        break;
    case vpiImmediateAssume:
        process_immediate_assume();
        break;
    case vpiAssume:
        process_unsupported_stmt(object);
        break;
    case vpiWhile:
        process_while();
        break;
    case vpiGate:
        process_gate();
        break;
    case vpiPrimTerm:
        process_primterm();
        break;
    case vpiClockingBlock:
        process_unsupported_stmt(object);
        break;
    case vpiArrayExpr:
        process_array_expr(object);
        break;
    case vpiTypeParameter:
        process_type_parameter();
        break;
    case vpiProgram:
    default:
        report_error("%.*s:%d: Encountered unhandled object '%.*s' of type '%s'\n", (int)object->VpiFile().length(), object->VpiFile().data(),
                     object->VpiLineNo(), (int)object->VpiName().length(), object->VpiName().data(), UHDM::VpiTypeName(obj_h).c_str());
        break;
    }

    // Check if we initialized the node in switch-case
    if (current_node) {
        if (current_node->type != AST::AST_NONE) {
            return current_node;
        }
    }
    return nullptr;
}

AST::AstNode *UhdmAst::visit_designs(const std::vector<vpiHandle> &designs)
{
    attr_id_init();

    current_node = new AST::AstNode(AST::AST_DESIGN);
    for (auto design : designs) {
        UhdmAst ast(this, shared, indent);
        auto *processed_design_node = ast.process_object(design);
        // Flatten multiple designs into one
        current_node->children = std::move(processed_design_node->children);
        delete processed_design_node;
    }

    for (auto &[name, node] : shared.param_types) {
        delete node;
    }
    shared.param_types.clear();

    // Remove all internal attributes from the AST.
    visitEachDescendant(current_node, delete_internal_attributes);

    attr_id_cleanup();

    return current_node;
}

void UhdmAst::report_error(const char *format, ...) const
{
    va_list args;
    va_start(args, format);
    if (shared.stop_on_error) {
        logv_error(format, args);
    } else {
        logv_warning(format, args);
    }
}

} // namespace systemverilog_plugin
