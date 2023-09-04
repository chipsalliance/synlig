module submodule(output int a);
   parameter int X = 20;
   typedef logic [X-1:0] my_type_t;
   parameter my_type_t Y = '1;
   assign a = int'(Y);
endmodule

module top(output int o, output int p, output int r);
   submodule u_sub_default(.a(o));
   submodule #(.X(5)) u_sub_5(.a(p));
   submodule #(.X(10)) u_sub_10(.a(r));
endmodule
