

module top
(
  data0_i,
  data1_i,
  sel_i,
  data_o
);

  input [15:0] data0_i;
  input [15:0] data1_i;
  input [15:0] sel_i;
  output [15:0] data_o;

  bsg_mux_bitwise
  wrapper
  (
    .data0_i(data0_i),
    .data1_i(data1_i),
    .sel_i(sel_i),
    .data_o(data_o)
  );


endmodule



module bsg_mux_segmented_segments_p16_segment_width_p1
(
  data0_i,
  data1_i,
  sel_i,
  data_o
);

  input [15:0] data0_i;
  input [15:0] data1_i;
  input [15:0] sel_i;
  output [15:0] data_o;
  wire [15:0] data_o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,
  N22,N23,N24,N25,N26,N27,N28,N29,N30,N31;
  assign data_o[0] = (N0)? data1_i[0] : 
                     (N16)? data0_i[0] : 1'b0;
  assign N0 = sel_i[0];
  assign data_o[1] = (N1)? data1_i[1] : 
                     (N17)? data0_i[1] : 1'b0;
  assign N1 = sel_i[1];
  assign data_o[2] = (N2)? data1_i[2] : 
                     (N18)? data0_i[2] : 1'b0;
  assign N2 = sel_i[2];
  assign data_o[3] = (N3)? data1_i[3] : 
                     (N19)? data0_i[3] : 1'b0;
  assign N3 = sel_i[3];
  assign data_o[4] = (N4)? data1_i[4] : 
                     (N20)? data0_i[4] : 1'b0;
  assign N4 = sel_i[4];
  assign data_o[5] = (N5)? data1_i[5] : 
                     (N21)? data0_i[5] : 1'b0;
  assign N5 = sel_i[5];
  assign data_o[6] = (N6)? data1_i[6] : 
                     (N22)? data0_i[6] : 1'b0;
  assign N6 = sel_i[6];
  assign data_o[7] = (N7)? data1_i[7] : 
                     (N23)? data0_i[7] : 1'b0;
  assign N7 = sel_i[7];
  assign data_o[8] = (N8)? data1_i[8] : 
                     (N24)? data0_i[8] : 1'b0;
  assign N8 = sel_i[8];
  assign data_o[9] = (N9)? data1_i[9] : 
                     (N25)? data0_i[9] : 1'b0;
  assign N9 = sel_i[9];
  assign data_o[10] = (N10)? data1_i[10] : 
                      (N26)? data0_i[10] : 1'b0;
  assign N10 = sel_i[10];
  assign data_o[11] = (N11)? data1_i[11] : 
                      (N27)? data0_i[11] : 1'b0;
  assign N11 = sel_i[11];
  assign data_o[12] = (N12)? data1_i[12] : 
                      (N28)? data0_i[12] : 1'b0;
  assign N12 = sel_i[12];
  assign data_o[13] = (N13)? data1_i[13] : 
                      (N29)? data0_i[13] : 1'b0;
  assign N13 = sel_i[13];
  assign data_o[14] = (N14)? data1_i[14] : 
                      (N30)? data0_i[14] : 1'b0;
  assign N14 = sel_i[14];
  assign data_o[15] = (N15)? data1_i[15] : 
                      (N31)? data0_i[15] : 1'b0;
  assign N15 = sel_i[15];
  assign N16 = ~sel_i[0];
  assign N17 = ~sel_i[1];
  assign N18 = ~sel_i[2];
  assign N19 = ~sel_i[3];
  assign N20 = ~sel_i[4];
  assign N21 = ~sel_i[5];
  assign N22 = ~sel_i[6];
  assign N23 = ~sel_i[7];
  assign N24 = ~sel_i[8];
  assign N25 = ~sel_i[9];
  assign N26 = ~sel_i[10];
  assign N27 = ~sel_i[11];
  assign N28 = ~sel_i[12];
  assign N29 = ~sel_i[13];
  assign N30 = ~sel_i[14];
  assign N31 = ~sel_i[15];

endmodule



module bsg_mux_bitwise
(
  data0_i,
  data1_i,
  sel_i,
  data_o
);

  input [15:0] data0_i;
  input [15:0] data1_i;
  input [15:0] sel_i;
  output [15:0] data_o;
  wire [15:0] data_o;

  bsg_mux_segmented_segments_p16_segment_width_p1
  mux_segmented
  (
    .data0_i(data0_i),
    .data1_i(data1_i),
    .sel_i(sel_i),
    .data_o(data_o)
  );


endmodule

