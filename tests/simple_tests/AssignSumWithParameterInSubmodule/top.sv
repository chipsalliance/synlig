module submodule(output int a);
   parameter int P = 1;
   assign a = P + 2;
endmodule

module top(output int o);
   submodule u_sub(.a(o));
endmodule
