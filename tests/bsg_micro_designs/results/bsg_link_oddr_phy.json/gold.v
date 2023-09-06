

module top
(
  reset_i,
  clk_i,
  data_i,
  ready_o,
  data_r_o,
  clk_r_o
);

  input [31:0] data_i;
  output [15:0] data_r_o;
  input reset_i;
  input clk_i;
  output ready_o;
  output clk_r_o;

  bsg_link_oddr_phy
  wrapper
  (
    .data_i(data_i),
    .data_r_o(data_r_o),
    .reset_i(reset_i),
    .clk_i(clk_i),
    .ready_o(ready_o),
    .clk_r_o(clk_r_o)
  );


endmodule



module bsg_link_oddr_phy
(
  reset_i,
  clk_i,
  data_i,
  ready_o,
  data_r_o,
  clk_r_o
);

  input [31:0] data_i;
  output [15:0] data_r_o;
  input reset_i;
  input clk_i;
  output ready_o;
  output clk_r_o;
  wire [15:0] data_r_o;
  wire ready_o,clk_r_o,N0,N1,odd_r,N2,reset_i_r,N3,clk_r,N4,N5,N6,N7,N8,N9,N10,N11,N12,
  N13,N14,N15,N16,N17,N18,N19,N20;
  wire [31:0] data_i_r;
  reg data_i_r_31_sv2v_reg,data_i_r_30_sv2v_reg,data_i_r_29_sv2v_reg,
  data_i_r_28_sv2v_reg,data_i_r_27_sv2v_reg,data_i_r_26_sv2v_reg,data_i_r_25_sv2v_reg,
  data_i_r_24_sv2v_reg,data_i_r_23_sv2v_reg,data_i_r_22_sv2v_reg,data_i_r_21_sv2v_reg,
  data_i_r_20_sv2v_reg,data_i_r_19_sv2v_reg,data_i_r_18_sv2v_reg,data_i_r_17_sv2v_reg,
  data_i_r_16_sv2v_reg,data_i_r_15_sv2v_reg,data_i_r_14_sv2v_reg,data_i_r_13_sv2v_reg,
  data_i_r_12_sv2v_reg,data_i_r_11_sv2v_reg,data_i_r_10_sv2v_reg,
  data_i_r_9_sv2v_reg,data_i_r_8_sv2v_reg,data_i_r_7_sv2v_reg,data_i_r_6_sv2v_reg,
  data_i_r_5_sv2v_reg,data_i_r_4_sv2v_reg,data_i_r_3_sv2v_reg,data_i_r_2_sv2v_reg,
  data_i_r_1_sv2v_reg,data_i_r_0_sv2v_reg,odd_r_sv2v_reg,reset_i_r_sv2v_reg,clk_r_sv2v_reg,
  clk_r_o_sv2v_reg,data_r_o_15_sv2v_reg,data_r_o_14_sv2v_reg,data_r_o_13_sv2v_reg,
  data_r_o_12_sv2v_reg,data_r_o_11_sv2v_reg,data_r_o_10_sv2v_reg,data_r_o_9_sv2v_reg,
  data_r_o_8_sv2v_reg,data_r_o_7_sv2v_reg,data_r_o_6_sv2v_reg,data_r_o_5_sv2v_reg,
  data_r_o_4_sv2v_reg,data_r_o_3_sv2v_reg,data_r_o_2_sv2v_reg,data_r_o_1_sv2v_reg,
  data_r_o_0_sv2v_reg;
  assign data_i_r[31] = data_i_r_31_sv2v_reg;
  assign data_i_r[30] = data_i_r_30_sv2v_reg;
  assign data_i_r[29] = data_i_r_29_sv2v_reg;
  assign data_i_r[28] = data_i_r_28_sv2v_reg;
  assign data_i_r[27] = data_i_r_27_sv2v_reg;
  assign data_i_r[26] = data_i_r_26_sv2v_reg;
  assign data_i_r[25] = data_i_r_25_sv2v_reg;
  assign data_i_r[24] = data_i_r_24_sv2v_reg;
  assign data_i_r[23] = data_i_r_23_sv2v_reg;
  assign data_i_r[22] = data_i_r_22_sv2v_reg;
  assign data_i_r[21] = data_i_r_21_sv2v_reg;
  assign data_i_r[20] = data_i_r_20_sv2v_reg;
  assign data_i_r[19] = data_i_r_19_sv2v_reg;
  assign data_i_r[18] = data_i_r_18_sv2v_reg;
  assign data_i_r[17] = data_i_r_17_sv2v_reg;
  assign data_i_r[16] = data_i_r_16_sv2v_reg;
  assign data_i_r[15] = data_i_r_15_sv2v_reg;
  assign data_i_r[14] = data_i_r_14_sv2v_reg;
  assign data_i_r[13] = data_i_r_13_sv2v_reg;
  assign data_i_r[12] = data_i_r_12_sv2v_reg;
  assign data_i_r[11] = data_i_r_11_sv2v_reg;
  assign data_i_r[10] = data_i_r_10_sv2v_reg;
  assign data_i_r[9] = data_i_r_9_sv2v_reg;
  assign data_i_r[8] = data_i_r_8_sv2v_reg;
  assign data_i_r[7] = data_i_r_7_sv2v_reg;
  assign data_i_r[6] = data_i_r_6_sv2v_reg;
  assign data_i_r[5] = data_i_r_5_sv2v_reg;
  assign data_i_r[4] = data_i_r_4_sv2v_reg;
  assign data_i_r[3] = data_i_r_3_sv2v_reg;
  assign data_i_r[2] = data_i_r_2_sv2v_reg;
  assign data_i_r[1] = data_i_r_1_sv2v_reg;
  assign data_i_r[0] = data_i_r_0_sv2v_reg;
  assign odd_r = odd_r_sv2v_reg;
  assign reset_i_r = reset_i_r_sv2v_reg;
  assign clk_r = clk_r_sv2v_reg;
  assign clk_r_o = clk_r_o_sv2v_reg;
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
  assign { N20, N19, N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5 } = (N0)? data_i_r[15:0] : 
                                                                                         (N1)? data_i_r[31:16] : 1'b0;
  assign N0 = odd_r;
  assign N1 = N2;
  assign ready_o = ~odd_r;
  assign N2 = ~odd_r;
  assign N3 = ~clk_i;
  assign N4 = ~clk_r;

  always @(posedge clk_i) begin
    if(N2) begin
      data_i_r_31_sv2v_reg <= data_i[31];
      data_i_r_30_sv2v_reg <= data_i[30];
      data_i_r_29_sv2v_reg <= data_i[29];
      data_i_r_28_sv2v_reg <= data_i[28];
      data_i_r_27_sv2v_reg <= data_i[27];
      data_i_r_26_sv2v_reg <= data_i[26];
      data_i_r_25_sv2v_reg <= data_i[25];
      data_i_r_24_sv2v_reg <= data_i[24];
      data_i_r_23_sv2v_reg <= data_i[23];
      data_i_r_22_sv2v_reg <= data_i[22];
      data_i_r_21_sv2v_reg <= data_i[21];
      data_i_r_20_sv2v_reg <= data_i[20];
      data_i_r_19_sv2v_reg <= data_i[19];
      data_i_r_18_sv2v_reg <= data_i[18];
      data_i_r_17_sv2v_reg <= data_i[17];
      data_i_r_16_sv2v_reg <= data_i[16];
      data_i_r_15_sv2v_reg <= data_i[15];
      data_i_r_14_sv2v_reg <= data_i[14];
      data_i_r_13_sv2v_reg <= data_i[13];
      data_i_r_12_sv2v_reg <= data_i[12];
      data_i_r_11_sv2v_reg <= data_i[11];
      data_i_r_10_sv2v_reg <= data_i[10];
      data_i_r_9_sv2v_reg <= data_i[9];
      data_i_r_8_sv2v_reg <= data_i[8];
      data_i_r_7_sv2v_reg <= data_i[7];
      data_i_r_6_sv2v_reg <= data_i[6];
      data_i_r_5_sv2v_reg <= data_i[5];
      data_i_r_4_sv2v_reg <= data_i[4];
      data_i_r_3_sv2v_reg <= data_i[3];
      data_i_r_2_sv2v_reg <= data_i[2];
      data_i_r_1_sv2v_reg <= data_i[1];
      data_i_r_0_sv2v_reg <= data_i[0];
    end 
    if(reset_i) begin
      odd_r_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      odd_r_sv2v_reg <= N2;
    end 
    if(1'b1) begin
      reset_i_r_sv2v_reg <= reset_i;
      data_r_o_15_sv2v_reg <= N20;
      data_r_o_14_sv2v_reg <= N19;
      data_r_o_13_sv2v_reg <= N18;
      data_r_o_12_sv2v_reg <= N17;
      data_r_o_11_sv2v_reg <= N16;
      data_r_o_10_sv2v_reg <= N15;
      data_r_o_9_sv2v_reg <= N14;
      data_r_o_8_sv2v_reg <= N13;
      data_r_o_7_sv2v_reg <= N12;
      data_r_o_6_sv2v_reg <= N11;
      data_r_o_5_sv2v_reg <= N10;
      data_r_o_4_sv2v_reg <= N9;
      data_r_o_3_sv2v_reg <= N8;
      data_r_o_2_sv2v_reg <= N7;
      data_r_o_1_sv2v_reg <= N6;
      data_r_o_0_sv2v_reg <= N5;
    end 
  end


  always @(posedge N3) begin
    if(reset_i_r) begin
      clk_r_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      clk_r_sv2v_reg <= N4;
    end 
    if(1'b1) begin
      clk_r_o_sv2v_reg <= clk_r;
    end 
  end


endmodule

