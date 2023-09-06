

module top
(
  i,
  o
);

  input [31:0] i;
  output [12:0] o;

  bsg_concentrate_static
  wrapper
  (
    .i(i),
    .o(o)
  );


endmodule



module bsg_concentrate_static
(
  i,
  o
);

  input [31:0] i;
  output [12:0] o;
  wire [12:0] o;
  assign o[12] = i[15];
  assign o[11] = i[14];
  assign o[10] = i[13];
  assign o[9] = i[11];
  assign o[8] = i[10];
  assign o[7] = i[8];
  assign o[6] = i[7];
  assign o[5] = i[5];
  assign o[4] = i[4];
  assign o[3] = i[3];
  assign o[2] = i[2];
  assign o[1] = i[1];
  assign o[0] = i[0];

endmodule

