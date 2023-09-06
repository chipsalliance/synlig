module dut(a, o);
input a;
output o;

wire [2:0] a;
reg [2:0] o;

assign o = a << 1;

endmodule
