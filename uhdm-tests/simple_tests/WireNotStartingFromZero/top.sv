module top (i, index_o);
  input [31:0] i;
  output [1:2] index_o; // verilog_lint: waive packed-dimensions-range-ordering
  wire [1:2] index_o; // verilog_lint: waive packed-dimensions-range-ordering
  assign index_o[1] = i[1];
  assign index_o[2] = i[0];
endmodule
