module top();
	if (1) begin : n
		typedef struct packed {
			struct packed {
				logic a;
				logic b;
			} foo;
		} bar;
		bar x;
	end
	assign n.x.foo.a = 0;
	assign n.x.foo.b = 0;
endmodule
