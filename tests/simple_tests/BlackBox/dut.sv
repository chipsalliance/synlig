module dut(input logic clk, input logic I,
input logic EN,
output logic O1, O2);

I_BUF ibuf1(I, EN, O1);

I_BUF #(.WEAK_KEEPER("PULLUP")) ibuf2 (I, EN, O2);

endmodule
