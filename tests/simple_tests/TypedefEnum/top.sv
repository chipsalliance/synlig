package pkg;
   typedef enum logic[2:0] {
      x = 1,
      y = 2,
      z = 3
   } a;
   typedef a b;
endpackage
   
module top(input logic clk, output pkg::b o);
   assign o = pkg::x;
endmodule   
