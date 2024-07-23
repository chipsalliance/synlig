module top();
	typedef struct {
		logic a;
		logic b;
	} pair_t;

	pair_t x;

	if (1) begin : gen1
		if (1) begin : gen2
			logic x;
		end
	end
	logic y;
	always_comb begin : gen3
		assign y = x.a;
	end
endmodule
