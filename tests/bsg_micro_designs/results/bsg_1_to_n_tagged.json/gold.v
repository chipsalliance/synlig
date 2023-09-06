

module top
(
  clk_i,
  reset_i,
  v_i,
  tag_i,
  yumi_o,
  v_o,
  ready_i
);

  input [4:0] tag_i;
  output [31:0] v_o;
  input [31:0] ready_i;
  input clk_i;
  input reset_i;
  input v_i;
  output yumi_o;

  bsg_1_to_n_tagged
  wrapper
  (
    .tag_i(tag_i),
    .v_o(v_o),
    .ready_i(ready_i),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(v_i),
    .yumi_o(yumi_o)
  );


endmodule



module bsg_decode_num_out_p32
(
  i,
  o
);

  input [4:0] i;
  output [31:0] o;
  wire [31:0] o;
  assign o = { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 } << i;

endmodule



module bsg_decode_with_v_num_out_p32
(
  i,
  v_i,
  o
);

  input [4:0] i;
  output [31:0] o;
  input v_i;
  wire [31:0] o,lo;

  bsg_decode_num_out_p32
  bd
  (
    .i(i),
    .o(lo)
  );

  assign o[31] = v_i & lo[31];
  assign o[30] = v_i & lo[30];
  assign o[29] = v_i & lo[29];
  assign o[28] = v_i & lo[28];
  assign o[27] = v_i & lo[27];
  assign o[26] = v_i & lo[26];
  assign o[25] = v_i & lo[25];
  assign o[24] = v_i & lo[24];
  assign o[23] = v_i & lo[23];
  assign o[22] = v_i & lo[22];
  assign o[21] = v_i & lo[21];
  assign o[20] = v_i & lo[20];
  assign o[19] = v_i & lo[19];
  assign o[18] = v_i & lo[18];
  assign o[17] = v_i & lo[17];
  assign o[16] = v_i & lo[16];
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



module bsg_1_to_n_tagged
(
  clk_i,
  reset_i,
  v_i,
  tag_i,
  yumi_o,
  v_o,
  ready_i
);

  input [4:0] tag_i;
  output [31:0] v_o;
  input [31:0] ready_i;
  input clk_i;
  input reset_i;
  input v_i;
  output yumi_o;
  wire [31:0] v_o;
  wire yumi_o,N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,
  N20,N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,
  N40,N41,N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53,N54,N55,N56,N57,N58,N59,
  N60,N61,N62,N63,N64,N65;

  bsg_decode_with_v_num_out_p32
  \many.bdv 
  (
    .i(tag_i),
    .v_i(v_i),
    .o(v_o)
  );

  assign N65 = (N33)? ready_i[0] : 
               (N35)? ready_i[1] : 
               (N37)? ready_i[2] : 
               (N39)? ready_i[3] : 
               (N41)? ready_i[4] : 
               (N43)? ready_i[5] : 
               (N45)? ready_i[6] : 
               (N47)? ready_i[7] : 
               (N49)? ready_i[8] : 
               (N51)? ready_i[9] : 
               (N53)? ready_i[10] : 
               (N55)? ready_i[11] : 
               (N57)? ready_i[12] : 
               (N59)? ready_i[13] : 
               (N61)? ready_i[14] : 
               (N63)? ready_i[15] : 
               (N34)? ready_i[16] : 
               (N36)? ready_i[17] : 
               (N38)? ready_i[18] : 
               (N40)? ready_i[19] : 
               (N42)? ready_i[20] : 
               (N44)? ready_i[21] : 
               (N46)? ready_i[22] : 
               (N48)? ready_i[23] : 
               (N50)? ready_i[24] : 
               (N52)? ready_i[25] : 
               (N54)? ready_i[26] : 
               (N56)? ready_i[27] : 
               (N58)? ready_i[28] : 
               (N60)? ready_i[29] : 
               (N62)? ready_i[30] : 
               (N64)? ready_i[31] : 1'b0;
  assign N0 = ~tag_i[0];
  assign N1 = ~tag_i[1];
  assign N2 = N0 & N1;
  assign N3 = N0 & tag_i[1];
  assign N4 = tag_i[0] & N1;
  assign N5 = tag_i[0] & tag_i[1];
  assign N6 = ~tag_i[2];
  assign N7 = N2 & N6;
  assign N8 = N2 & tag_i[2];
  assign N9 = N4 & N6;
  assign N10 = N4 & tag_i[2];
  assign N11 = N3 & N6;
  assign N12 = N3 & tag_i[2];
  assign N13 = N5 & N6;
  assign N14 = N5 & tag_i[2];
  assign N15 = ~tag_i[3];
  assign N16 = N7 & N15;
  assign N17 = N7 & tag_i[3];
  assign N18 = N9 & N15;
  assign N19 = N9 & tag_i[3];
  assign N20 = N11 & N15;
  assign N21 = N11 & tag_i[3];
  assign N22 = N13 & N15;
  assign N23 = N13 & tag_i[3];
  assign N24 = N8 & N15;
  assign N25 = N8 & tag_i[3];
  assign N26 = N10 & N15;
  assign N27 = N10 & tag_i[3];
  assign N28 = N12 & N15;
  assign N29 = N12 & tag_i[3];
  assign N30 = N14 & N15;
  assign N31 = N14 & tag_i[3];
  assign N32 = ~tag_i[4];
  assign N33 = N16 & N32;
  assign N34 = N16 & tag_i[4];
  assign N35 = N18 & N32;
  assign N36 = N18 & tag_i[4];
  assign N37 = N20 & N32;
  assign N38 = N20 & tag_i[4];
  assign N39 = N22 & N32;
  assign N40 = N22 & tag_i[4];
  assign N41 = N24 & N32;
  assign N42 = N24 & tag_i[4];
  assign N43 = N26 & N32;
  assign N44 = N26 & tag_i[4];
  assign N45 = N28 & N32;
  assign N46 = N28 & tag_i[4];
  assign N47 = N30 & N32;
  assign N48 = N30 & tag_i[4];
  assign N49 = N17 & N32;
  assign N50 = N17 & tag_i[4];
  assign N51 = N19 & N32;
  assign N52 = N19 & tag_i[4];
  assign N53 = N21 & N32;
  assign N54 = N21 & tag_i[4];
  assign N55 = N23 & N32;
  assign N56 = N23 & tag_i[4];
  assign N57 = N25 & N32;
  assign N58 = N25 & tag_i[4];
  assign N59 = N27 & N32;
  assign N60 = N27 & tag_i[4];
  assign N61 = N29 & N32;
  assign N62 = N29 & tag_i[4];
  assign N63 = N31 & N32;
  assign N64 = N31 & tag_i[4];
  assign yumi_o = N65 & v_i;

endmodule

