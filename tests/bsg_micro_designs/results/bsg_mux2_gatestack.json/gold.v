

module top
(
  i0,
  i1,
  i2,
  o
);

  input [15:0] i0;
  input [15:0] i1;
  input [15:0] i2;
  output [15:0] o;

  bsg_mux2_gatestack
  wrapper
  (
    .i0(i0),
    .i1(i1),
    .i2(i2),
    .o(o)
  );


endmodule



module bsg_mux2_gatestack
(
  i0,
  i1,
  i2,
  o
);

  input [15:0] i0;
  input [15:0] i1;
  input [15:0] i2;
  output [15:0] o;
  wire [15:0] o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,
  N22,N23,N24,N25,N26,N27,N28,N29,N30,N31;
  assign o[0] = (N0)? i1[0] : 
                (N16)? i0[0] : 1'b0;
  assign N0 = i2[0];
  assign o[1] = (N1)? i1[1] : 
                (N17)? i0[1] : 1'b0;
  assign N1 = i2[1];
  assign o[2] = (N2)? i1[2] : 
                (N18)? i0[2] : 1'b0;
  assign N2 = i2[2];
  assign o[3] = (N3)? i1[3] : 
                (N19)? i0[3] : 1'b0;
  assign N3 = i2[3];
  assign o[4] = (N4)? i1[4] : 
                (N20)? i0[4] : 1'b0;
  assign N4 = i2[4];
  assign o[5] = (N5)? i1[5] : 
                (N21)? i0[5] : 1'b0;
  assign N5 = i2[5];
  assign o[6] = (N6)? i1[6] : 
                (N22)? i0[6] : 1'b0;
  assign N6 = i2[6];
  assign o[7] = (N7)? i1[7] : 
                (N23)? i0[7] : 1'b0;
  assign N7 = i2[7];
  assign o[8] = (N8)? i1[8] : 
                (N24)? i0[8] : 1'b0;
  assign N8 = i2[8];
  assign o[9] = (N9)? i1[9] : 
                (N25)? i0[9] : 1'b0;
  assign N9 = i2[9];
  assign o[10] = (N10)? i1[10] : 
                 (N26)? i0[10] : 1'b0;
  assign N10 = i2[10];
  assign o[11] = (N11)? i1[11] : 
                 (N27)? i0[11] : 1'b0;
  assign N11 = i2[11];
  assign o[12] = (N12)? i1[12] : 
                 (N28)? i0[12] : 1'b0;
  assign N12 = i2[12];
  assign o[13] = (N13)? i1[13] : 
                 (N29)? i0[13] : 1'b0;
  assign N13 = i2[13];
  assign o[14] = (N14)? i1[14] : 
                 (N30)? i0[14] : 1'b0;
  assign N14 = i2[14];
  assign o[15] = (N15)? i1[15] : 
                 (N31)? i0[15] : 1'b0;
  assign N15 = i2[15];
  assign N16 = ~i2[0];
  assign N17 = ~i2[1];
  assign N18 = ~i2[2];
  assign N19 = ~i2[3];
  assign N20 = ~i2[4];
  assign N21 = ~i2[5];
  assign N22 = ~i2[6];
  assign N23 = ~i2[7];
  assign N24 = ~i2[8];
  assign N25 = ~i2[9];
  assign N26 = ~i2[10];
  assign N27 = ~i2[11];
  assign N28 = ~i2[12];
  assign N29 = ~i2[13];
  assign N30 = ~i2[14];
  assign N31 = ~i2[15];

endmodule

