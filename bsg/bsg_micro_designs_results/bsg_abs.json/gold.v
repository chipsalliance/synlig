

module top
(
  a_i,
  o
);

  input [15:0] a_i;
  output [15:0] o;

  bsg_abs
  wrapper
  (
    .a_i(a_i),
    .o(o)
  );


endmodule



module bsg_abs
(
  a_i,
  o
);

  input [15:0] a_i;
  output [15:0] o;
  wire [15:0] o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,
  N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33;
  assign { N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17 } = { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 } - a_i;
  assign { N33, N32, N31, N30, N29, N28, N27, N26, N25, N24, N23, N22, N21, N20, N19, N18 } = { N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17 } + 1'b1;
  assign o = (N0)? { N33, N32, N31, N30, N29, N28, N27, N26, N25, N24, N23, N22, N21, N20, N19, N18 } : 
             (N1)? a_i : 1'b0;
  assign N0 = a_i[15];
  assign N1 = ~a_i[15];

endmodule

