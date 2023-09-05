module dut (a, b);
	input [2:0] a;
	output b;
	wire [2:0] a;
	localparam [2:0] OP_1 = 3'b100;
	localparam [2:0] OP_2 = 3'b101;
	localparam [2:0] OP_3 = 3'b110;
	assign b = a[2] &
		(a inside {OP_1,
					OP_2,
					OP_3});
endmodule
