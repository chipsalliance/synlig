

module top
(
  a_i,
  b_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] o;

  bsg_xor
  wrapper
  (
    .a_i(a_i),
    .b_i(b_i),
    .o(o)
  );


endmodule



module bsg_xor
(
  a_i,
  b_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] o;
  wire [15:0] o;
  assign o[15] = a_i[15] ^ b_i[15];
  assign o[14] = a_i[14] ^ b_i[14];
  assign o[13] = a_i[13] ^ b_i[13];
  assign o[12] = a_i[12] ^ b_i[12];
  assign o[11] = a_i[11] ^ b_i[11];
  assign o[10] = a_i[10] ^ b_i[10];
  assign o[9] = a_i[9] ^ b_i[9];
  assign o[8] = a_i[8] ^ b_i[8];
  assign o[7] = a_i[7] ^ b_i[7];
  assign o[6] = a_i[6] ^ b_i[6];
  assign o[5] = a_i[5] ^ b_i[5];
  assign o[4] = a_i[4] ^ b_i[4];
  assign o[3] = a_i[3] ^ b_i[3];
  assign o[2] = a_i[2] ^ b_i[2];
  assign o[1] = a_i[1] ^ b_i[1];
  assign o[0] = a_i[0] ^ b_i[0];

endmodule

