

module top
(
  i,
  o
);

  output [15:0] o;
  input i;

  bsg_buf_ctrl
  wrapper
  (
    .o(o),
    .i(i)
  );


endmodule



module bsg_buf_ctrl
(
  i,
  o
);

  output [15:0] o;
  input i;
  wire [15:0] o;
  wire o_15_;
  assign o_15_ = i;
  assign o[0] = o_15_;
  assign o[1] = o_15_;
  assign o[2] = o_15_;
  assign o[3] = o_15_;
  assign o[4] = o_15_;
  assign o[5] = o_15_;
  assign o[6] = o_15_;
  assign o[7] = o_15_;
  assign o[8] = o_15_;
  assign o[9] = o_15_;
  assign o[10] = o_15_;
  assign o[11] = o_15_;
  assign o[12] = o_15_;
  assign o[13] = o_15_;
  assign o[14] = o_15_;
  assign o[15] = o_15_;

endmodule

