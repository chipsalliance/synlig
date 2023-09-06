

module top
(
  index_i,
  bank_i,
  o
);

  input [15:0] index_i;
  input [0:0] bank_i;
  output [15:0] o;

  bsg_hash_bank_reverse
  wrapper
  (
    .index_i(index_i),
    .bank_i(bank_i),
    .o(o)
  );


endmodule



module bsg_hash_bank_reverse
(
  index_i,
  bank_i,
  o
);

  input [15:0] index_i;
  input [0:0] bank_i;
  output [15:0] o;
  wire [15:0] o;
  assign o[15] = index_i[15];
  assign o[14] = index_i[14];
  assign o[13] = index_i[13];
  assign o[12] = index_i[12];
  assign o[11] = index_i[11];
  assign o[10] = index_i[10];
  assign o[9] = index_i[9];
  assign o[8] = index_i[8];
  assign o[7] = index_i[7];
  assign o[6] = index_i[6];
  assign o[5] = index_i[5];
  assign o[4] = index_i[4];
  assign o[3] = index_i[3];
  assign o[2] = index_i[2];
  assign o[1] = index_i[1];
  assign o[0] = index_i[0];

endmodule

