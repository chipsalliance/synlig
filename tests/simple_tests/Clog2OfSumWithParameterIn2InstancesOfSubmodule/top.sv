module submodule #(
   parameter int P = 1
) (
   output int a
);
   assign a = $clog2(P + 2);
endmodule // submodule

module top(output int o, output int p);
   submodule #(.P(1)) u_sub1 (.a(o));
   submodule #(.P(3)) u_sub3 (.a(p));
endmodule // top
