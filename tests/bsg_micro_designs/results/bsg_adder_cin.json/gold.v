

module top
(
  a_i,
  b_i,
  cin_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] o;
  input cin_i;

  bsg_adder_cin
  wrapper
  (
    .a_i(a_i),
    .b_i(b_i),
    .o(o),
    .cin_i(cin_i)
  );


endmodule



module bsg_adder_cin
(
  a_i,
  b_i,
  cin_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] o;
  input cin_i;
  wire [15:0] o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15;
  assign { N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1, N0 } = a_i + b_i;
  assign o = { N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1, N0 } + cin_i;

endmodule

