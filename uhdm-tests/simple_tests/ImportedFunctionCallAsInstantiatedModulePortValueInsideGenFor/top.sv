package some_package; // verilog_lint: waive package-filename
  function automatic logic the_function_name(logic val);
    return val == 1;
  endfunction : the_function_name
endpackage : some_package

module module_name (input logic module_input);
endmodule

module top
  import some_package::*;
();
  logic some_wire;

  for (genvar k = 0; k < 2; k++) begin : gen_for_generate_loop_name
    module_name an_instance (
      .module_input(the_function_name(some_wire))
    );
  end

endmodule : top
