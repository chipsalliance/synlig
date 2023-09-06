

module top
(
  i,
  v_i,
  o
);

  input [3:0] i;
  output [15:0] o;
  input v_i;

  bsg_decode_with_v
  wrapper
  (
    .i(i),
    .o(o),
    .v_i(v_i)
  );


endmodule



module bsg_decode_num_out_p16
(
  i,
  o
);

  input [3:0] i;
  output [15:0] o;
  wire [15:0] o;
  assign o = { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 } << i;

endmodule



module bsg_decode_with_v
(
  i,
  v_i,
  o
);

  input [3:0] i;
  output [15:0] o;
  input v_i;
  wire [15:0] o,lo;

  bsg_decode_num_out_p16
  bd
  (
    .i(i),
    .o(lo)
  );

  assign o[15] = v_i & lo[15];
  assign o[14] = v_i & lo[14];
  assign o[13] = v_i & lo[13];
  assign o[12] = v_i & lo[12];
  assign o[11] = v_i & lo[11];
  assign o[10] = v_i & lo[10];
  assign o[9] = v_i & lo[9];
  assign o[8] = v_i & lo[8];
  assign o[7] = v_i & lo[7];
  assign o[6] = v_i & lo[6];
  assign o[5] = v_i & lo[5];
  assign o[4] = v_i & lo[4];
  assign o[3] = v_i & lo[3];
  assign o[2] = v_i & lo[2];
  assign o[1] = v_i & lo[1];
  assign o[0] = v_i & lo[0];

endmodule

