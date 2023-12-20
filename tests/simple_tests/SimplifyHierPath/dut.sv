module module_scope_Example(o1);
   parameter [31:0] v1 = 10;
   output wire [31:0] o1;
   assign module_scope_Example.o1 = module_scope_Example.v1;
endmodule

module dut(
   input logic clk,
   output wire [31:0] a1
);
   module_scope_Example #(.v1(11)) a  (a1);
endmodule
