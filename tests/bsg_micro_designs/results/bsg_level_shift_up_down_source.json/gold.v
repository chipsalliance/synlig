

module top
(
  v0_en_i,
  v0_data_i,
  v1_data_o
);

  input [15:0] v0_data_i;
  output [15:0] v1_data_o;
  input v0_en_i;

  bsg_level_shift_up_down_source
  wrapper
  (
    .v0_data_i(v0_data_i),
    .v1_data_o(v1_data_o),
    .v0_en_i(v0_en_i)
  );


endmodule



module bsg_level_shift_up_down_source
(
  v0_en_i,
  v0_data_i,
  v1_data_o
);

  input [15:0] v0_data_i;
  output [15:0] v1_data_o;
  input v0_en_i;
  wire [15:0] v1_data_o;
  assign v1_data_o[15] = v0_data_i[15] & v0_en_i;
  assign v1_data_o[14] = v0_data_i[14] & v0_en_i;
  assign v1_data_o[13] = v0_data_i[13] & v0_en_i;
  assign v1_data_o[12] = v0_data_i[12] & v0_en_i;
  assign v1_data_o[11] = v0_data_i[11] & v0_en_i;
  assign v1_data_o[10] = v0_data_i[10] & v0_en_i;
  assign v1_data_o[9] = v0_data_i[9] & v0_en_i;
  assign v1_data_o[8] = v0_data_i[8] & v0_en_i;
  assign v1_data_o[7] = v0_data_i[7] & v0_en_i;
  assign v1_data_o[6] = v0_data_i[6] & v0_en_i;
  assign v1_data_o[5] = v0_data_i[5] & v0_en_i;
  assign v1_data_o[4] = v0_data_i[4] & v0_en_i;
  assign v1_data_o[3] = v0_data_i[3] & v0_en_i;
  assign v1_data_o[2] = v0_data_i[2] & v0_en_i;
  assign v1_data_o[1] = v0_data_i[1] & v0_en_i;
  assign v1_data_o[0] = v0_data_i[0] & v0_en_i;

endmodule

