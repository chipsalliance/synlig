

module top
(
  o
);

  output [15:0] o;

  bsg_tiehi
  wrapper
  (
    .o(o)
  );


endmodule



module bsg_tiehi
(
  o
);

  output [15:0] o;
  wire [15:0] o;
  assign o[0] = 1'b1;
  assign o[1] = 1'b1;
  assign o[2] = 1'b1;
  assign o[3] = 1'b1;
  assign o[4] = 1'b1;
  assign o[5] = 1'b1;
  assign o[6] = 1'b1;
  assign o[7] = 1'b1;
  assign o[8] = 1'b1;
  assign o[9] = 1'b1;
  assign o[10] = 1'b1;
  assign o[11] = 1'b1;
  assign o[12] = 1'b1;
  assign o[13] = 1'b1;
  assign o[14] = 1'b1;
  assign o[15] = 1'b1;

endmodule

