module top(output int o);
   logic [7:0] key [2];
   assign o = $bits(key);
endmodule
