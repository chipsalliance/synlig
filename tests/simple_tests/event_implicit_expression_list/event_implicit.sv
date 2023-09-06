/*
:name: event_implicit
:description: event implicit list
:tags: 9.4.2.2
*/
module top ();
	wire a = 0;
	wire b = 0;
	wire c = 0;
	wire d = 0;
	reg out;
	always @(*)
		out = (a | b) & (c | d);
endmodule
