module top(output [3:0] b);
   reg [0:0][7:0] a;
   assign a = 8'h0F;
   assign b = a[0][6:3];
endmodule
