

module top
(
  clk_i,
  data_i,
  data_r_o
);

  input [15:0] data_i;
  output [31:0] data_r_o;
  input clk_i;

  bsg_link_iddr_phy
  wrapper
  (
    .data_i(data_i),
    .data_r_o(data_r_o),
    .clk_i(clk_i)
  );


endmodule



module bsg_link_iddr_phy
(
  clk_i,
  data_i,
  data_r_o
);

  input [15:0] data_i;
  output [31:0] data_r_o;
  input clk_i;
  wire [31:0] data_r_o;
  wire N0;
  wire [15:0] data_p_r,data_n_r;
  reg data_p_r_15_sv2v_reg,data_p_r_14_sv2v_reg,data_p_r_13_sv2v_reg,
  data_p_r_12_sv2v_reg,data_p_r_11_sv2v_reg,data_p_r_10_sv2v_reg,data_p_r_9_sv2v_reg,
  data_p_r_8_sv2v_reg,data_p_r_7_sv2v_reg,data_p_r_6_sv2v_reg,data_p_r_5_sv2v_reg,
  data_p_r_4_sv2v_reg,data_p_r_3_sv2v_reg,data_p_r_2_sv2v_reg,data_p_r_1_sv2v_reg,
  data_p_r_0_sv2v_reg,data_n_r_15_sv2v_reg,data_n_r_14_sv2v_reg,data_n_r_13_sv2v_reg,
  data_n_r_12_sv2v_reg,data_n_r_11_sv2v_reg,data_n_r_10_sv2v_reg,data_n_r_9_sv2v_reg,
  data_n_r_8_sv2v_reg,data_n_r_7_sv2v_reg,data_n_r_6_sv2v_reg,data_n_r_5_sv2v_reg,
  data_n_r_4_sv2v_reg,data_n_r_3_sv2v_reg,data_n_r_2_sv2v_reg,data_n_r_1_sv2v_reg,
  data_n_r_0_sv2v_reg,data_r_o_31_sv2v_reg,data_r_o_30_sv2v_reg,data_r_o_29_sv2v_reg,
  data_r_o_28_sv2v_reg,data_r_o_27_sv2v_reg,data_r_o_26_sv2v_reg,data_r_o_25_sv2v_reg,
  data_r_o_24_sv2v_reg,data_r_o_23_sv2v_reg,data_r_o_22_sv2v_reg,
  data_r_o_21_sv2v_reg,data_r_o_20_sv2v_reg,data_r_o_19_sv2v_reg,data_r_o_18_sv2v_reg,
  data_r_o_17_sv2v_reg,data_r_o_16_sv2v_reg,data_r_o_15_sv2v_reg,data_r_o_14_sv2v_reg,
  data_r_o_13_sv2v_reg,data_r_o_12_sv2v_reg,data_r_o_11_sv2v_reg,data_r_o_10_sv2v_reg,
  data_r_o_9_sv2v_reg,data_r_o_8_sv2v_reg,data_r_o_7_sv2v_reg,data_r_o_6_sv2v_reg,
  data_r_o_5_sv2v_reg,data_r_o_4_sv2v_reg,data_r_o_3_sv2v_reg,data_r_o_2_sv2v_reg,
  data_r_o_1_sv2v_reg,data_r_o_0_sv2v_reg;
  assign data_p_r[15] = data_p_r_15_sv2v_reg;
  assign data_p_r[14] = data_p_r_14_sv2v_reg;
  assign data_p_r[13] = data_p_r_13_sv2v_reg;
  assign data_p_r[12] = data_p_r_12_sv2v_reg;
  assign data_p_r[11] = data_p_r_11_sv2v_reg;
  assign data_p_r[10] = data_p_r_10_sv2v_reg;
  assign data_p_r[9] = data_p_r_9_sv2v_reg;
  assign data_p_r[8] = data_p_r_8_sv2v_reg;
  assign data_p_r[7] = data_p_r_7_sv2v_reg;
  assign data_p_r[6] = data_p_r_6_sv2v_reg;
  assign data_p_r[5] = data_p_r_5_sv2v_reg;
  assign data_p_r[4] = data_p_r_4_sv2v_reg;
  assign data_p_r[3] = data_p_r_3_sv2v_reg;
  assign data_p_r[2] = data_p_r_2_sv2v_reg;
  assign data_p_r[1] = data_p_r_1_sv2v_reg;
  assign data_p_r[0] = data_p_r_0_sv2v_reg;
  assign data_n_r[15] = data_n_r_15_sv2v_reg;
  assign data_n_r[14] = data_n_r_14_sv2v_reg;
  assign data_n_r[13] = data_n_r_13_sv2v_reg;
  assign data_n_r[12] = data_n_r_12_sv2v_reg;
  assign data_n_r[11] = data_n_r_11_sv2v_reg;
  assign data_n_r[10] = data_n_r_10_sv2v_reg;
  assign data_n_r[9] = data_n_r_9_sv2v_reg;
  assign data_n_r[8] = data_n_r_8_sv2v_reg;
  assign data_n_r[7] = data_n_r_7_sv2v_reg;
  assign data_n_r[6] = data_n_r_6_sv2v_reg;
  assign data_n_r[5] = data_n_r_5_sv2v_reg;
  assign data_n_r[4] = data_n_r_4_sv2v_reg;
  assign data_n_r[3] = data_n_r_3_sv2v_reg;
  assign data_n_r[2] = data_n_r_2_sv2v_reg;
  assign data_n_r[1] = data_n_r_1_sv2v_reg;
  assign data_n_r[0] = data_n_r_0_sv2v_reg;
  assign data_r_o[31] = data_r_o_31_sv2v_reg;
  assign data_r_o[30] = data_r_o_30_sv2v_reg;
  assign data_r_o[29] = data_r_o_29_sv2v_reg;
  assign data_r_o[28] = data_r_o_28_sv2v_reg;
  assign data_r_o[27] = data_r_o_27_sv2v_reg;
  assign data_r_o[26] = data_r_o_26_sv2v_reg;
  assign data_r_o[25] = data_r_o_25_sv2v_reg;
  assign data_r_o[24] = data_r_o_24_sv2v_reg;
  assign data_r_o[23] = data_r_o_23_sv2v_reg;
  assign data_r_o[22] = data_r_o_22_sv2v_reg;
  assign data_r_o[21] = data_r_o_21_sv2v_reg;
  assign data_r_o[20] = data_r_o_20_sv2v_reg;
  assign data_r_o[19] = data_r_o_19_sv2v_reg;
  assign data_r_o[18] = data_r_o_18_sv2v_reg;
  assign data_r_o[17] = data_r_o_17_sv2v_reg;
  assign data_r_o[16] = data_r_o_16_sv2v_reg;
  assign data_r_o[15] = data_r_o_15_sv2v_reg;
  assign data_r_o[14] = data_r_o_14_sv2v_reg;
  assign data_r_o[13] = data_r_o_13_sv2v_reg;
  assign data_r_o[12] = data_r_o_12_sv2v_reg;
  assign data_r_o[11] = data_r_o_11_sv2v_reg;
  assign data_r_o[10] = data_r_o_10_sv2v_reg;
  assign data_r_o[9] = data_r_o_9_sv2v_reg;
  assign data_r_o[8] = data_r_o_8_sv2v_reg;
  assign data_r_o[7] = data_r_o_7_sv2v_reg;
  assign data_r_o[6] = data_r_o_6_sv2v_reg;
  assign data_r_o[5] = data_r_o_5_sv2v_reg;
  assign data_r_o[4] = data_r_o_4_sv2v_reg;
  assign data_r_o[3] = data_r_o_3_sv2v_reg;
  assign data_r_o[2] = data_r_o_2_sv2v_reg;
  assign data_r_o[1] = data_r_o_1_sv2v_reg;
  assign data_r_o[0] = data_r_o_0_sv2v_reg;
  assign N0 = ~clk_i;

  always @(posedge clk_i) begin
    if(1'b1) begin
      data_p_r_15_sv2v_reg <= data_i[15];
      data_p_r_14_sv2v_reg <= data_i[14];
      data_p_r_13_sv2v_reg <= data_i[13];
      data_p_r_12_sv2v_reg <= data_i[12];
      data_p_r_11_sv2v_reg <= data_i[11];
      data_p_r_10_sv2v_reg <= data_i[10];
      data_p_r_9_sv2v_reg <= data_i[9];
      data_p_r_8_sv2v_reg <= data_i[8];
      data_p_r_7_sv2v_reg <= data_i[7];
      data_p_r_6_sv2v_reg <= data_i[6];
      data_p_r_5_sv2v_reg <= data_i[5];
      data_p_r_4_sv2v_reg <= data_i[4];
      data_p_r_3_sv2v_reg <= data_i[3];
      data_p_r_2_sv2v_reg <= data_i[2];
      data_p_r_1_sv2v_reg <= data_i[1];
      data_p_r_0_sv2v_reg <= data_i[0];
      data_r_o_31_sv2v_reg <= data_n_r[15];
      data_r_o_30_sv2v_reg <= data_n_r[14];
      data_r_o_29_sv2v_reg <= data_n_r[13];
      data_r_o_28_sv2v_reg <= data_n_r[12];
      data_r_o_27_sv2v_reg <= data_n_r[11];
      data_r_o_26_sv2v_reg <= data_n_r[10];
      data_r_o_25_sv2v_reg <= data_n_r[9];
      data_r_o_24_sv2v_reg <= data_n_r[8];
      data_r_o_23_sv2v_reg <= data_n_r[7];
      data_r_o_22_sv2v_reg <= data_n_r[6];
      data_r_o_21_sv2v_reg <= data_n_r[5];
      data_r_o_20_sv2v_reg <= data_n_r[4];
      data_r_o_19_sv2v_reg <= data_n_r[3];
      data_r_o_18_sv2v_reg <= data_n_r[2];
      data_r_o_17_sv2v_reg <= data_n_r[1];
      data_r_o_16_sv2v_reg <= data_n_r[0];
      data_r_o_15_sv2v_reg <= data_p_r[15];
      data_r_o_14_sv2v_reg <= data_p_r[14];
      data_r_o_13_sv2v_reg <= data_p_r[13];
      data_r_o_12_sv2v_reg <= data_p_r[12];
      data_r_o_11_sv2v_reg <= data_p_r[11];
      data_r_o_10_sv2v_reg <= data_p_r[10];
      data_r_o_9_sv2v_reg <= data_p_r[9];
      data_r_o_8_sv2v_reg <= data_p_r[8];
      data_r_o_7_sv2v_reg <= data_p_r[7];
      data_r_o_6_sv2v_reg <= data_p_r[6];
      data_r_o_5_sv2v_reg <= data_p_r[5];
      data_r_o_4_sv2v_reg <= data_p_r[4];
      data_r_o_3_sv2v_reg <= data_p_r[3];
      data_r_o_2_sv2v_reg <= data_p_r[2];
      data_r_o_1_sv2v_reg <= data_p_r[1];
      data_r_o_0_sv2v_reg <= data_p_r[0];
    end 
  end


  always @(posedge N0) begin
    if(1'b1) begin
      data_n_r_15_sv2v_reg <= data_i[15];
      data_n_r_14_sv2v_reg <= data_i[14];
      data_n_r_13_sv2v_reg <= data_i[13];
      data_n_r_12_sv2v_reg <= data_i[12];
      data_n_r_11_sv2v_reg <= data_i[11];
      data_n_r_10_sv2v_reg <= data_i[10];
      data_n_r_9_sv2v_reg <= data_i[9];
      data_n_r_8_sv2v_reg <= data_i[8];
      data_n_r_7_sv2v_reg <= data_i[7];
      data_n_r_6_sv2v_reg <= data_i[6];
      data_n_r_5_sv2v_reg <= data_i[5];
      data_n_r_4_sv2v_reg <= data_i[4];
      data_n_r_3_sv2v_reg <= data_i[3];
      data_n_r_2_sv2v_reg <= data_i[2];
      data_n_r_1_sv2v_reg <= data_i[1];
      data_n_r_0_sv2v_reg <= data_i[0];
    end 
  end


endmodule

