module submodule(output int a);
   assign a = 1 + 2;
endmodule

module top(output int o);
   submodule u_sub(.a(o));
endmodule
