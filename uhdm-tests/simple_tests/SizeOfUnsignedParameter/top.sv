module top(output int o);
   localparam unsigned P = 15;
   assign o = $bits(P);
endmodule
