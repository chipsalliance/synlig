package pack;
  typedef enum logic { FOO } foo;
endpackage

module dut(input pack::foo [1:0] inp[2], output pack::foo [1:0] out[2]);
  assign out = inp;
endmodule

module top(input pack::foo [1:0] inp[2], output pack::foo [1:0] out[2]);
  dut u_dut (.inp(inp), .out(out));
endmodule

