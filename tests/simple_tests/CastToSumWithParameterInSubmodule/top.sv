module submodule #(
   parameter int P = 1
) (
   output logic [P + 1:0] a
);
   assign a = (P + 2)'(31);
endmodule // submodule

module top(output logic [2:0] o);
   submodule #(.P(1)) u_sub (.a(o));
endmodule // top
