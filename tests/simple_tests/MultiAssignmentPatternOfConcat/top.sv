module top(output int o);
   int n [1:6] = '{3{4, 5}};
   assign o = n[2];
endmodule 
