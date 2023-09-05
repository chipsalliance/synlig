package tl_main_pkg;
   localparam int AddrSpace = 1;
endpackage

package dm;
   localparam int HaltAddress = 10;
   localparam logic [31:0] ExceptionAddress = HaltAddress + 2;
endpackage : dm

module top(output int o);
   import tl_main_pkg::*;

   rv_core_ibex #(
      .DmExceptionAddr(AddrSpace + dm::ExceptionAddress)
   ) u_rv_core_ibex(.a(o));
endmodule

module rv_core_ibex(output int a);
   parameter int unsigned DmExceptionAddr = 3;
   ibex_core #(
      .DmExceptionAddr(DmExceptionAddr)
  ) u_core(.b(a));
endmodule

module ibex_core(output int b);
   parameter int unsigned DmExceptionAddr = 4;
   assign b = DmExceptionAddr;
endmodule
