package pack_pkg;
  typedef enum logic { fOO } foo;
endpackage

module dut(input pack_pkg::foo [1:0] inp[2], output pack_pkg::foo [1:0] out[2]);
  assign out = inp;
endmodule

module top(input pack_pkg::foo [1:0] inp[2], output pack_pkg::foo [1:0] out[2]);
  dut u_dut (.inp(inp), .out(out));
endmodule

