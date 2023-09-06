package prim_util_pkg;
   function automatic int get_5();
      int result = 5;
      return result;
   endfunction // get_5
endpackage // prim_util_pkg

module dut;
   import prim_util_pkg::*;
endmodule // dut

module top(output int o);
   import prim_util_pkg::*;
   dut u_dut;
   assign o = get_5();
endmodule; // top
