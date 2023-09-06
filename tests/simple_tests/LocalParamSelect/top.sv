module top(output int o);
   localparam int LP [2] = '{11, 12};
   assign o = LP[0];
endmodule
