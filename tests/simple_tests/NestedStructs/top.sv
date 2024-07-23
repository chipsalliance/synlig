typedef struct packed {
	struct packed {
		 logic a;
	} foo;
} bar1;

parameter int x = 1;
module top();
	typedef struct packed {
		struct packed {
			logic a;
			logic b;
		} foo;
	} bar2;

	bar1 a;
	bar2 b;

	assign a.foo.a = 1;
	assign b.foo.a = 0;
	assign b.foo.b = 1;
endmodule
