

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

  bsg_muxi2_gatestack
  wrapper
  (
    .i0(i0),
    .i1(i1),
    .i2(i2),
    .o(o)
  );


endmodule



module bsg_muxi2_gatestack
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
  N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,N41,
  N42,N43,N44,N45,N46,N47;
  assign N17 = (N0)? i1[0] : 
               (N16)? i0[0] : 1'b0;
  assign N0 = i2[0];
  assign N19 = (N1)? i1[1] : 
               (N18)? i0[1] : 1'b0;
  assign N1 = i2[1];
  assign N21 = (N2)? i1[2] : 
               (N20)? i0[2] : 1'b0;
  assign N2 = i2[2];
  assign N23 = (N3)? i1[3] : 
               (N22)? i0[3] : 1'b0;
  assign N3 = i2[3];
  assign N25 = (N4)? i1[4] : 
               (N24)? i0[4] : 1'b0;
  assign N4 = i2[4];
  assign N27 = (N5)? i1[5] : 
               (N26)? i0[5] : 1'b0;
  assign N5 = i2[5];
  assign N29 = (N6)? i1[6] : 
               (N28)? i0[6] : 1'b0;
  assign N6 = i2[6];
  assign N31 = (N7)? i1[7] : 
               (N30)? i0[7] : 1'b0;
  assign N7 = i2[7];
  assign N33 = (N8)? i1[8] : 
               (N32)? i0[8] : 1'b0;
  assign N8 = i2[8];
  assign N35 = (N9)? i1[9] : 
               (N34)? i0[9] : 1'b0;
  assign N9 = i2[9];
  assign N37 = (N10)? i1[10] : 
               (N36)? i0[10] : 1'b0;
  assign N10 = i2[10];
  assign N39 = (N11)? i1[11] : 
               (N38)? i0[11] : 1'b0;
  assign N11 = i2[11];
  assign N41 = (N12)? i1[12] : 
               (N40)? i0[12] : 1'b0;
  assign N12 = i2[12];
  assign N43 = (N13)? i1[13] : 
               (N42)? i0[13] : 1'b0;
  assign N13 = i2[13];
  assign N45 = (N14)? i1[14] : 
               (N44)? i0[14] : 1'b0;
  assign N14 = i2[14];
  assign N47 = (N15)? i1[15] : 
               (N46)? i0[15] : 1'b0;
  assign N15 = i2[15];
  assign N16 = ~i2[0];
  assign o[0] = ~N17;
  assign N18 = ~i2[1];
  assign o[1] = ~N19;
  assign N20 = ~i2[2];
  assign o[2] = ~N21;
  assign N22 = ~i2[3];
  assign o[3] = ~N23;
  assign N24 = ~i2[4];
  assign o[4] = ~N25;
  assign N26 = ~i2[5];
  assign o[5] = ~N27;
  assign N28 = ~i2[6];
  assign o[6] = ~N29;
  assign N30 = ~i2[7];
  assign o[7] = ~N31;
  assign N32 = ~i2[8];
  assign o[8] = ~N33;
  assign N34 = ~i2[9];
  assign o[9] = ~N35;
  assign N36 = ~i2[10];
  assign o[10] = ~N37;
  assign N38 = ~i2[11];
  assign o[11] = ~N39;
  assign N40 = ~i2[12];
  assign o[12] = ~N41;
  assign N42 = ~i2[13];
  assign o[13] = ~N43;
  assign N44 = ~i2[14];
  assign o[14] = ~N45;
  assign N46 = ~i2[15];
  assign o[15] = ~N47;

endmodule

