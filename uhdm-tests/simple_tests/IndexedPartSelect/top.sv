module top(output [3:0] b, output [3:0] c);
   reg [7:0] a;
   assign a = 8'h0F;
   assign b = a[2+:4];
   assign c = a[5-:4]; //a[5:5-4+1]
endmodule
