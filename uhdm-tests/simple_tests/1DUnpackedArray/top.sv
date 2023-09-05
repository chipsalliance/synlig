module top(output int a, b, c, d);
   int x [3:0] = '{10, 11, 12, 13};

   assign a = x[0];
   assign b = x[1];
   assign c = x[2];
   assign d = x[3];
endmodule
