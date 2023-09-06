package prim_util_pkg;
   function automatic int get_5();
      int result = 5;
      return result;
   endfunction // get_5
endpackage // prim_util_pkg

module dut(output int x);
   import prim_util_pkg::*;
   assign x = get_5();
endmodule // dut

module top(output int a, b);
   import prim_util_pkg::*;
   dut u_dut(a);
   assign b = get_5();
endmodule; // top
