module dut #(parameter logic [255:0] PARAM) ();
endmodule

module foo #(parameter real REALPARAM = 0.5) ();
endmodule

module bar #(parameter string STRPARAM = "default") ();
endmodule

module top();

dut #(.PARAM(0)) d1();
dut #(.PARAM(1)) d2();
dut #(.PARAM(4294967295)) d3();
dut #(.PARAM(4294967296)) d4();
dut #(.PARAM(429496729600)) d5();
dut #(.PARAM('1)) d6();

PRIMITIVE #(.WIDTH(32)) d7();
PRIMITIVE #(.REAL(32.7)) d8();

foo #(.REALPARAM(1.5)) d9();
bar #(.STRPARAM("override")) d10();

endmodule
