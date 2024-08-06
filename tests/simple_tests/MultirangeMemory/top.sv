module top();
	logic [3:0] arr [2];

	assign arr[1][0] = 1'b0;
	assign arr[1][2:1] = 2'b10;
	assign arr[1][3] = 1'b0;

	always_comb begin
		assert(arr[1][0] == 1'b0);
		assert(arr[1][1] == 1'b0);
		assert(arr[1][2] == 1'b1);
		assert(arr[1][3] == 1'b0);
	end
endmodule
