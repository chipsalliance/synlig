module dut (a, b);
	input [3:0] a;
	output [2:0] b;
	logic [3:0] a;
	logic [2:0] b;
	assign b = {~(|a[3:2]), a[3:2]};
endmodule
