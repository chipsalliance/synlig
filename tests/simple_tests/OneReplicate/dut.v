module dut (a, b);
	input a;
	output [3:0] b;
	reg [3:0] b;
	assign b = {4{a}};
endmodule
