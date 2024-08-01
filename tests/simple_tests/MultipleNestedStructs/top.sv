typedef struct packed {
	struct packed {
		logic a;
	} foo;
} foo;
parameter int x = 1;
module top();
	typedef struct packed {
		struct packed {
			logic a;
			logic b;
		} foo;
	} bar2;
	typedef struct packed {
		struct packed {
			logic [2:0] a;
			logic [3:0] b;
		} foo;
		foo bar;
	} bar3;

	foo  a;
	bar2 b;
	bar3 c;

	assign a.foo.a = 1;

	assign b.foo.a = 0;
	assign b.foo.b = 1;

	assign c.foo.a = 3;
	assign c.foo.b = 5;
	assign c.bar.a = 0;

endmodule
