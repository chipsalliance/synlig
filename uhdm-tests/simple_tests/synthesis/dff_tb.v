`timescale 1ns/1ps

module sim;

reg clk = 1'b0;
reg d = 1'b0;
wire q;

glbl glbl();

top uut (.c(clk), .d(d), .q(q));

initial forever #5 clk = !clk;

initial #123 d <= 1'b1;
initial #245 d <= 1'b0;
initial #400 $finish;

initial begin $dumpfile("dump_dff.vcd"); $dumpvars(0); end

endmodule
