module top(input clk, output o);
   logic a [1:0][2:0];
   assign a[1][2] = 1;
   assign o = a[1][2];
endmodule   
