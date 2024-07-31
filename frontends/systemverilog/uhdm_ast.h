#ifndef _UHDM_AST_H_
#define _UHDM_AST_H_ 1

#include "frontends/ast/ast.h"
#include <vector>
#undef cover

#include "uhdm_ast_shared.h"
#include <memory>
#include <uhdm/uhdm.h>

namespace systemverilog_plugin
{

class AstNodeBuilder;

class UhdmAst
{
  private:
    // Logging method for exclusive use of `uhdmast_assert` macro.
    void uhdmast_assert_log(const char *expr_str, const char *func, const char *file, int line) const;

    // Walks through one-to-many relationships from given parent
    // node through the VPI interface, visiting child nodes belonging to
    // ChildrenNodeTypes that are present in the given object.
    void visit_one_to_many(const std::vector<int> child_node_types, vpiHandle parent_handle, const std::function<void(::Yosys::AST::AstNode *)> &f);

    // Walks through one-to-one relationships from given parent
    // node through the VPI interface, visiting child nodes belonging to
    // ChildrenNodeTypes that are present in the given object.
    void visit_one_to_one(const std::vector<int> child_node_types, vpiHandle parent_handle, const std::function<void(::Yosys::AST::AstNode *)> &f);

    // Iterates through one-to-many relationships from given parent
    // node through the VPI interface, visiting child nodes belonging to
    // ChildrenNodeTypes that are present in the given object.
    void iterate_one_to_many(const std::vector<int> child_node_types, vpiHandle parent_handle, const std::function<void(vpiHandle)> &f);

    // Visit children of type vpiRange that belong to the given parent node.
    void visit_range(vpiHandle obj_h, const std::function<void(::Yosys::AST::AstNode *)> &f);

    // Visit the default expression assigned to a variable.
    void visit_default_expr(vpiHandle obj_h);

    // Reads location info (start/end line/column numbers, file name) from `obj_h` and sets them on `target_node`.
    void apply_location_from_current_obj(::Yosys::AST::AstNode &target_node) const;
    // Reads object name from `obj_h` and assigns it to `target_node`.
    void apply_name_from_current_obj(::Yosys::AST::AstNode &target_node) const;

    // Creates node of specified `type` with location properties read from `obj_h`.
    AstNodeBuilder make_node(::Yosys::AST::AstNodeType type) const;
    // Creates node of specified `type` with location properties and name read from `obj_h`.
    AstNodeBuilder make_named_node(::Yosys::AST::AstNodeType type) const;
    // Creates AST_IDENTIFIER node with specified `id` and location properties read from `obj_h`.
    AstNodeBuilder make_ident(std::string id) const;
    // Creates signed AST_CONSTANT node with specified `value` and location properties read from `obj_h`.
    AstNodeBuilder make_const(int32_t value, uint8_t width = 32) const;
    // Creates unsigned AST_CONSTANT node with specified `value` and location properties read from `obj_h`.
    AstNodeBuilder make_const(uint32_t value, uint8_t width = 32) const;

    // Create an AstNode of the specified type with metadata extracted from
    // the given vpiHandle.
    // OBSOLETE: use `make_node` or `make_named_node` instead.
    ::Yosys::AST::AstNode *make_ast_node(::Yosys::AST::AstNodeType type, std::vector<::Yosys::AST::AstNode *> children = {});

    // Create an identifier AstNode
    // OBSOLETE: use `make_ident` instead.
    ::Yosys::AST::AstNode *make_identifier(std::string name);

    // Makes the passed node a cell node of the specified type
    void make_cell(vpiHandle obj_h, ::Yosys::AST::AstNode *node, std::string type);

    // Moves a type node to the specified node. If a node of the same name already exists there, the type node is deleted.
    void move_type_to_new_typedef(::Yosys::AST::AstNode *current_node, ::Yosys::AST::AstNode *type_node);

    // Go up the UhdmAst to find a parent node of the specified type
    ::Yosys::AST::AstNode *find_ancestor(const std::unordered_set<::Yosys::AST::AstNodeType> &types);

    // Reports that something went wrong with reading the UHDM file
    void report_error(const char *format, ...) const;

    // Processes the value connected to the specified node
    ::Yosys::AST::AstNode *process_value(vpiHandle obj_h);

    // Transforms break and continue nodes into structures accepted by the AST frontend
    void transform_breaks_continues(::Yosys::AST::AstNode *loop, ::Yosys::AST::AstNode *decl_block);

    // The parent UhdmAst
    UhdmAst *parent;

    // Data shared between all UhdmAst objects
    UhdmAstShared &shared;

