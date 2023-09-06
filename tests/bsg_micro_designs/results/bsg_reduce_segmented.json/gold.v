

module top
(
  i,
  o
);

  input [15:0] i;
  output [0:0] o;

  bsg_reduce_segmented
  wrapper
  (
    .i(i),
    .o(o)
  );


endmodule



module bsg_reduce_segmented
(
  i,
  o
);

  input [15:0] i;
  output [0:0] o;
  wire [0:0] o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13;
  assign o[0] = N13 ^ i[0];
  assign N13 = N12 ^ i[1];
  assign N12 = N11 ^ i[2];
  assign N11 = N10 ^ i[3];
  assign N10 = N9 ^ i[4];
  assign N9 = N8 ^ i[5];
  assign N8 = N7 ^ i[6];
  assign N7 = N6 ^ i[7];
  assign N6 = N5 ^ i[8];
  assign N5 = N4 ^ i[9];
  assign N4 = N3 ^ i[10];
  assign N3 = N2 ^ i[11];
  assign N2 = N1 ^ i[12];
  assign N1 = N0 ^ i[13];
  assign N0 = i[15] ^ i[14];

endmodule

