

module top
(
  data_i,
  select_i,
  data_o
);

  input [15:0] data_i;
  input [31:0] select_i;
  output [15:0] data_o;

  bsg_permute_box
  wrapper
  (
    .data_i(data_i),
    .select_i(select_i),
    .data_o(data_o)
  );


endmodule



module bsg_permute_box
(
  data_i,
  select_i,
  data_o
);

  input [15:0] data_i;
  input [31:0] select_i;
  output [15:0] data_o;
  wire [15:0] data_o;
  assign data_o[15] = data_i[15];
  assign data_o[14] = data_i[14];
  assign data_o[13] = data_i[13];
  assign data_o[12] = data_i[12];
  assign data_o[11] = data_i[11];
  assign data_o[10] = data_i[10];
  assign data_o[9] = data_i[9];
  assign data_o[8] = data_i[8];
  assign data_o[7] = data_i[7];
  assign data_o[6] = data_i[6];
  assign data_o[5] = data_i[5];
  assign data_o[4] = data_i[4];
  assign data_o[3] = data_i[3];
  assign data_o[2] = data_i[2];
  assign data_o[1] = data_i[1];
  assign data_o[0] = data_i[0];

endmodule