    // The current VPI/UHDM handle
    vpiHandle obj_h = 0;

    // The current Yosys AST node
    ::Yosys::AST::AstNode *current_node = nullptr;

    // Indentation used for debug printing
    std::string indent;

    // Mapping of names that should be replaced to new names
    std::unordered_map<std::string, std::string> node_renames;

    // Functions that process specific types of nodes
    void process_design();
    void process_parameter();
    void process_port();
    void process_module();
    void process_struct_typespec();
    void process_union_typespec();
    void process_packed_array_typespec();
    void process_array_typespec();
    void process_typespec_member();
    void process_enum_typespec();
    void process_enum_const();
    void process_custom_var();
    void process_int_var();
    void process_real_var();
    void process_array_var();
    void process_packed_array_var();
    void process_param_assign();
    void process_cont_assign();
    void process_cont_assign_net();
    void process_cont_assign_var_init();
    void process_assignment(const UHDM::BaseClass *object);
    void process_net();
    void process_packed_array_net();
    void process_array_net(const UHDM::BaseClass *object);
    void process_package();
    void process_interface();
    void process_modport();
    void process_io_decl();
    void process_always();
    void process_event_control(const UHDM::BaseClass *object);
    void process_initial();
    void process_begin(bool is_named);
    void process_operation(const UHDM::BaseClass *object);
    void process_stream_op();
    void process_list_op();
    void process_cast_op();
    void process_inside_op();
    void process_assignment_pattern_op();
    void process_tagged_pattern();
    void process_bit_select();
    void process_part_select();
    void process_indexed_part_select();
    void process_var_select();
    void process_if_else();
    void process_for();
    void process_gen_scope_array();
    void process_gen_scope();
    void process_case();
    void process_case_item();
    void process_range(const UHDM::BaseClass *object);
    void process_return();
    void process_function();
    void process_logic_var();
    void process_sys_func_call();
    // use for task calls and function calls
    void process_tf_call(::Yosys::AST::AstNodeType type);
    void process_immediate_assert();
    void process_hier_path();
    void process_logic_typespec();
    void process_int_typespec();
    void process_shortint_typespec();
    void process_longint_typespec();
    void process_shortreal_typespec();
    void process_time_typespec();
    void process_bit_typespec();
    void process_string_var();
    void process_string_typespec();
    void process_repeat();
    void process_byte_var();
    void process_byte_typespec();
    void process_long_int_var();
    void process_immediate_cover();
    void process_immediate_assume();
    void process_while();
    void process_gate();
    void process_primterm();
    void process_type_parameter();
    void simplify_parameter(::Yosys::AST::AstNode *parameter, const std::vector<::Yosys::AST::AstNode *> &parameter_scopes);
    void process_unsupported_stmt(const UHDM::BaseClass *object, bool is_error = true);
    void process_array_expr(const UHDM::BaseClass *object);

    UhdmAst(UhdmAst *p, UhdmAstShared &s, const std::string &i) : parent(p), shared(s), indent(i)
    {
        if (parent)
            node_renames = parent->node_renames;
    }

  public:
    UhdmAst(UhdmAstShared &s, const std::string &i = "") : UhdmAst(nullptr, s, i) {}

    // Visits single VPI object and creates proper AST node
    ::Yosys::AST::AstNode *process_object(vpiHandle obj_h);

    // Visits all VPI design objects and returns created ASTs
    ::Yosys::AST::AstNode *visit_designs(const std::vector<vpiHandle> &designs);

