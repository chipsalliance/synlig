

module top
(
  clk,
  reset_i,
  yumi_i,
  o
);

  output [31:0] o;
  input clk;
  input reset_i;
  input yumi_i;

  bsg_lfsr
  wrapper
  (
    .o(o),
    .clk(clk),
    .reset_i(reset_i),
    .yumi_i(yumi_i)
  );


endmodule



module bsg_lfsr
(
  clk,
  reset_i,
  yumi_i,
  o
);

  output [31:0] o;
  input clk;
  input reset_i;
  input yumi_i;
  wire [31:0] o,o_n;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,
  N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33;
  reg o_31_sv2v_reg,o_30_sv2v_reg,o_29_sv2v_reg,o_28_sv2v_reg,o_27_sv2v_reg,
  o_26_sv2v_reg,o_25_sv2v_reg,o_24_sv2v_reg,o_23_sv2v_reg,o_22_sv2v_reg,o_21_sv2v_reg,
  o_20_sv2v_reg,o_19_sv2v_reg,o_18_sv2v_reg,o_17_sv2v_reg,o_16_sv2v_reg,o_15_sv2v_reg,
  o_14_sv2v_reg,o_13_sv2v_reg,o_12_sv2v_reg,o_11_sv2v_reg,o_10_sv2v_reg,
  o_9_sv2v_reg,o_8_sv2v_reg,o_7_sv2v_reg,o_6_sv2v_reg,o_5_sv2v_reg,o_4_sv2v_reg,o_3_sv2v_reg,
  o_2_sv2v_reg,o_1_sv2v_reg,o_0_sv2v_reg;
  assign o[31] = o_31_sv2v_reg;
  assign o[30] = o_30_sv2v_reg;
  assign o[29] = o_29_sv2v_reg;
  assign o[28] = o_28_sv2v_reg;
  assign o[27] = o_27_sv2v_reg;
  assign o[26] = o_26_sv2v_reg;
  assign o[25] = o_25_sv2v_reg;
  assign o[24] = o_24_sv2v_reg;
  assign o[23] = o_23_sv2v_reg;
  assign o[22] = o_22_sv2v_reg;
  assign o[21] = o_21_sv2v_reg;
  assign o[20] = o_20_sv2v_reg;
  assign o[19] = o_19_sv2v_reg;
  assign o[18] = o_18_sv2v_reg;
  assign o[17] = o_17_sv2v_reg;
  assign o[16] = o_16_sv2v_reg;
  assign o[15] = o_15_sv2v_reg;
  assign o[14] = o_14_sv2v_reg;
  assign o[13] = o_13_sv2v_reg;
  assign o[12] = o_12_sv2v_reg;
  assign o[11] = o_11_sv2v_reg;
  assign o[10] = o_10_sv2v_reg;
  assign o[9] = o_9_sv2v_reg;
  assign o[8] = o_8_sv2v_reg;
  assign o[7] = o_7_sv2v_reg;
  assign o[6] = o_6_sv2v_reg;
  assign o[5] = o_5_sv2v_reg;
  assign o[4] = o_4_sv2v_reg;
  assign o[3] = o_3_sv2v_reg;
  assign o[2] = o_2_sv2v_reg;
  assign o[1] = o_1_sv2v_reg;
  assign o[0] = o_0_sv2v_reg;
  assign N2 = (N0)? 1'b1 : 
              (N1)? 1'b0 : 1'b0;
  assign N0 = yumi_i;
  assign N1 = ~yumi_i;
  assign o_n[31] = o[0] & 1'b1;
  assign o_n[30] = o[31] ^ N3;
  assign N3 = o[0] & 1'b0;
  assign o_n[29] = o[30] ^ N4;
  assign N4 = o[0] & 1'b1;
  assign o_n[28] = o[29] ^ N5;
  assign N5 = o[0] & 1'b0;
  assign o_n[27] = o[28] ^ N6;
  assign N6 = o[0] & 1'b0;
  assign o_n[26] = o[27] ^ N7;
  assign N7 = o[0] & 1'b1;
  assign o_n[25] = o[26] ^ N8;
  assign N8 = o[0] & 1'b1;
  assign o_n[24] = o[25] ^ N9;
  assign N9 = o[0] & 1'b0;
  assign o_n[23] = o[24] ^ N10;
  assign N10 = o[0] & 1'b0;
  assign o_n[22] = o[23] ^ N11;
  assign N11 = o[0] & 1'b0;
  assign o_n[21] = o[22] ^ N12;
  assign N12 = o[0] & 1'b0;
  assign o_n[20] = o[21] ^ N13;
  assign N13 = o[0] & 1'b0;
  assign o_n[19] = o[20] ^ N14;
  assign N14 = o[0] & 1'b0;
  assign o_n[18] = o[19] ^ N15;
  assign N15 = o[0] & 1'b0;
  assign o_n[17] = o[18] ^ N16;
  assign N16 = o[0] & 1'b0;
  assign o_n[16] = o[17] ^ N17;
  assign N17 = o[0] & 1'b0;
  assign o_n[15] = o[16] ^ N18;
  assign N18 = o[0] & 1'b0;
  assign o_n[14] = o[15] ^ N19;
  assign N19 = o[0] & 1'b0;
  assign o_n[13] = o[14] ^ N20;
  assign N20 = o[0] & 1'b0;
  assign o_n[12] = o[13] ^ N21;
  assign N21 = o[0] & 1'b0;
  assign o_n[11] = o[12] ^ N22;
  assign N22 = o[0] & 1'b0;
  assign o_n[10] = o[11] ^ N23;
  assign N23 = o[0] & 1'b0;
  assign o_n[9] = o[10] ^ N24;
  assign N24 = o[0] & 1'b0;
  assign o_n[8] = o[9] ^ N25;
  assign N25 = o[0] & 1'b0;
  assign o_n[7] = o[8] ^ N26;
  assign N26 = o[0] & 1'b0;
  assign o_n[6] = o[7] ^ N27;
  assign N27 = o[0] & 1'b0;
  assign o_n[5] = o[6] ^ N28;
  assign N28 = o[0] & 1'b0;
  assign o_n[4] = o[5] ^ N29;
  assign N29 = o[0] & 1'b0;
  assign o_n[3] = o[4] ^ N30;
  assign N30 = o[0] & 1'b0;
  assign o_n[2] = o[3] ^ N31;
  assign N31 = o[0] & 1'b0;
  assign o_n[1] = o[2] ^ N32;
  assign N32 = o[0] & 1'b0;
  assign o_n[0] = o[1] ^ N33;
  assign N33 = o[0] & 1'b0;

  always @(posedge clk) begin
    if(reset_i) begin
      o_31_sv2v_reg <= 1'b0;
      o_30_sv2v_reg <= 1'b0;
      o_29_sv2v_reg <= 1'b0;
      o_28_sv2v_reg <= 1'b0;
      o_27_sv2v_reg <= 1'b0;
      o_26_sv2v_reg <= 1'b0;
      o_25_sv2v_reg <= 1'b0;
      o_24_sv2v_reg <= 1'b0;
      o_23_sv2v_reg <= 1'b0;
      o_22_sv2v_reg <= 1'b0;
      o_21_sv2v_reg <= 1'b0;
      o_20_sv2v_reg <= 1'b0;
      o_19_sv2v_reg <= 1'b0;
      o_18_sv2v_reg <= 1'b0;
      o_17_sv2v_reg <= 1'b0;
      o_16_sv2v_reg <= 1'b0;
      o_15_sv2v_reg <= 1'b0;
      o_14_sv2v_reg <= 1'b0;
      o_13_sv2v_reg <= 1'b0;
      o_12_sv2v_reg <= 1'b0;
      o_11_sv2v_reg <= 1'b0;
      o_10_sv2v_reg <= 1'b0;
      o_9_sv2v_reg <= 1'b0;
      o_8_sv2v_reg <= 1'b0;
      o_7_sv2v_reg <= 1'b0;
      o_6_sv2v_reg <= 1'b0;
      o_5_sv2v_reg <= 1'b0;
      o_4_sv2v_reg <= 1'b0;
      o_3_sv2v_reg <= 1'b0;
      o_2_sv2v_reg <= 1'b0;
      o_1_sv2v_reg <= 1'b0;
      o_0_sv2v_reg <= 1'b1;
    end else if(N2) begin
      o_31_sv2v_reg <= o_n[31];
      o_30_sv2v_reg <= o_n[30];
      o_29_sv2v_reg <= o_n[29];
      o_28_sv2v_reg <= o_n[28];
      o_27_sv2v_reg <= o_n[27];
      o_26_sv2v_reg <= o_n[26];
      o_25_sv2v_reg <= o_n[25];
      o_24_sv2v_reg <= o_n[24];
      o_23_sv2v_reg <= o_n[23];
      o_22_sv2v_reg <= o_n[22];
      o_21_sv2v_reg <= o_n[21];
      o_20_sv2v_reg <= o_n[20];
      o_19_sv2v_reg <= o_n[19];
      o_18_sv2v_reg <= o_n[18];
      o_17_sv2v_reg <= o_n[17];
      o_16_sv2v_reg <= o_n[16];
      o_15_sv2v_reg <= o_n[15];
      o_14_sv2v_reg <= o_n[14];
      o_13_sv2v_reg <= o_n[13];
      o_12_sv2v_reg <= o_n[12];
      o_11_sv2v_reg <= o_n[11];
      o_10_sv2v_reg <= o_n[10];
      o_9_sv2v_reg <= o_n[9];
      o_8_sv2v_reg <= o_n[8];
      o_7_sv2v_reg <= o_n[7];
      o_6_sv2v_reg <= o_n[6];
      o_5_sv2v_reg <= o_n[5];
      o_4_sv2v_reg <= o_n[4];
      o_3_sv2v_reg <= o_n[3];
      o_2_sv2v_reg <= o_n[2];
      o_1_sv2v_reg <= o_n[1];
      o_0_sv2v_reg <= o_n[0];
    end 
  end


endmodule

