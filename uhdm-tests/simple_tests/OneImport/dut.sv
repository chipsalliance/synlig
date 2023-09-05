module dut (a, b);
  import my_pkg::*;
  import my_pkg::opcode_e, my_pkg::OPCODE_LOAD;
  input [5:0] a;
  output [2:0] b;
  wire [5:0] a;
  reg [2:0] b;
  assign b = 3'(my_pkg::PMP_CFG_W)
             | 3'(a == OPCODE_LOAD);
endmodule