    static const ::Yosys::IdString &partial();
    static const ::Yosys::IdString &packed_ranges();
    static const ::Yosys::IdString &unpacked_ranges();
    // set this attribute to force conversion of multirange wire to single range. It is useful to force-convert some memories.
    static const ::Yosys::IdString &force_convert();
    static const ::Yosys::IdString &is_imported();
    static const ::Yosys::IdString &is_simplified_wire();
    static const ::Yosys::IdString &low_high_bound();
    static const ::Yosys::IdString &is_elaborated_module();
};

// Utility for building AstNode trees.
//
// The object members that set AstNode properties return rvalue reference to *this (i.e. to the builder object), so they can be chained.
// The children list is set using call operator (`builder_object({child0, child1, ...})`).
// Build finalization is done through cast operator to either `AstNode*` or `std::unique_ptr<AstNode>`.
//
// Usage example:
//
// 1. Define one or more factory functions for creating base AstNode object:
//
//     const auto make_node = [](AST::AstNodeType type) {
//         auto node = std::make_unique<AST::AstNode>(type);
//         // ...initialize the node if needed...
//         return AstNodeBuilder(std::move(node));
//     };
//
// 2. Use the factories to create a tree:
//
//     // AST::AstNode *const variable_node = ...
//     // AST::AstNode *const value_node = ...
//     AST::AstNode *const assign = //
//       (make_node(AST::AST_ASSIGN_EQ))({
//         (make_node(AST::AST_IDENTIFIER).str(variable_node->str)),
//         (make_node(Yosys::AST::AST_ADD))({
//           (make_node(AST::AST_IDENTIFIER).str(value_node->str)),
//           (make_node(AST::AST_CONSTANT).value(4)),
//         }),
//       });
//
// In the real code instead of custom factories illustrated in point 1 above, you probably should use predefined methods from `UhdmAst` class.
// The syntax above puts the factory call and all its method calls (but not the function call operator with the children list) in `()`. This is done
// to make `clang-format` format the code as presented. Otherwise it is heavily wrapped and a lot less readable. `()` are technically not required
// in leafs to make them format as expected, but its nice to use them for consistency.
class AstNodeBuilder
{
    using AstNode = ::Yosys::AST::AstNode;
    using AstNodeType = ::Yosys::AST::AstNodeType;

    std::unique_ptr<AstNode> node;

  public:
    explicit AstNodeBuilder(AstNodeType node_type) : node(new AstNode(node_type)) {}
    explicit AstNodeBuilder(std::unique_ptr<AstNode> node) : node(std::move(node)) {}
    ~AstNodeBuilder() { log_assert(node == nullptr); }

    AstNodeBuilder(AstNodeBuilder &&) = default;

    AstNodeBuilder() = delete;
    AstNodeBuilder(const AstNodeBuilder &) = delete;
    AstNodeBuilder &operator=(const AstNodeBuilder &) = delete;
    AstNodeBuilder &operator=(AstNodeBuilder &&) = delete;

    // Property setters

    // Sets `AstNode::children` vector
    AstNodeBuilder &&operator()(std::vector<AstNode *> children) { return node->children = std::move(children), std::move(*this); }

    // Sets `AstNode::str` value.
    AstNodeBuilder &&str(std::string s) { return node->str = std::move(s), std::move(*this); }

    // Sets `AstNode::integer` value.
    AstNodeBuilder &&integer(uint32_t v) { return node->integer = v, std::move(*this); }

    // Sets `AstNode::is_signed` value.
    AstNodeBuilder &&is_signed(bool v) { return node->is_signed = v, std::move(*this); }

    // Sets `AstNode::is_reg` value.
    AstNodeBuilder &&is_reg(bool v) { return node->is_reg = v, std::move(*this); }

    // Sets `AstNode::range_valid`.
    AstNodeBuilder &&range_valid(bool v) { return node->range_valid = v, std::move(*this); }

    // Convenience range setters

    // Sets `AstNode::range_left`, `AstNode::range_right`, `AstNode::range_valid`.
    AstNodeBuilder &&range(bool v, int left = -1, int right = 0)
    {
        node->range_valid = v;
        node->range_left = left;
        node->range_right = right;
        return std::move(*this);
    }

    // Sets `AstNode::range_left`, `AstNode::range_right`, `AstNode::range_valid = true`.
    AstNodeBuilder &&range(int left, int right) { return range(true, left, right); }

    // Convenience value setters, mainly for constants.

    // Sets node's value.
    // Sets: `AstNode::integer`, `AstNode::is_signed`, `AstNode::bits`.
    AstNodeBuilder &&value(uint32_t v, bool is_signed, int width = 32)
    {
        log_assert(width >= 0);
        node->integer = v;
        node->is_signed = is_signed;
        // `AstNode::mkconst_int` does this too.
        for (int i = 0; i < width; i++) {
            node->bits.push_back((v & 1) ? Yosys::RTLIL::State::S1 : Yosys::RTLIL::State::S0);
            v = v >> 1;
        }
        range(width - 1, 0);
        return std::move(*this);
    }

    // Sets node's value to signed 32 bit integer.
    // Sets: `AstNode::integer`, `AstNode::is_signed`, `AstNode::bits`.
    AstNodeBuilder &&value(int32_t v) { return value(v, true); }

    // Sets node's value to unsigned 32 bit integer.
    // Sets: `AstNode::integer`, `AstNode::is_signed`, `AstNode::bits`.
    AstNodeBuilder &&value(uint32_t v) { return value(v, false); }

    // Type-cast operators used for building.

    operator AstNode *() { return node.release(); }

    operator std::unique_ptr<AstNode>() { return std::move(node); }
};

} // namespace systemverilog_plugin

#endif
