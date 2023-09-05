module top(output int o);
   parameter int X = 20;
   typedef logic [X-1:0] my_type_t;
   parameter my_type_t Y = '1;
   assign o = int'(Y);
endmodule
