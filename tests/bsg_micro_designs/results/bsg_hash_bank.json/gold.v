

module top
(
  i,
  bank_o,
  index_o
);

  input [15:0] i;
  output [0:0] bank_o;
  output [15:0] index_o;

  bsg_hash_bank
  wrapper
  (
    .i(i),
    .bank_o(bank_o),
    .index_o(index_o)
  );


endmodule



module bsg_hash_bank
(
  i,
  bank_o,
  index_o
);

  input [15:0] i;
  output [0:0] bank_o;
  output [15:0] index_o;
  wire [0:0] bank_o;
  wire [15:0] index_o;
  assign bank_o[0] = 1'b0;
  assign index_o[15] = i[15];
  assign index_o[14] = i[14];
  assign index_o[13] = i[13];
  assign index_o[12] = i[12];
  assign index_o[11] = i[11];
  assign index_o[10] = i[10];
  assign index_o[9] = i[9];
  assign index_o[8] = i[8];
  assign index_o[7] = i[7];
  assign index_o[6] = i[6];
  assign index_o[5] = i[5];
  assign index_o[4] = i[4];
  assign index_o[3] = i[3];
  assign index_o[2] = i[2];
  assign index_o[1] = i[1];
  assign index_o[0] = i[0];

endmodule

