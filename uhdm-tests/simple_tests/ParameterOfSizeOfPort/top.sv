module top(output int o);
   parameter logic [$bits(o)-1:0] X = '1;
   assign o = int'(X);
endmodule
