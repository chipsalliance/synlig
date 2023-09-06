

module top
(
  a_i,
  b_i,
  c_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  input [15:0] c_i;
  output [15:0] o;

  bsg_nor3
  wrapper
  (
    .a_i(a_i),
    .b_i(b_i),
    .c_i(c_i),
    .o(o)
  );


endmodule



module bsg_nor3
(
  a_i,
  b_i,
  c_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  input [15:0] c_i;
  output [15:0] o;
  wire [15:0] o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,
  N22,N23,N24,N25,N26,N27,N28,N29,N30,N31;
  assign o[15] = ~N1;
  assign N1 = N0 | c_i[15];
  assign N0 = a_i[15] | b_i[15];
  assign o[14] = ~N3;
  assign N3 = N2 | c_i[14];
  assign N2 = a_i[14] | b_i[14];
  assign o[13] = ~N5;
  assign N5 = N4 | c_i[13];
  assign N4 = a_i[13] | b_i[13];
  assign o[12] = ~N7;
  assign N7 = N6 | c_i[12];
  assign N6 = a_i[12] | b_i[12];
  assign o[11] = ~N9;
  assign N9 = N8 | c_i[11];
  assign N8 = a_i[11] | b_i[11];
  assign o[10] = ~N11;
  assign N11 = N10 | c_i[10];
  assign N10 = a_i[10] | b_i[10];
  assign o[9] = ~N13;
  assign N13 = N12 | c_i[9];
  assign N12 = a_i[9] | b_i[9];
  assign o[8] = ~N15;
  assign N15 = N14 | c_i[8];
  assign N14 = a_i[8] | b_i[8];
  assign o[7] = ~N17;
  assign N17 = N16 | c_i[7];
  assign N16 = a_i[7] | b_i[7];
  assign o[6] = ~N19;
  assign N19 = N18 | c_i[6];
  assign N18 = a_i[6] | b_i[6];
  assign o[5] = ~N21;
  assign N21 = N20 | c_i[5];
  assign N20 = a_i[5] | b_i[5];
  assign o[4] = ~N23;
  assign N23 = N22 | c_i[4];
  assign N22 = a_i[4] | b_i[4];
  assign o[3] = ~N25;
  assign N25 = N24 | c_i[3];
  assign N24 = a_i[3] | b_i[3];
  assign o[2] = ~N27;
  assign N27 = N26 | c_i[2];
  assign N26 = a_i[2] | b_i[2];
  assign o[1] = ~N29;
  assign N29 = N28 | c_i[1];
  assign N28 = a_i[1] | b_i[1];
  assign o[0] = ~N31;
  assign N31 = N30 | c_i[0];
  assign N30 = a_i[0] | b_i[0];

endmodule

