parameter int enableFoo = 1;
typedef struct packed {
	logic [3:0] a;
	logic [3:0] b;
} packed_t;
module top();
	if (enableFoo) begin : foo
		typedef struct packed {
			packed_t bar;
		} packed_packed_t;
	end
endmodule
