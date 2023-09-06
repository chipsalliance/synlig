

module top
(
  a_i,
  b_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] o;

  bsg_xnor
  wrapper
  (
    .a_i(a_i),
    .b_i(b_i),
    .o(o)
  );


endmodule



module bsg_xnor
(
  a_i,
  b_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] o;
  wire [15:0] o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15;
  assign o[15] = ~N0;
  assign N0 = a_i[15] ^ b_i[15];
  assign o[14] = ~N1;
  assign N1 = a_i[14] ^ b_i[14];
  assign o[13] = ~N2;
  assign N2 = a_i[13] ^ b_i[13];
  assign o[12] = ~N3;
  assign N3 = a_i[12] ^ b_i[12];
  assign o[11] = ~N4;
  assign N4 = a_i[11] ^ b_i[11];
  assign o[10] = ~N5;
  assign N5 = a_i[10] ^ b_i[10];
  assign o[9] = ~N6;
  assign N6 = a_i[9] ^ b_i[9];
  assign o[8] = ~N7;
  assign N7 = a_i[8] ^ b_i[8];
  assign o[7] = ~N8;
  assign N8 = a_i[7] ^ b_i[7];
  assign o[6] = ~N9;
  assign N9 = a_i[6] ^ b_i[6];
  assign o[5] = ~N10;
  assign N10 = a_i[5] ^ b_i[5];
  assign o[4] = ~N11;
  assign N11 = a_i[4] ^ b_i[4];
  assign o[3] = ~N12;
  assign N12 = a_i[3] ^ b_i[3];
  assign o[2] = ~N13;
  assign N13 = a_i[2] ^ b_i[2];
  assign o[1] = ~N14;
  assign N14 = a_i[1] ^ b_i[1];
  assign o[0] = ~N15;
  assign N15 = a_i[0] ^ b_i[0];

endmodule

