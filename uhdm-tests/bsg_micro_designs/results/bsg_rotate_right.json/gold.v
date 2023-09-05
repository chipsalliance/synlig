

module top
(
  data_i,
  rot_i,
  o
);

  input [15:0] data_i;
  input [3:0] rot_i;
  output [15:0] o;

  bsg_rotate_right
  wrapper
  (
    .data_i(data_i),
    .rot_i(rot_i),
    .o(o)
  );


endmodule



module bsg_rotate_right
(
  data_i,
  rot_i,
  o
);

  input [15:0] data_i;
  input [3:0] rot_i;
  output [15:0] o;
  wire [15:0] o;
  wire sv2v_dc_1,sv2v_dc_2,sv2v_dc_3,sv2v_dc_4,sv2v_dc_5,sv2v_dc_6,sv2v_dc_7,sv2v_dc_8,
  sv2v_dc_9,sv2v_dc_10,sv2v_dc_11,sv2v_dc_12,sv2v_dc_13,sv2v_dc_14,sv2v_dc_15;
  assign { sv2v_dc_1, sv2v_dc_2, sv2v_dc_3, sv2v_dc_4, sv2v_dc_5, sv2v_dc_6, sv2v_dc_7, sv2v_dc_8, sv2v_dc_9, sv2v_dc_10, sv2v_dc_11, sv2v_dc_12, sv2v_dc_13, sv2v_dc_14, sv2v_dc_15, o } = { data_i[14:0], data_i } >> rot_i;

endmodule

