module submodule #(
   parameter int P = 1
) (
   output logic [P + 1:0] a
);
   assign a = (P + 2)'(31);
endmodule // submodule

module top(output logic [2:0] o, output logic [4:0] p);
   submodule #(.P(1)) u_sub1 (.a(o));
   submodule #(.P(3)) u_sub3 (.a(p));
endmodule // top
