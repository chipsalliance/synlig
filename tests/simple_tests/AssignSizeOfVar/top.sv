module top(output int o);
   int x = 25;
   assign o = $bits(x);
endmodule
