

module top
(
  clk_i,
  reset_i,
  dma_data_o,
  dma_data_v_o,
  dma_data_ready_i,
  app_rd_data_valid_i,
  app_rd_data_end_i,
  app_rd_data_i
);

  output [15:0] dma_data_o;
  input [15:0] app_rd_data_i;
  input clk_i;
  input reset_i;
  input dma_data_ready_i;
  input app_rd_data_valid_i;
  input app_rd_data_end_i;
  output dma_data_v_o;

  bsg_cache_to_dram_ctrl_rx
  wrapper
  (
    .dma_data_o(dma_data_o),
    .app_rd_data_i(app_rd_data_i),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .dma_data_ready_i(dma_data_ready_i),
    .app_rd_data_valid_i(app_rd_data_valid_i),
    .app_rd_data_end_i(app_rd_data_end_i),
    .dma_data_v_o(dma_data_v_o)
  );


endmodule



module bsg_serial_in_parallel_out_width_p16_els_p3_out_els_p2
(
  clk_i,
  reset_i,
  valid_i,
  data_i,
  ready_o,
  valid_o,
  data_o,
  yumi_cnt_i
);

  input [15:0] data_i;
  output [1:0] valid_o;
  output [31:0] data_o;
  input [1:0] yumi_cnt_i;
  input clk_i;
  input reset_i;
  input valid_i;
  output ready_o;
  wire [1:0] valid_o,num_els_r,num_els_n;
  wire [31:0] data_o;
  wire ready_o,N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,
  N20,N21,N22,N23,N24,N25,N26,N27,N28,data_n_3__15_,data_n_3__14_,data_n_3__13_,
  data_n_3__12_,data_n_3__11_,data_n_3__10_,data_n_3__9_,data_n_3__8_,data_n_3__7_,
  data_n_3__6_,data_n_3__5_,data_n_3__4_,data_n_3__3_,data_n_3__2_,data_n_3__1_,
  data_n_3__0_,data_n_2__15_,data_n_2__14_,data_n_2__13_,data_n_2__12_,data_n_2__11_,
  data_n_2__10_,data_n_2__9_,data_n_2__8_,data_n_2__7_,data_n_2__6_,data_n_2__5_,
  data_n_2__4_,data_n_2__3_,data_n_2__2_,data_n_2__1_,data_n_2__0_,N29,N30,N31,N32,
  N33,N34,N35,N36,N37,N38,N39,N40,N41,N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,
  N53,N54,N55,N56,N57,N58,N59,N60;
  wire [2:0] valid_r,valid_nn;
  wire [47:0] data_r,data_nn;
  wire [3:2] valid_n;
  reg valid_r_2_sv2v_reg,valid_r_1_sv2v_reg,valid_r_0_sv2v_reg,num_els_r_1_sv2v_reg,
  num_els_r_0_sv2v_reg,data_r_47_sv2v_reg,data_r_46_sv2v_reg,data_r_45_sv2v_reg,
  data_r_44_sv2v_reg,data_r_43_sv2v_reg,data_r_42_sv2v_reg,data_r_41_sv2v_reg,
  data_r_40_sv2v_reg,data_r_39_sv2v_reg,data_r_38_sv2v_reg,data_r_37_sv2v_reg,
  data_r_36_sv2v_reg,data_r_35_sv2v_reg,data_r_34_sv2v_reg,data_r_33_sv2v_reg,
  data_r_32_sv2v_reg,data_r_31_sv2v_reg,data_r_30_sv2v_reg,data_r_29_sv2v_reg,data_r_28_sv2v_reg,
  data_r_27_sv2v_reg,data_r_26_sv2v_reg,data_r_25_sv2v_reg,data_r_24_sv2v_reg,
  data_r_23_sv2v_reg,data_r_22_sv2v_reg,data_r_21_sv2v_reg,data_r_20_sv2v_reg,
  data_r_19_sv2v_reg,data_r_18_sv2v_reg,data_r_17_sv2v_reg,data_r_16_sv2v_reg,
  data_r_15_sv2v_reg,data_r_14_sv2v_reg,data_r_13_sv2v_reg,data_r_12_sv2v_reg,
  data_r_11_sv2v_reg,data_r_10_sv2v_reg,data_r_9_sv2v_reg,data_r_8_sv2v_reg,data_r_7_sv2v_reg,
  data_r_6_sv2v_reg,data_r_5_sv2v_reg,data_r_4_sv2v_reg,data_r_3_sv2v_reg,
  data_r_2_sv2v_reg,data_r_1_sv2v_reg,data_r_0_sv2v_reg;
  assign valid_r[2] = valid_r_2_sv2v_reg;
  assign valid_r[1] = valid_r_1_sv2v_reg;
  assign valid_r[0] = valid_r_0_sv2v_reg;
  assign num_els_r[1] = num_els_r_1_sv2v_reg;
  assign num_els_r[0] = num_els_r_0_sv2v_reg;
  assign data_r[47] = data_r_47_sv2v_reg;
  assign data_r[46] = data_r_46_sv2v_reg;
  assign data_r[45] = data_r_45_sv2v_reg;
  assign data_r[44] = data_r_44_sv2v_reg;
  assign data_r[43] = data_r_43_sv2v_reg;
  assign data_r[42] = data_r_42_sv2v_reg;
  assign data_r[41] = data_r_41_sv2v_reg;
  assign data_r[40] = data_r_40_sv2v_reg;
  assign data_r[39] = data_r_39_sv2v_reg;
  assign data_r[38] = data_r_38_sv2v_reg;
  assign data_r[37] = data_r_37_sv2v_reg;
  assign data_r[36] = data_r_36_sv2v_reg;
  assign data_r[35] = data_r_35_sv2v_reg;
  assign data_r[34] = data_r_34_sv2v_reg;
  assign data_r[33] = data_r_33_sv2v_reg;
  assign data_r[32] = data_r_32_sv2v_reg;
  assign data_r[31] = data_r_31_sv2v_reg;
  assign data_r[30] = data_r_30_sv2v_reg;
  assign data_r[29] = data_r_29_sv2v_reg;
  assign data_r[28] = data_r_28_sv2v_reg;
  assign data_r[27] = data_r_27_sv2v_reg;
  assign data_r[26] = data_r_26_sv2v_reg;
  assign data_r[25] = data_r_25_sv2v_reg;
  assign data_r[24] = data_r_24_sv2v_reg;
  assign data_r[23] = data_r_23_sv2v_reg;
  assign data_r[22] = data_r_22_sv2v_reg;
  assign data_r[21] = data_r_21_sv2v_reg;
  assign data_r[20] = data_r_20_sv2v_reg;
  assign data_r[19] = data_r_19_sv2v_reg;
  assign data_r[18] = data_r_18_sv2v_reg;
  assign data_r[17] = data_r_17_sv2v_reg;
  assign data_r[16] = data_r_16_sv2v_reg;
  assign data_r[15] = data_r_15_sv2v_reg;
  assign data_r[14] = data_r_14_sv2v_reg;
  assign data_r[13] = data_r_13_sv2v_reg;
  assign data_r[12] = data_r_12_sv2v_reg;
  assign data_r[11] = data_r_11_sv2v_reg;
  assign data_r[10] = data_r_10_sv2v_reg;
  assign data_r[9] = data_r_9_sv2v_reg;
  assign data_r[8] = data_r_8_sv2v_reg;
  assign data_r[7] = data_r_7_sv2v_reg;
  assign data_r[6] = data_r_6_sv2v_reg;
  assign data_r[5] = data_r_5_sv2v_reg;
  assign data_r[4] = data_r_4_sv2v_reg;
  assign data_r[3] = data_r_3_sv2v_reg;
  assign data_r[2] = data_r_2_sv2v_reg;
  assign data_r[1] = data_r_1_sv2v_reg;
  assign data_r[0] = data_r_0_sv2v_reg;
  assign N60 = N52 | N55;
  assign { N28, N27 } = num_els_r + N26;
  assign num_els_n = { N28, N27 } - yumi_cnt_i;
  assign N32 = num_els_r[0] & num_els_r[1];
  assign N31 = N0 & num_els_r[1];
  assign N0 = ~num_els_r[0];
  assign N30 = num_els_r[0] & N1;
  assign N1 = ~num_els_r[1];
  assign N29 = N2 & N3;
  assign N2 = ~num_els_r[0];
  assign N3 = ~num_els_r[1];
  assign N40 = num_els_r[0] & num_els_r[1];
  assign N39 = N4 & num_els_r[1];
  assign N4 = ~num_els_r[0];
  assign N38 = num_els_r[0] & N5;
  assign N5 = ~num_els_r[1];
  assign N37 = N6 & N7;
  assign N6 = ~num_els_r[0];
  assign N7 = ~num_els_r[1];
  assign N52 = yumi_cnt_i[0] & yumi_cnt_i[1];
  assign N55 = N8 & yumi_cnt_i[1];
  assign N8 = ~yumi_cnt_i[0];
  assign N54 = yumi_cnt_i[0] & N9;
  assign N9 = ~yumi_cnt_i[1];
  assign N53 = N10 & N11;
  assign N10 = ~yumi_cnt_i[0];
  assign N11 = ~yumi_cnt_i[1];
  assign { data_o[0:0], data_o[1:1], data_o[2:2], data_o[3:3], data_o[4:4], data_o[5:5], data_o[6:6], data_o[7:7], data_o[8:8], data_o[9:9], data_o[10:10], data_o[11:11], data_o[12:12], data_o[13:13], data_o[14:14], data_o[15:15] } = (N12)? { data_i[0:0], data_i[1:1], data_i[2:2], data_i[3:3], data_i[4:4], data_i[5:5], data_i[6:6], data_i[7:7], data_i[8:8], data_i[9:9], data_i[10:10], data_i[11:11], data_i[12:12], data_i[13:13], data_i[14:14], data_i[15:15] } : 
                                                                                                                                                                                                                                          (N33)? { data_r[0:0], data_r[1:1], data_r[2:2], data_r[3:3], data_r[4:4], data_r[5:5], data_r[6:6], data_r[7:7], data_r[8:8], data_r[9:9], data_r[10:10], data_r[11:11], data_r[12:12], data_r[13:13], data_r[14:14], data_r[15:15] } : 1'b0;
  assign N12 = N29;
  assign { data_o[16:16], data_o[17:17], data_o[18:18], data_o[19:19], data_o[20:20], data_o[21:21], data_o[22:22], data_o[23:23], data_o[24:24], data_o[25:25], data_o[26:26], data_o[27:27], data_o[28:28], data_o[29:29], data_o[30:30], data_o[31:31] } = (N13)? { data_i[0:0], data_i[1:1], data_i[2:2], data_i[3:3], data_i[4:4], data_i[5:5], data_i[6:6], data_i[7:7], data_i[8:8], data_i[9:9], data_i[10:10], data_i[11:11], data_i[12:12], data_i[13:13], data_i[14:14], data_i[15:15] } : 
                                                                                                                                                                                                                                                              (N34)? { data_r[16:16], data_r[17:17], data_r[18:18], data_r[19:19], data_r[20:20], data_r[21:21], data_r[22:22], data_r[23:23], data_r[24:24], data_r[25:25], data_r[26:26], data_r[27:27], data_r[28:28], data_r[29:29], data_r[30:30], data_r[31:31] } : 1'b0;
  assign N13 = N30;
  assign { data_n_2__0_, data_n_2__1_, data_n_2__2_, data_n_2__3_, data_n_2__4_, data_n_2__5_, data_n_2__6_, data_n_2__7_, data_n_2__8_, data_n_2__9_, data_n_2__10_, data_n_2__11_, data_n_2__12_, data_n_2__13_, data_n_2__14_, data_n_2__15_ } = (N14)? { data_i[0:0], data_i[1:1], data_i[2:2], data_i[3:3], data_i[4:4], data_i[5:5], data_i[6:6], data_i[7:7], data_i[8:8], data_i[9:9], data_i[10:10], data_i[11:11], data_i[12:12], data_i[13:13], data_i[14:14], data_i[15:15] } : 
                                                                                                                                                                                                                                                    (N35)? { data_r[32:32], data_r[33:33], data_r[34:34], data_r[35:35], data_r[36:36], data_r[37:37], data_r[38:38], data_r[39:39], data_r[40:40], data_r[41:41], data_r[42:42], data_r[43:43], data_r[44:44], data_r[45:45], data_r[46:46], data_r[47:47] } : 1'b0;
  assign N14 = N31;
  assign { data_n_3__0_, data_n_3__1_, data_n_3__2_, data_n_3__3_, data_n_3__4_, data_n_3__5_, data_n_3__6_, data_n_3__7_, data_n_3__8_, data_n_3__9_, data_n_3__10_, data_n_3__11_, data_n_3__12_, data_n_3__13_, data_n_3__14_, data_n_3__15_ } = (N15)? { data_i[0:0], data_i[1:1], data_i[2:2], data_i[3:3], data_i[4:4], data_i[5:5], data_i[6:6], data_i[7:7], data_i[8:8], data_i[9:9], data_i[10:10], data_i[11:11], data_i[12:12], data_i[13:13], data_i[14:14], data_i[15:15] } : 
                                                                                                                                                                                                                                                    (N36)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 1'b0;
  assign N15 = N32;
  assign valid_o[0] = (N16)? N41 : 
                      (N42)? valid_r[0] : 1'b0;
  assign N16 = N37;
  assign valid_o[1] = (N17)? N41 : 
                      (N43)? valid_r[1] : 1'b0;
  assign N17 = N38;
  assign valid_n[2] = (N18)? N41 : 
                      (N44)? valid_r[2] : 1'b0;
  assign N18 = N39;
  assign valid_n[3] = (N19)? N41 : 
                      (N45)? 1'b0 : 1'b0;
  assign N19 = N40;
  assign data_nn[31:16] = (N20)? { data_n_3__15_, data_n_3__14_, data_n_3__13_, data_n_3__12_, data_n_3__11_, data_n_3__10_, data_n_3__9_, data_n_3__8_, data_n_3__7_, data_n_3__6_, data_n_3__5_, data_n_3__4_, data_n_3__3_, data_n_3__2_, data_n_3__1_, data_n_3__0_ } : 
                          (N21)? { data_n_2__15_, data_n_2__14_, data_n_2__13_, data_n_2__12_, data_n_2__11_, data_n_2__10_, data_n_2__9_, data_n_2__8_, data_n_2__7_, data_n_2__6_, data_n_2__5_, data_n_2__4_, data_n_2__3_, data_n_2__2_, data_n_2__1_, data_n_2__0_ } : 
                          (N22)? data_o[31:16] : 1'b0;
  assign N20 = N55;
  assign N21 = N54;
  assign N22 = N53;
  assign data_nn[47:32] = (N21)? { data_n_3__15_, data_n_3__14_, data_n_3__13_, data_n_3__12_, data_n_3__11_, data_n_3__10_, data_n_3__9_, data_n_3__8_, data_n_3__7_, data_n_3__6_, data_n_3__5_, data_n_3__4_, data_n_3__3_, data_n_3__2_, data_n_3__1_, data_n_3__0_ } : 
                          (N22)? { data_n_2__15_, data_n_2__14_, data_n_2__13_, data_n_2__12_, data_n_2__11_, data_n_2__10_, data_n_2__9_, data_n_2__8_, data_n_2__7_, data_n_2__6_, data_n_2__5_, data_n_2__4_, data_n_2__3_, data_n_2__2_, data_n_2__1_, data_n_2__0_ } : 1'b0;
  assign { N59, N58, N57, N56 } = (N23)? { 1'b0, 1'b0, valid_n } : 
                                  (N47)? { valid_n, valid_o } : 1'b0;
  assign N23 = yumi_cnt_i[1];
  assign valid_nn = (N24)? { N59, N58, N57 } : 
                    (N46)? { N58, N57, N56 } : 1'b0;
  assign N24 = yumi_cnt_i[0];
  assign data_nn[15] = (N48)? data_o[15] : 
                       (N50)? data_o[31] : 
                       (N49)? data_n_2__15_ : 
                       (N51)? data_n_3__15_ : 
                       (N25)? 1'b0 : 
                       (N25)? 1'b0 : 1'b0;
  assign N25 = 1'b0;
  assign data_nn[14] = (N48)? data_o[14] : 
                       (N50)? data_o[30] : 
                       (N49)? data_n_2__14_ : 
                       (N51)? data_n_3__14_ : 
                       (N25)? 1'b0 : 
                       (N25)? 1'b0 : 1'b0;
  assign data_nn[13] = (N48)? data_o[13] : 
                       (N50)? data_o[29] : 
                       (N49)? data_n_2__13_ : 
                       (N51)? data_n_3__13_ : 
                       (N25)? 1'b0 : 
                       (N25)? 1'b0 : 1'b0;
  assign data_nn[12] = (N48)? data_o[12] : 
                       (N50)? data_o[28] : 
                       (N49)? data_n_2__12_ : 
                       (N51)? data_n_3__12_ : 
                       (N25)? 1'b0 : 
                       (N25)? 1'b0 : 1'b0;
  assign data_nn[11] = (N48)? data_o[11] : 
                       (N50)? data_o[27] : 
                       (N49)? data_n_2__11_ : 
                       (N51)? data_n_3__11_ : 
                       (N25)? 1'b0 : 
                       (N25)? 1'b0 : 1'b0;
  assign data_nn[10] = (N48)? data_o[10] : 
                       (N50)? data_o[26] : 
                       (N49)? data_n_2__10_ : 
                       (N51)? data_n_3__10_ : 
                       (N25)? 1'b0 : 
                       (N25)? 1'b0 : 1'b0;
  assign data_nn[9] = (N48)? data_o[9] : 
                      (N50)? data_o[25] : 
                      (N49)? data_n_2__9_ : 
                      (N51)? data_n_3__9_ : 
                      (N25)? 1'b0 : 
                      (N25)? 1'b0 : 1'b0;
  assign data_nn[8] = (N48)? data_o[8] : 
                      (N50)? data_o[24] : 
                      (N49)? data_n_2__8_ : 
                      (N51)? data_n_3__8_ : 
                      (N25)? 1'b0 : 
                      (N25)? 1'b0 : 1'b0;
  assign data_nn[7] = (N48)? data_o[7] : 
                      (N50)? data_o[23] : 
                      (N49)? data_n_2__7_ : 
                      (N51)? data_n_3__7_ : 
                      (N25)? 1'b0 : 
                      (N25)? 1'b0 : 1'b0;
  assign data_nn[6] = (N48)? data_o[6] : 
                      (N50)? data_o[22] : 
                      (N49)? data_n_2__6_ : 
                      (N51)? data_n_3__6_ : 
                      (N25)? 1'b0 : 
                      (N25)? 1'b0 : 1'b0;
  assign data_nn[5] = (N48)? data_o[5] : 
                      (N50)? data_o[21] : 
                      (N49)? data_n_2__5_ : 
                      (N51)? data_n_3__5_ : 
                      (N25)? 1'b0 : 
                      (N25)? 1'b0 : 1'b0;
  assign data_nn[4] = (N48)? data_o[4] : 
                      (N50)? data_o[20] : 
                      (N49)? data_n_2__4_ : 
                      (N51)? data_n_3__4_ : 
                      (N25)? 1'b0 : 
                      (N25)? 1'b0 : 1'b0;
  assign data_nn[3] = (N48)? data_o[3] : 
                      (N50)? data_o[19] : 
                      (N49)? data_n_2__3_ : 
                      (N51)? data_n_3__3_ : 
                      (N25)? 1'b0 : 
                      (N25)? 1'b0 : 1'b0;
  assign data_nn[2] = (N48)? data_o[2] : 
                      (N50)? data_o[18] : 
                      (N49)? data_n_2__2_ : 
                      (N51)? data_n_3__2_ : 
                      (N25)? 1'b0 : 
                      (N25)? 1'b0 : 1'b0;
  assign data_nn[1] = (N48)? data_o[1] : 
                      (N50)? data_o[17] : 
                      (N49)? data_n_2__1_ : 
                      (N51)? data_n_3__1_ : 
                      (N25)? 1'b0 : 
                      (N25)? 1'b0 : 1'b0;
  assign data_nn[0] = (N48)? data_o[0] : 
                      (N50)? data_o[16] : 
                      (N49)? data_n_2__0_ : 
                      (N51)? data_n_3__0_ : 
                      (N25)? 1'b0 : 
                      (N25)? 1'b0 : 1'b0;
  assign ready_o = ~valid_r[2];
  assign N26 = valid_i & ready_o;
  assign N33 = ~N29;
  assign N34 = ~N30;
  assign N35 = ~N31;
  assign N36 = ~N32;
  assign N41 = valid_i & ready_o;
  assign N42 = ~N37;
  assign N43 = ~N38;
  assign N44 = ~N39;
  assign N45 = ~N40;
  assign N46 = ~yumi_cnt_i[0];
  assign N47 = ~yumi_cnt_i[1];
  assign N48 = N46 & N47;
  assign N49 = N46 & yumi_cnt_i[1];
  assign N50 = yumi_cnt_i[0] & N47;
  assign N51 = yumi_cnt_i[0] & yumi_cnt_i[1];

  always @(posedge clk_i) begin
    if(reset_i) begin
      valid_r_2_sv2v_reg <= 1'b0;
      valid_r_1_sv2v_reg <= 1'b0;
      valid_r_0_sv2v_reg <= 1'b0;
      num_els_r_1_sv2v_reg <= 1'b0;
      num_els_r_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      valid_r_2_sv2v_reg <= valid_nn[2];
      valid_r_1_sv2v_reg <= valid_nn[1];
      valid_r_0_sv2v_reg <= valid_nn[0];
      num_els_r_1_sv2v_reg <= num_els_n[1];
      num_els_r_0_sv2v_reg <= num_els_n[0];
    end 
    if(N60) begin
      data_r_47_sv2v_reg <= 1'b0;
      data_r_46_sv2v_reg <= 1'b0;
      data_r_45_sv2v_reg <= 1'b0;
      data_r_44_sv2v_reg <= 1'b0;
      data_r_43_sv2v_reg <= 1'b0;
      data_r_42_sv2v_reg <= 1'b0;
      data_r_41_sv2v_reg <= 1'b0;
      data_r_40_sv2v_reg <= 1'b0;
      data_r_39_sv2v_reg <= 1'b0;
      data_r_38_sv2v_reg <= 1'b0;
      data_r_37_sv2v_reg <= 1'b0;
      data_r_36_sv2v_reg <= 1'b0;
      data_r_35_sv2v_reg <= 1'b0;
      data_r_34_sv2v_reg <= 1'b0;
      data_r_33_sv2v_reg <= 1'b0;
      data_r_32_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      data_r_47_sv2v_reg <= data_nn[47];
      data_r_46_sv2v_reg <= data_nn[46];
      data_r_45_sv2v_reg <= data_nn[45];
      data_r_44_sv2v_reg <= data_nn[44];
      data_r_43_sv2v_reg <= data_nn[43];
      data_r_42_sv2v_reg <= data_nn[42];
      data_r_41_sv2v_reg <= data_nn[41];
      data_r_40_sv2v_reg <= data_nn[40];
      data_r_39_sv2v_reg <= data_nn[39];
      data_r_38_sv2v_reg <= data_nn[38];
      data_r_37_sv2v_reg <= data_nn[37];
      data_r_36_sv2v_reg <= data_nn[36];
      data_r_35_sv2v_reg <= data_nn[35];
      data_r_34_sv2v_reg <= data_nn[34];
      data_r_33_sv2v_reg <= data_nn[33];
      data_r_32_sv2v_reg <= data_nn[32];
    end 
    if(N52) begin
      data_r_31_sv2v_reg <= 1'b0;
      data_r_30_sv2v_reg <= 1'b0;
      data_r_29_sv2v_reg <= 1'b0;
      data_r_28_sv2v_reg <= 1'b0;
      data_r_27_sv2v_reg <= 1'b0;
      data_r_26_sv2v_reg <= 1'b0;
      data_r_25_sv2v_reg <= 1'b0;
      data_r_24_sv2v_reg <= 1'b0;
      data_r_23_sv2v_reg <= 1'b0;
      data_r_22_sv2v_reg <= 1'b0;
      data_r_21_sv2v_reg <= 1'b0;
      data_r_20_sv2v_reg <= 1'b0;
      data_r_19_sv2v_reg <= 1'b0;
      data_r_18_sv2v_reg <= 1'b0;
      data_r_17_sv2v_reg <= 1'b0;
      data_r_16_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      data_r_31_sv2v_reg <= data_nn[31];
      data_r_30_sv2v_reg <= data_nn[30];
      data_r_29_sv2v_reg <= data_nn[29];
      data_r_28_sv2v_reg <= data_nn[28];
      data_r_27_sv2v_reg <= data_nn[27];
      data_r_26_sv2v_reg <= data_nn[26];
      data_r_25_sv2v_reg <= data_nn[25];
      data_r_24_sv2v_reg <= data_nn[24];
      data_r_23_sv2v_reg <= data_nn[23];
      data_r_22_sv2v_reg <= data_nn[22];
      data_r_21_sv2v_reg <= data_nn[21];
      data_r_20_sv2v_reg <= data_nn[20];
      data_r_19_sv2v_reg <= data_nn[19];
      data_r_18_sv2v_reg <= data_nn[18];
      data_r_17_sv2v_reg <= data_nn[17];
      data_r_16_sv2v_reg <= data_nn[16];
    end 
    if(1'b1) begin
      data_r_15_sv2v_reg <= data_nn[15];
      data_r_14_sv2v_reg <= data_nn[14];
      data_r_13_sv2v_reg <= data_nn[13];
      data_r_12_sv2v_reg <= data_nn[12];
      data_r_11_sv2v_reg <= data_nn[11];
      data_r_10_sv2v_reg <= data_nn[10];
      data_r_9_sv2v_reg <= data_nn[9];
      data_r_8_sv2v_reg <= data_nn[8];
      data_r_7_sv2v_reg <= data_nn[7];
      data_r_6_sv2v_reg <= data_nn[6];
      data_r_5_sv2v_reg <= data_nn[5];
      data_r_4_sv2v_reg <= data_nn[4];
      data_r_3_sv2v_reg <= data_nn[3];
      data_r_2_sv2v_reg <= data_nn[2];
      data_r_1_sv2v_reg <= data_nn[1];
      data_r_0_sv2v_reg <= data_nn[0];
    end 
  end


endmodule



module bsg_circular_ptr_slots_p2_max_add_p1
(
  clk,
  reset_i,
  add_i,
  o,
  n_o
);

  input [0:0] add_i;
  output [0:0] o;
  output [0:0] n_o;
  input clk;
  input reset_i;
  wire [0:0] o,n_o,\genblk1.genblk1.ptr_r_p1 ;
  wire N0,N1,N2;
  reg o_0_sv2v_reg;
  assign o[0] = o_0_sv2v_reg;
  assign \genblk1.genblk1.ptr_r_p1 [0] = o[0] ^ 1'b1;
  assign n_o[0] = (N0)? \genblk1.genblk1.ptr_r_p1 [0] : 
                  (N1)? o[0] : 1'b0;
  assign N0 = add_i[0];
  assign N1 = N2;
  assign N2 = ~add_i[0];

  always @(posedge clk) begin
    if(reset_i) begin
      o_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      o_0_sv2v_reg <= n_o[0];
    end 
  end


endmodule



module bsg_mem_1rw_sync_synth_width_p32_els_p2_latch_last_read_p0_verbose_p1
(
  clk_i,
  v_i,
  reset_i,
  data_i,
  addr_i,
  w_i,
  data_o
);

  input [31:0] data_i;
  input [0:0] addr_i;
  output [31:0] data_o;
  input clk_i;
  input v_i;
  input reset_i;
  input w_i;
  wire [31:0] data_o;
  wire N0,N1,N2,N3,N4,N5,N7,N8;
  wire [0:0] \nz.addr_r ;
  wire [63:0] \nz.mem ;
  reg \nz.addr_r_0_sv2v_reg ,\nz.mem_63_sv2v_reg ,\nz.mem_62_sv2v_reg ,
  \nz.mem_61_sv2v_reg ,\nz.mem_60_sv2v_reg ,\nz.mem_59_sv2v_reg ,\nz.mem_58_sv2v_reg ,
  \nz.mem_57_sv2v_reg ,\nz.mem_56_sv2v_reg ,\nz.mem_55_sv2v_reg ,\nz.mem_54_sv2v_reg ,
  \nz.mem_53_sv2v_reg ,\nz.mem_52_sv2v_reg ,\nz.mem_51_sv2v_reg ,\nz.mem_50_sv2v_reg ,
  \nz.mem_49_sv2v_reg ,\nz.mem_48_sv2v_reg ,\nz.mem_47_sv2v_reg ,
  \nz.mem_46_sv2v_reg ,\nz.mem_45_sv2v_reg ,\nz.mem_44_sv2v_reg ,\nz.mem_43_sv2v_reg ,
  \nz.mem_42_sv2v_reg ,\nz.mem_41_sv2v_reg ,\nz.mem_40_sv2v_reg ,\nz.mem_39_sv2v_reg ,
  \nz.mem_38_sv2v_reg ,\nz.mem_37_sv2v_reg ,\nz.mem_36_sv2v_reg ,\nz.mem_35_sv2v_reg ,
  \nz.mem_34_sv2v_reg ,\nz.mem_33_sv2v_reg ,\nz.mem_32_sv2v_reg ,\nz.mem_31_sv2v_reg ,
  \nz.mem_30_sv2v_reg ,\nz.mem_29_sv2v_reg ,\nz.mem_28_sv2v_reg ,\nz.mem_27_sv2v_reg ,
  \nz.mem_26_sv2v_reg ,\nz.mem_25_sv2v_reg ,\nz.mem_24_sv2v_reg ,
  \nz.mem_23_sv2v_reg ,\nz.mem_22_sv2v_reg ,\nz.mem_21_sv2v_reg ,\nz.mem_20_sv2v_reg ,
  \nz.mem_19_sv2v_reg ,\nz.mem_18_sv2v_reg ,\nz.mem_17_sv2v_reg ,\nz.mem_16_sv2v_reg ,
  \nz.mem_15_sv2v_reg ,\nz.mem_14_sv2v_reg ,\nz.mem_13_sv2v_reg ,\nz.mem_12_sv2v_reg ,
  \nz.mem_11_sv2v_reg ,\nz.mem_10_sv2v_reg ,\nz.mem_9_sv2v_reg ,\nz.mem_8_sv2v_reg ,
  \nz.mem_7_sv2v_reg ,\nz.mem_6_sv2v_reg ,\nz.mem_5_sv2v_reg ,\nz.mem_4_sv2v_reg ,
  \nz.mem_3_sv2v_reg ,\nz.mem_2_sv2v_reg ,\nz.mem_1_sv2v_reg ,\nz.mem_0_sv2v_reg ;
  assign \nz.addr_r [0] = \nz.addr_r_0_sv2v_reg ;
  assign \nz.mem [63] = \nz.mem_63_sv2v_reg ;
  assign \nz.mem [62] = \nz.mem_62_sv2v_reg ;
  assign \nz.mem [61] = \nz.mem_61_sv2v_reg ;
  assign \nz.mem [60] = \nz.mem_60_sv2v_reg ;
  assign \nz.mem [59] = \nz.mem_59_sv2v_reg ;
  assign \nz.mem [58] = \nz.mem_58_sv2v_reg ;
  assign \nz.mem [57] = \nz.mem_57_sv2v_reg ;
  assign \nz.mem [56] = \nz.mem_56_sv2v_reg ;
  assign \nz.mem [55] = \nz.mem_55_sv2v_reg ;
  assign \nz.mem [54] = \nz.mem_54_sv2v_reg ;
  assign \nz.mem [53] = \nz.mem_53_sv2v_reg ;
  assign \nz.mem [52] = \nz.mem_52_sv2v_reg ;
  assign \nz.mem [51] = \nz.mem_51_sv2v_reg ;
  assign \nz.mem [50] = \nz.mem_50_sv2v_reg ;
  assign \nz.mem [49] = \nz.mem_49_sv2v_reg ;
  assign \nz.mem [48] = \nz.mem_48_sv2v_reg ;
  assign \nz.mem [47] = \nz.mem_47_sv2v_reg ;
  assign \nz.mem [46] = \nz.mem_46_sv2v_reg ;
  assign \nz.mem [45] = \nz.mem_45_sv2v_reg ;
  assign \nz.mem [44] = \nz.mem_44_sv2v_reg ;
  assign \nz.mem [43] = \nz.mem_43_sv2v_reg ;
  assign \nz.mem [42] = \nz.mem_42_sv2v_reg ;
  assign \nz.mem [41] = \nz.mem_41_sv2v_reg ;
  assign \nz.mem [40] = \nz.mem_40_sv2v_reg ;
  assign \nz.mem [39] = \nz.mem_39_sv2v_reg ;
  assign \nz.mem [38] = \nz.mem_38_sv2v_reg ;
  assign \nz.mem [37] = \nz.mem_37_sv2v_reg ;
  assign \nz.mem [36] = \nz.mem_36_sv2v_reg ;
  assign \nz.mem [35] = \nz.mem_35_sv2v_reg ;
  assign \nz.mem [34] = \nz.mem_34_sv2v_reg ;
  assign \nz.mem [33] = \nz.mem_33_sv2v_reg ;
  assign \nz.mem [32] = \nz.mem_32_sv2v_reg ;
  assign \nz.mem [31] = \nz.mem_31_sv2v_reg ;
  assign \nz.mem [30] = \nz.mem_30_sv2v_reg ;
  assign \nz.mem [29] = \nz.mem_29_sv2v_reg ;
  assign \nz.mem [28] = \nz.mem_28_sv2v_reg ;
  assign \nz.mem [27] = \nz.mem_27_sv2v_reg ;
  assign \nz.mem [26] = \nz.mem_26_sv2v_reg ;
  assign \nz.mem [25] = \nz.mem_25_sv2v_reg ;
  assign \nz.mem [24] = \nz.mem_24_sv2v_reg ;
  assign \nz.mem [23] = \nz.mem_23_sv2v_reg ;
  assign \nz.mem [22] = \nz.mem_22_sv2v_reg ;
  assign \nz.mem [21] = \nz.mem_21_sv2v_reg ;
  assign \nz.mem [20] = \nz.mem_20_sv2v_reg ;
  assign \nz.mem [19] = \nz.mem_19_sv2v_reg ;
  assign \nz.mem [18] = \nz.mem_18_sv2v_reg ;
  assign \nz.mem [17] = \nz.mem_17_sv2v_reg ;
  assign \nz.mem [16] = \nz.mem_16_sv2v_reg ;
  assign \nz.mem [15] = \nz.mem_15_sv2v_reg ;
  assign \nz.mem [14] = \nz.mem_14_sv2v_reg ;
  assign \nz.mem [13] = \nz.mem_13_sv2v_reg ;
  assign \nz.mem [12] = \nz.mem_12_sv2v_reg ;
  assign \nz.mem [11] = \nz.mem_11_sv2v_reg ;
  assign \nz.mem [10] = \nz.mem_10_sv2v_reg ;
  assign \nz.mem [9] = \nz.mem_9_sv2v_reg ;
  assign \nz.mem [8] = \nz.mem_8_sv2v_reg ;
  assign \nz.mem [7] = \nz.mem_7_sv2v_reg ;
  assign \nz.mem [6] = \nz.mem_6_sv2v_reg ;
  assign \nz.mem [5] = \nz.mem_5_sv2v_reg ;
  assign \nz.mem [4] = \nz.mem_4_sv2v_reg ;
  assign \nz.mem [3] = \nz.mem_3_sv2v_reg ;
  assign \nz.mem [2] = \nz.mem_2_sv2v_reg ;
  assign \nz.mem [1] = \nz.mem_1_sv2v_reg ;
  assign \nz.mem [0] = \nz.mem_0_sv2v_reg ;
  assign data_o[31] = (N2)? \nz.mem [31] : 
                      (N0)? \nz.mem [63] : 1'b0;
  assign N0 = \nz.addr_r [0];
  assign data_o[30] = (N2)? \nz.mem [30] : 
                      (N0)? \nz.mem [62] : 1'b0;
  assign data_o[29] = (N2)? \nz.mem [29] : 
                      (N0)? \nz.mem [61] : 1'b0;
  assign data_o[28] = (N2)? \nz.mem [28] : 
                      (N0)? \nz.mem [60] : 1'b0;
  assign data_o[27] = (N2)? \nz.mem [27] : 
                      (N0)? \nz.mem [59] : 1'b0;
  assign data_o[26] = (N2)? \nz.mem [26] : 
                      (N0)? \nz.mem [58] : 1'b0;
  assign data_o[25] = (N2)? \nz.mem [25] : 
                      (N0)? \nz.mem [57] : 1'b0;
  assign data_o[24] = (N2)? \nz.mem [24] : 
                      (N0)? \nz.mem [56] : 1'b0;
  assign data_o[23] = (N2)? \nz.mem [23] : 
                      (N0)? \nz.mem [55] : 1'b0;
  assign data_o[22] = (N2)? \nz.mem [22] : 
                      (N0)? \nz.mem [54] : 1'b0;
  assign data_o[21] = (N2)? \nz.mem [21] : 
                      (N0)? \nz.mem [53] : 1'b0;
  assign data_o[20] = (N2)? \nz.mem [20] : 
                      (N0)? \nz.mem [52] : 1'b0;
  assign data_o[19] = (N2)? \nz.mem [19] : 
                      (N0)? \nz.mem [51] : 1'b0;
  assign data_o[18] = (N2)? \nz.mem [18] : 
                      (N0)? \nz.mem [50] : 1'b0;
  assign data_o[17] = (N2)? \nz.mem [17] : 
                      (N0)? \nz.mem [49] : 1'b0;
  assign data_o[16] = (N2)? \nz.mem [16] : 
                      (N0)? \nz.mem [48] : 1'b0;
  assign data_o[15] = (N2)? \nz.mem [15] : 
                      (N0)? \nz.mem [47] : 1'b0;
  assign data_o[14] = (N2)? \nz.mem [14] : 
                      (N0)? \nz.mem [46] : 1'b0;
  assign data_o[13] = (N2)? \nz.mem [13] : 
                      (N0)? \nz.mem [45] : 1'b0;
  assign data_o[12] = (N2)? \nz.mem [12] : 
                      (N0)? \nz.mem [44] : 1'b0;
  assign data_o[11] = (N2)? \nz.mem [11] : 
                      (N0)? \nz.mem [43] : 1'b0;
  assign data_o[10] = (N2)? \nz.mem [10] : 
                      (N0)? \nz.mem [42] : 1'b0;
  assign data_o[9] = (N2)? \nz.mem [9] : 
                     (N0)? \nz.mem [41] : 1'b0;
  assign data_o[8] = (N2)? \nz.mem [8] : 
                     (N0)? \nz.mem [40] : 1'b0;
  assign data_o[7] = (N2)? \nz.mem [7] : 
                     (N0)? \nz.mem [39] : 1'b0;
  assign data_o[6] = (N2)? \nz.mem [6] : 
                     (N0)? \nz.mem [38] : 1'b0;
  assign data_o[5] = (N2)? \nz.mem [5] : 
                     (N0)? \nz.mem [37] : 1'b0;
  assign data_o[4] = (N2)? \nz.mem [4] : 
                     (N0)? \nz.mem [36] : 1'b0;
  assign data_o[3] = (N2)? \nz.mem [3] : 
                     (N0)? \nz.mem [35] : 1'b0;
  assign data_o[2] = (N2)? \nz.mem [2] : 
                     (N0)? \nz.mem [34] : 1'b0;
  assign data_o[1] = (N2)? \nz.mem [1] : 
                     (N0)? \nz.mem [33] : 1'b0;
  assign data_o[0] = (N2)? \nz.mem [0] : 
                     (N0)? \nz.mem [32] : 1'b0;
  assign N5 = ~addr_i[0];
  assign { N8, N7 } = (N1)? { addr_i[0:0], N5 } : 
                      (N4)? { 1'b0, 1'b0 } : 1'b0;
  assign N1 = N3;
  assign N2 = ~\nz.addr_r [0];
  assign N3 = v_i & w_i;
  assign N4 = ~N3;

  always @(posedge clk_i) begin
    if(1'b1) begin
      \nz.addr_r_0_sv2v_reg  <= addr_i[0];
    end 
    if(N8) begin
      \nz.mem_63_sv2v_reg  <= data_i[31];
      \nz.mem_62_sv2v_reg  <= data_i[30];
      \nz.mem_61_sv2v_reg  <= data_i[29];
      \nz.mem_60_sv2v_reg  <= data_i[28];
      \nz.mem_59_sv2v_reg  <= data_i[27];
      \nz.mem_58_sv2v_reg  <= data_i[26];
      \nz.mem_57_sv2v_reg  <= data_i[25];
      \nz.mem_56_sv2v_reg  <= data_i[24];
      \nz.mem_55_sv2v_reg  <= data_i[23];
      \nz.mem_54_sv2v_reg  <= data_i[22];
      \nz.mem_53_sv2v_reg  <= data_i[21];
      \nz.mem_52_sv2v_reg  <= data_i[20];
      \nz.mem_51_sv2v_reg  <= data_i[19];
      \nz.mem_50_sv2v_reg  <= data_i[18];
      \nz.mem_49_sv2v_reg  <= data_i[17];
      \nz.mem_48_sv2v_reg  <= data_i[16];
      \nz.mem_47_sv2v_reg  <= data_i[15];
      \nz.mem_46_sv2v_reg  <= data_i[14];
      \nz.mem_45_sv2v_reg  <= data_i[13];
      \nz.mem_44_sv2v_reg  <= data_i[12];
      \nz.mem_43_sv2v_reg  <= data_i[11];
      \nz.mem_42_sv2v_reg  <= data_i[10];
      \nz.mem_41_sv2v_reg  <= data_i[9];
      \nz.mem_40_sv2v_reg  <= data_i[8];
      \nz.mem_39_sv2v_reg  <= data_i[7];
      \nz.mem_38_sv2v_reg  <= data_i[6];
      \nz.mem_37_sv2v_reg  <= data_i[5];
      \nz.mem_36_sv2v_reg  <= data_i[4];
      \nz.mem_35_sv2v_reg  <= data_i[3];
      \nz.mem_34_sv2v_reg  <= data_i[2];
      \nz.mem_33_sv2v_reg  <= data_i[1];
      \nz.mem_32_sv2v_reg  <= data_i[0];
    end 
    if(N7) begin
      \nz.mem_31_sv2v_reg  <= data_i[31];
      \nz.mem_30_sv2v_reg  <= data_i[30];
      \nz.mem_29_sv2v_reg  <= data_i[29];
      \nz.mem_28_sv2v_reg  <= data_i[28];
      \nz.mem_27_sv2v_reg  <= data_i[27];
      \nz.mem_26_sv2v_reg  <= data_i[26];
      \nz.mem_25_sv2v_reg  <= data_i[25];
      \nz.mem_24_sv2v_reg  <= data_i[24];
      \nz.mem_23_sv2v_reg  <= data_i[23];
      \nz.mem_22_sv2v_reg  <= data_i[22];
      \nz.mem_21_sv2v_reg  <= data_i[21];
      \nz.mem_20_sv2v_reg  <= data_i[20];
      \nz.mem_19_sv2v_reg  <= data_i[19];
      \nz.mem_18_sv2v_reg  <= data_i[18];
      \nz.mem_17_sv2v_reg  <= data_i[17];
      \nz.mem_16_sv2v_reg  <= data_i[16];
      \nz.mem_15_sv2v_reg  <= data_i[15];
      \nz.mem_14_sv2v_reg  <= data_i[14];
      \nz.mem_13_sv2v_reg  <= data_i[13];
      \nz.mem_12_sv2v_reg  <= data_i[12];
      \nz.mem_11_sv2v_reg  <= data_i[11];
      \nz.mem_10_sv2v_reg  <= data_i[10];
      \nz.mem_9_sv2v_reg  <= data_i[9];
      \nz.mem_8_sv2v_reg  <= data_i[8];
      \nz.mem_7_sv2v_reg  <= data_i[7];
      \nz.mem_6_sv2v_reg  <= data_i[6];
      \nz.mem_5_sv2v_reg  <= data_i[5];
      \nz.mem_4_sv2v_reg  <= data_i[4];
      \nz.mem_3_sv2v_reg  <= data_i[3];
      \nz.mem_2_sv2v_reg  <= data_i[2];
      \nz.mem_1_sv2v_reg  <= data_i[1];
      \nz.mem_0_sv2v_reg  <= data_i[0];
    end 
  end


endmodule



module bsg_mem_1rw_sync_width_p32_els_p2
(
  clk_i,
  reset_i,
  data_i,
  addr_i,
  v_i,
  w_i,
  data_o
);

  input [31:0] data_i;
  input [0:0] addr_i;
  output [31:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input w_i;
  wire [31:0] data_o;

  bsg_mem_1rw_sync_synth_width_p32_els_p2_latch_last_read_p0_verbose_p1
  synth
  (
    .clk_i(clk_i),
    .v_i(v_i),
    .reset_i(reset_i),
    .data_i(data_i),
    .addr_i(addr_i[0]),
    .w_i(w_i),
    .data_o(data_o)
  );


endmodule



module bsg_fifo_1rw_large_width_p32_els_p2
(
  clk_i,
  reset_i,
  data_i,
  v_i,
  enq_not_deq_i,
  full_o,
  empty_o,
  data_o
);

  input [31:0] data_i;
  output [31:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input enq_not_deq_i;
  output full_o;
  output empty_o;
  wire [31:0] data_o;
  wire full_o,empty_o,N0,N1,N2,N3,N4,mem_we,mem_re,N5,N6,last_op_is_read_r,N7,N8,N9,
  _0_net__0_,N10,N11,N12,N13,sv2v_dc_1,sv2v_dc_2;
  wire [0:0] rd_ptr,wr_ptr;
  reg last_op_is_read_r_sv2v_reg;
  assign last_op_is_read_r = last_op_is_read_r_sv2v_reg;
  assign N0 = rd_ptr[0] ^ wr_ptr[0];
  assign N8 = ~N0;
  assign N1 = rd_ptr[0] ^ wr_ptr[0];
  assign N9 = ~N1;

  bsg_circular_ptr_slots_p2_max_add_p1
  rd_circ_ptr
  (
    .clk(clk_i),
    .reset_i(reset_i),
    .add_i(mem_re),
    .o(rd_ptr[0]),
    .n_o(sv2v_dc_1)
  );


  bsg_circular_ptr_slots_p2_max_add_p1
  wr_circ_ptr
  (
    .clk(clk_i),
    .reset_i(reset_i),
    .add_i(mem_we),
    .o(wr_ptr[0]),
    .n_o(sv2v_dc_2)
  );


  bsg_mem_1rw_sync_width_p32_els_p2
  mem_1srw
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .data_i(data_i),
    .addr_i(_0_net__0_),
    .v_i(v_i),
    .w_i(mem_we),
    .data_o(data_o)
  );

  assign N7 = (N2)? 1'b1 : 
              (N6)? 1'b0 : 1'b0;
  assign N2 = N5;
  assign _0_net__0_ = (N3)? wr_ptr[0] : 
                      (N4)? rd_ptr[0] : 1'b0;
  assign N3 = N11;
  assign N4 = N10;
  assign mem_we = enq_not_deq_i & v_i;
  assign mem_re = N12 & v_i;
  assign N12 = ~enq_not_deq_i;
  assign N5 = v_i;
  assign N6 = ~N5;
  assign empty_o = N8 & last_op_is_read_r;
  assign full_o = N9 & N13;
  assign N13 = ~last_op_is_read_r;
  assign N10 = ~mem_we;
  assign N11 = mem_we;

  always @(posedge clk_i) begin
    if(reset_i) begin
      last_op_is_read_r_sv2v_reg <= 1'b1;
    end else if(N7) begin
      last_op_is_read_r_sv2v_reg <= mem_re;
    end 
  end


endmodule



module bsg_thermometer_count_width_p2
(
  i,
  o
);

  input [1:0] i;
  output [1:0] o;
  wire [1:0] o;
  wire o_1_,N0;
  assign o_1_ = i[1];
  assign o[1] = o_1_;
  assign o[0] = i[0] & N0;
  assign N0 = ~o_1_;

endmodule



module bsg_round_robin_2_to_2_width_p16
(
  clk_i,
  reset_i,
  data_i,
  v_i,
  ready_o,
  data_o,
  v_o,
  ready_i
);

  input [31:0] data_i;
  input [1:0] v_i;
  output [1:0] ready_o;
  output [31:0] data_o;
  output [1:0] v_o;
  input [1:0] ready_i;
  input clk_i;
  input reset_i;
  wire [1:0] ready_o,v_o;
  wire [31:0] data_o;
  wire N0,N1,head_r,N2,N3,N4,N5,N6;
  reg head_r_sv2v_reg;
  assign head_r = head_r_sv2v_reg;
  assign data_o = (N0)? { data_i[15:0], data_i[31:16] } : 
                  (N1)? data_i : 1'b0;
  assign N0 = head_r;
  assign N1 = N3;
  assign v_o = (N0)? { v_i[0:0], v_i[1:1] } : 
               (N1)? v_i : 1'b0;
  assign ready_o = (N0)? { ready_i[0:0], ready_i[1:1] } : 
                   (N1)? ready_i : 1'b0;
  assign N2 = N5 ^ N6;
  assign N5 = head_r ^ N4;
  assign N4 = v_i[1] & ready_o[1];
  assign N6 = v_i[0] & ready_o[0];
  assign N3 = ~head_r;

  always @(posedge clk_i) begin
    if(reset_i) begin
      head_r_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      head_r_sv2v_reg <= N2;
    end 
  end


endmodule



module bsg_mem_1r1w_synth_width_p16_els_p2_read_write_same_addr_p0
(
  w_clk_i,
  w_reset_i,
  w_v_i,
  w_addr_i,
  w_data_i,
  r_v_i,
  r_addr_i,
  r_data_o
);

  input [0:0] w_addr_i;
  input [15:0] w_data_i;
  input [0:0] r_addr_i;
  output [15:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [15:0] r_data_o;
  wire N0,N1,N2,N3,N4,N5,N7,N8;
  wire [31:0] \nz.mem ;
  reg \nz.mem_31_sv2v_reg ,\nz.mem_30_sv2v_reg ,\nz.mem_29_sv2v_reg ,
  \nz.mem_28_sv2v_reg ,\nz.mem_27_sv2v_reg ,\nz.mem_26_sv2v_reg ,\nz.mem_25_sv2v_reg ,
  \nz.mem_24_sv2v_reg ,\nz.mem_23_sv2v_reg ,\nz.mem_22_sv2v_reg ,\nz.mem_21_sv2v_reg ,
  \nz.mem_20_sv2v_reg ,\nz.mem_19_sv2v_reg ,\nz.mem_18_sv2v_reg ,\nz.mem_17_sv2v_reg ,
  \nz.mem_16_sv2v_reg ,\nz.mem_15_sv2v_reg ,\nz.mem_14_sv2v_reg ,\nz.mem_13_sv2v_reg ,
  \nz.mem_12_sv2v_reg ,\nz.mem_11_sv2v_reg ,\nz.mem_10_sv2v_reg ,
  \nz.mem_9_sv2v_reg ,\nz.mem_8_sv2v_reg ,\nz.mem_7_sv2v_reg ,\nz.mem_6_sv2v_reg ,
  \nz.mem_5_sv2v_reg ,\nz.mem_4_sv2v_reg ,\nz.mem_3_sv2v_reg ,\nz.mem_2_sv2v_reg ,
  \nz.mem_1_sv2v_reg ,\nz.mem_0_sv2v_reg ;
  assign \nz.mem [31] = \nz.mem_31_sv2v_reg ;
  assign \nz.mem [30] = \nz.mem_30_sv2v_reg ;
  assign \nz.mem [29] = \nz.mem_29_sv2v_reg ;
  assign \nz.mem [28] = \nz.mem_28_sv2v_reg ;
  assign \nz.mem [27] = \nz.mem_27_sv2v_reg ;
  assign \nz.mem [26] = \nz.mem_26_sv2v_reg ;
  assign \nz.mem [25] = \nz.mem_25_sv2v_reg ;
  assign \nz.mem [24] = \nz.mem_24_sv2v_reg ;
  assign \nz.mem [23] = \nz.mem_23_sv2v_reg ;
  assign \nz.mem [22] = \nz.mem_22_sv2v_reg ;
  assign \nz.mem [21] = \nz.mem_21_sv2v_reg ;
  assign \nz.mem [20] = \nz.mem_20_sv2v_reg ;
  assign \nz.mem [19] = \nz.mem_19_sv2v_reg ;
  assign \nz.mem [18] = \nz.mem_18_sv2v_reg ;
  assign \nz.mem [17] = \nz.mem_17_sv2v_reg ;
  assign \nz.mem [16] = \nz.mem_16_sv2v_reg ;
  assign \nz.mem [15] = \nz.mem_15_sv2v_reg ;
  assign \nz.mem [14] = \nz.mem_14_sv2v_reg ;
  assign \nz.mem [13] = \nz.mem_13_sv2v_reg ;
  assign \nz.mem [12] = \nz.mem_12_sv2v_reg ;
  assign \nz.mem [11] = \nz.mem_11_sv2v_reg ;
  assign \nz.mem [10] = \nz.mem_10_sv2v_reg ;
  assign \nz.mem [9] = \nz.mem_9_sv2v_reg ;
  assign \nz.mem [8] = \nz.mem_8_sv2v_reg ;
  assign \nz.mem [7] = \nz.mem_7_sv2v_reg ;
  assign \nz.mem [6] = \nz.mem_6_sv2v_reg ;
  assign \nz.mem [5] = \nz.mem_5_sv2v_reg ;
  assign \nz.mem [4] = \nz.mem_4_sv2v_reg ;
  assign \nz.mem [3] = \nz.mem_3_sv2v_reg ;
  assign \nz.mem [2] = \nz.mem_2_sv2v_reg ;
  assign \nz.mem [1] = \nz.mem_1_sv2v_reg ;
  assign \nz.mem [0] = \nz.mem_0_sv2v_reg ;
  assign r_data_o[15] = (N3)? \nz.mem [15] : 
                        (N0)? \nz.mem [31] : 1'b0;
  assign N0 = r_addr_i[0];
  assign r_data_o[14] = (N3)? \nz.mem [14] : 
                        (N0)? \nz.mem [30] : 1'b0;
  assign r_data_o[13] = (N3)? \nz.mem [13] : 
                        (N0)? \nz.mem [29] : 1'b0;
  assign r_data_o[12] = (N3)? \nz.mem [12] : 
                        (N0)? \nz.mem [28] : 1'b0;
  assign r_data_o[11] = (N3)? \nz.mem [11] : 
                        (N0)? \nz.mem [27] : 1'b0;
  assign r_data_o[10] = (N3)? \nz.mem [10] : 
                        (N0)? \nz.mem [26] : 1'b0;
  assign r_data_o[9] = (N3)? \nz.mem [9] : 
                       (N0)? \nz.mem [25] : 1'b0;
  assign r_data_o[8] = (N3)? \nz.mem [8] : 
                       (N0)? \nz.mem [24] : 1'b0;
  assign r_data_o[7] = (N3)? \nz.mem [7] : 
                       (N0)? \nz.mem [23] : 1'b0;
  assign r_data_o[6] = (N3)? \nz.mem [6] : 
                       (N0)? \nz.mem [22] : 1'b0;
  assign r_data_o[5] = (N3)? \nz.mem [5] : 
                       (N0)? \nz.mem [21] : 1'b0;
  assign r_data_o[4] = (N3)? \nz.mem [4] : 
                       (N0)? \nz.mem [20] : 1'b0;
  assign r_data_o[3] = (N3)? \nz.mem [3] : 
                       (N0)? \nz.mem [19] : 1'b0;
  assign r_data_o[2] = (N3)? \nz.mem [2] : 
                       (N0)? \nz.mem [18] : 1'b0;
  assign r_data_o[1] = (N3)? \nz.mem [1] : 
                       (N0)? \nz.mem [17] : 1'b0;
  assign r_data_o[0] = (N3)? \nz.mem [0] : 
                       (N0)? \nz.mem [16] : 1'b0;
  assign N5 = ~w_addr_i[0];
  assign { N8, N7 } = (N1)? { w_addr_i[0:0], N5 } : 
                      (N2)? { 1'b0, 1'b0 } : 1'b0;
  assign N1 = w_v_i;
  assign N2 = N4;
  assign N3 = ~r_addr_i[0];
  assign N4 = ~w_v_i;

  always @(posedge w_clk_i) begin
    if(N8) begin
      \nz.mem_31_sv2v_reg  <= w_data_i[15];
      \nz.mem_30_sv2v_reg  <= w_data_i[14];
      \nz.mem_29_sv2v_reg  <= w_data_i[13];
      \nz.mem_28_sv2v_reg  <= w_data_i[12];
      \nz.mem_27_sv2v_reg  <= w_data_i[11];
      \nz.mem_26_sv2v_reg  <= w_data_i[10];
      \nz.mem_25_sv2v_reg  <= w_data_i[9];
      \nz.mem_24_sv2v_reg  <= w_data_i[8];
      \nz.mem_23_sv2v_reg  <= w_data_i[7];
      \nz.mem_22_sv2v_reg  <= w_data_i[6];
      \nz.mem_21_sv2v_reg  <= w_data_i[5];
      \nz.mem_20_sv2v_reg  <= w_data_i[4];
      \nz.mem_19_sv2v_reg  <= w_data_i[3];
      \nz.mem_18_sv2v_reg  <= w_data_i[2];
      \nz.mem_17_sv2v_reg  <= w_data_i[1];
      \nz.mem_16_sv2v_reg  <= w_data_i[0];
    end 
    if(N7) begin
      \nz.mem_15_sv2v_reg  <= w_data_i[15];
      \nz.mem_14_sv2v_reg  <= w_data_i[14];
      \nz.mem_13_sv2v_reg  <= w_data_i[13];
      \nz.mem_12_sv2v_reg  <= w_data_i[12];
      \nz.mem_11_sv2v_reg  <= w_data_i[11];
      \nz.mem_10_sv2v_reg  <= w_data_i[10];
      \nz.mem_9_sv2v_reg  <= w_data_i[9];
      \nz.mem_8_sv2v_reg  <= w_data_i[8];
      \nz.mem_7_sv2v_reg  <= w_data_i[7];
      \nz.mem_6_sv2v_reg  <= w_data_i[6];
      \nz.mem_5_sv2v_reg  <= w_data_i[5];
      \nz.mem_4_sv2v_reg  <= w_data_i[4];
      \nz.mem_3_sv2v_reg  <= w_data_i[3];
      \nz.mem_2_sv2v_reg  <= w_data_i[2];
      \nz.mem_1_sv2v_reg  <= w_data_i[1];
      \nz.mem_0_sv2v_reg  <= w_data_i[0];
    end 
  end


endmodule



module bsg_mem_1r1w_width_p16_els_p2_read_write_same_addr_p0
(
  w_clk_i,
  w_reset_i,
  w_v_i,
  w_addr_i,
  w_data_i,
  r_v_i,
  r_addr_i,
  r_data_o
);

  input [0:0] w_addr_i;
  input [15:0] w_data_i;
  input [0:0] r_addr_i;
  output [15:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [15:0] r_data_o;

  bsg_mem_1r1w_synth_width_p16_els_p2_read_write_same_addr_p0
  synth
  (
    .w_clk_i(w_clk_i),
    .w_reset_i(w_reset_i),
    .w_v_i(w_v_i),
    .w_addr_i(w_addr_i[0]),
    .w_data_i(w_data_i),
    .r_v_i(r_v_i),
    .r_addr_i(r_addr_i[0]),
    .r_data_o(r_data_o)
  );


endmodule



module bsg_two_fifo_width_p16
(
  clk_i,
  reset_i,
  ready_o,
  data_i,
  v_i,
  v_o,
  data_o,
  yumi_i
);

  input [15:0] data_i;
  output [15:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output ready_o;
  output v_o;
  wire [15:0] data_o;
  wire ready_o,v_o,enq_i,tail_r,_0_net_,head_r,empty_r,full_r,N0,N1,N2,N3,N4,N5,N6,N7,
  N8,N9,N10,N11,N12,N13,N14;
  reg full_r_sv2v_reg,tail_r_sv2v_reg,head_r_sv2v_reg,empty_r_sv2v_reg;
  assign full_r = full_r_sv2v_reg;
  assign tail_r = tail_r_sv2v_reg;
  assign head_r = head_r_sv2v_reg;
  assign empty_r = empty_r_sv2v_reg;

  bsg_mem_1r1w_width_p16_els_p2_read_write_same_addr_p0
  mem_1r1w
  (
    .w_clk_i(clk_i),
    .w_reset_i(reset_i),
    .w_v_i(enq_i),
    .w_addr_i(tail_r),
    .w_data_i(data_i),
    .r_v_i(_0_net_),
    .r_addr_i(head_r),
    .r_data_o(data_o)
  );

  assign _0_net_ = ~empty_r;
  assign v_o = ~empty_r;
  assign ready_o = ~full_r;
  assign enq_i = v_i & N5;
  assign N5 = ~full_r;
  assign N1 = enq_i;
  assign N0 = ~tail_r;
  assign N2 = ~head_r;
  assign N3 = N7 | N9;
  assign N7 = empty_r & N6;
  assign N6 = ~enq_i;
  assign N9 = N8 & N6;
  assign N8 = N5 & yumi_i;
  assign N4 = N13 | N14;
  assign N13 = N11 & N12;
  assign N11 = N10 & enq_i;
  assign N10 = ~empty_r;
  assign N12 = ~yumi_i;
  assign N14 = full_r & N12;

  always @(posedge clk_i) begin
    if(reset_i) begin
      full_r_sv2v_reg <= 1'b0;
      empty_r_sv2v_reg <= 1'b1;
    end else if(1'b1) begin
      full_r_sv2v_reg <= N4;
      empty_r_sv2v_reg <= N3;
    end 
    if(reset_i) begin
      tail_r_sv2v_reg <= 1'b0;
    end else if(N1) begin
      tail_r_sv2v_reg <= N0;
    end 
    if(reset_i) begin
      head_r_sv2v_reg <= 1'b0;
    end else if(yumi_i) begin
      head_r_sv2v_reg <= N2;
    end 
  end


endmodule



module bsg_round_robin_n_to_1_width_p16_num_in_p2_strict_p1
(
  clk_i,
  reset_i,
  data_i,
  v_i,
  yumi_o,
  v_o,
  data_o,
  tag_o,
  yumi_i
);

  input [31:0] data_i;
  input [1:0] v_i;
  output [1:0] yumi_o;
  output [15:0] data_o;
  output [0:0] tag_o;
  input clk_i;
  input reset_i;
  input yumi_i;
  output v_o;
  wire [1:0] yumi_o;
  wire [15:0] data_o;
  wire [0:0] tag_o;
  wire v_o,N0,N1,sv2v_dc_1;

  bsg_circular_ptr_slots_p2_max_add_p1
  \strict.circular_ptr 
  (
    .clk(clk_i),
    .reset_i(reset_i),
    .add_i(yumi_i),
    .o(tag_o[0]),
    .n_o(sv2v_dc_1)
  );

  assign v_o = (N1)? v_i[0] : 
               (N0)? v_i[1] : 1'b0;
  assign N0 = tag_o[0];
  assign data_o[15] = (N1)? data_i[15] : 
                      (N0)? data_i[31] : 1'b0;
  assign data_o[14] = (N1)? data_i[14] : 
                      (N0)? data_i[30] : 1'b0;
  assign data_o[13] = (N1)? data_i[13] : 
                      (N0)? data_i[29] : 1'b0;
  assign data_o[12] = (N1)? data_i[12] : 
                      (N0)? data_i[28] : 1'b0;
  assign data_o[11] = (N1)? data_i[11] : 
                      (N0)? data_i[27] : 1'b0;
  assign data_o[10] = (N1)? data_i[10] : 
                      (N0)? data_i[26] : 1'b0;
  assign data_o[9] = (N1)? data_i[9] : 
                     (N0)? data_i[25] : 1'b0;
  assign data_o[8] = (N1)? data_i[8] : 
                     (N0)? data_i[24] : 1'b0;
  assign data_o[7] = (N1)? data_i[7] : 
                     (N0)? data_i[23] : 1'b0;
  assign data_o[6] = (N1)? data_i[6] : 
                     (N0)? data_i[22] : 1'b0;
  assign data_o[5] = (N1)? data_i[5] : 
                     (N0)? data_i[21] : 1'b0;
  assign data_o[4] = (N1)? data_i[4] : 
                     (N0)? data_i[20] : 1'b0;
  assign data_o[3] = (N1)? data_i[3] : 
                     (N0)? data_i[19] : 1'b0;
  assign data_o[2] = (N1)? data_i[2] : 
                     (N0)? data_i[18] : 1'b0;
  assign data_o[1] = (N1)? data_i[1] : 
                     (N0)? data_i[17] : 1'b0;
  assign data_o[0] = (N1)? data_i[0] : 
                     (N0)? data_i[16] : 1'b0;
  assign yumi_o = { 1'b0, yumi_i } << tag_o[0];
  assign N1 = ~tag_o[0];

endmodule



module bsg_fifo_1r1w_large_width_p16_els_p4
(
  clk_i,
  reset_i,
  data_i,
  v_i,
  ready_o,
  v_o,
  data_o,
  yumi_i
);

  input [15:0] data_i;
  output [15:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output ready_o;
  output v_o;
  wire [15:0] data_o;
  wire ready_o,v_o,N0,N1,N2,N3,big_deq_r,big_deq,big_valid,big_full_lo,big_empty_lo,
  bypass_mode,can_spill,emergency,will_spill,N4,N5,N6,_0_net__1_,_0_net__0_,N7,N8,N9,
  N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,sv2v_dc_1;
  wire [1:0] valid_sipo,yumi_cnt_sipo,little_ready,little_ready_rot,valid_int,bypass_vector,
  little_valid,cnt,little_valid_rot,yumi_int;
  wire [31:0] data_sipo,big_data_lo,little_data,little_data_rot,data_int;
  reg big_deq_r_sv2v_reg;
  assign big_deq_r = big_deq_r_sv2v_reg;

  bsg_serial_in_parallel_out_width_p16_els_p3_out_els_p2
  sipo
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .valid_i(v_i),
    .data_i(data_i),
    .ready_o(ready_o),
    .valid_o(valid_sipo),
    .data_o(data_sipo),
    .yumi_cnt_i(yumi_cnt_sipo)
  );


  bsg_fifo_1rw_large_width_p32_els_p2
  big1p
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .data_i(data_sipo),
    .v_i(big_valid),
    .enq_not_deq_i(will_spill),
    .full_o(big_full_lo),
    .empty_o(big_empty_lo),
    .data_o(big_data_lo)
  );


  bsg_thermometer_count_width_p2
  thermo
  (
    .i({ _0_net__1_, _0_net__0_ }),
    .o(cnt)
  );


  bsg_round_robin_2_to_2_width_p16
  rr222
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .data_i(little_data),
    .v_i(little_valid),
    .ready_o(little_ready),
    .data_o(little_data_rot),
    .v_o(little_valid_rot),
    .ready_i(little_ready_rot)
  );


  bsg_two_fifo_width_p16
  \twofer_0_.little 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(little_ready_rot[0]),
    .data_i(little_data_rot[15:0]),
    .v_i(little_valid_rot[0]),
    .v_o(valid_int[0]),
    .data_o(data_int[15:0]),
    .yumi_i(yumi_int[0])
  );


  bsg_two_fifo_width_p16
  \twofer_1_.little 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(little_ready_rot[1]),
    .data_i(little_data_rot[31:16]),
    .v_i(little_valid_rot[1]),
    .v_o(valid_int[1]),
    .data_o(data_int[31:16]),
    .yumi_i(yumi_int[1])
  );


  bsg_round_robin_n_to_1_width_p16_num_in_p2_strict_p1
  round_robin_n_to_1
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .data_i(data_int),
    .v_i(valid_int),
    .yumi_o(yumi_int),
    .v_o(v_o),
    .data_o(data_o),
    .tag_o(sv2v_dc_1),
    .yumi_i(yumi_i)
  );

  assign N6 = (N0)? N4 : 
              (N1)? N5 : 1'b0;
  assign N0 = big_deq_r;
  assign N1 = N9;
  assign little_data = (N0)? big_data_lo : 
                       (N1)? data_sipo : 1'b0;
  assign little_valid = (N0)? { 1'b1, 1'b1 } : 
                        (N1)? bypass_vector : 1'b0;
  assign yumi_cnt_sipo = (N2)? { 1'b1, 1'b0 } : 
                         (N3)? cnt : 1'b0;
  assign N2 = N8;
  assign N3 = N7;
  assign bypass_mode = N10 & big_empty_lo;
  assign N10 = N9 & little_ready[0];
  assign N9 = ~big_deq_r;
  assign can_spill = N11 & N12;
  assign N11 = ~big_full_lo;
  assign N12 = ~bypass_mode;
  assign emergency = N15 & N9;
  assign N15 = N13 & N14;
  assign N13 = little_ready_rot[1] & little_ready_rot[0];
  assign N14 = ~big_empty_lo;
  assign will_spill = N17 & N18;
  assign N17 = can_spill & N16;
  assign N16 = valid_sipo[1] & valid_sipo[0];
  assign N18 = ~emergency;
  assign N4 = ~N19;
  assign N19 = valid_int[1] | valid_int[0];
  assign N5 = little_ready_rot[1] & little_ready_rot[0];
  assign big_deq = N21 & N6;
  assign N21 = N20 & N14;
  assign N20 = ~will_spill;
  assign big_valid = will_spill | big_deq;
  assign bypass_vector[1] = valid_sipo[1] & bypass_mode;
  assign bypass_vector[0] = valid_sipo[0] & bypass_mode;
  assign _0_net__1_ = little_ready[1] & bypass_vector[1];
  assign _0_net__0_ = little_ready[0] & bypass_vector[0];
  assign N7 = ~will_spill;
  assign N8 = will_spill;

  always @(posedge clk_i) begin
    if(1'b1) begin
      big_deq_r_sv2v_reg <= big_deq;
    end 
  end


endmodule



module bsg_counter_clear_up_max_val_p3_init_val_p0
(
  clk_i,
  reset_i,
  clear_i,
  up_i,
  count_o
);

  output [1:0] count_o;
  input clk_i;
  input reset_i;
  input clear_i;
  input up_i;
  wire [1:0] count_o;
  wire N0,N1,N4,N5,N6,N8,N9,N10,N11,N12,N13,N14,N2,N3,N7,N30,N15;
  reg count_o_1_sv2v_reg,count_o_0_sv2v_reg;
  assign count_o[1] = count_o_1_sv2v_reg;
  assign count_o[0] = count_o_0_sv2v_reg;
  assign N15 = reset_i | clear_i;
  assign { N6, N5 } = count_o + 1'b1;
  assign N8 = (N0)? 1'b1 : 
              (N7)? 1'b1 : 
              (N3)? 1'b0 : 1'b0;
  assign N0 = clear_i;
  assign N10 = (N1)? 1'b1 : 
               (N30)? 1'b0 : 1'b0;
  assign N1 = up_i;
  assign N9 = (N0)? up_i : 
              (N7)? N5 : 1'b0;
  assign N4 = N14;
  assign N11 = ~reset_i;
  assign N12 = ~clear_i;
  assign N13 = N11 & N12;
  assign N14 = up_i & N13;
  assign N2 = up_i | clear_i;
  assign N3 = ~N2;
  assign N7 = up_i & N12;
  assign N30 = ~up_i;

  always @(posedge clk_i) begin
    if(N15) begin
      count_o_1_sv2v_reg <= 1'b0;
    end else if(N10) begin
      count_o_1_sv2v_reg <= N6;
    end 
    if(reset_i) begin
      count_o_0_sv2v_reg <= 1'b0;
    end else if(N8) begin
      count_o_0_sv2v_reg <= N9;
    end 
  end


endmodule



module bsg_cache_to_dram_ctrl_rx
(
  clk_i,
  reset_i,
  dma_data_o,
  dma_data_v_o,
  dma_data_ready_i,
  app_rd_data_valid_i,
  app_rd_data_end_i,
  app_rd_data_i
);

  output [15:0] dma_data_o;
  input [15:0] app_rd_data_i;
  input clk_i;
  input reset_i;
  input dma_data_ready_i;
  input app_rd_data_valid_i;
  input app_rd_data_end_i;
  output dma_data_v_o;
  wire [15:0] dma_data_o;
  wire dma_data_v_o,N0,fifo_yumi_li,counter_clear_li,counter_up_li,N1,N2;
  wire [1:0] count_lo;

  bsg_fifo_1r1w_large_width_p16_els_p4
  fifo
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .data_i(app_rd_data_i),
    .v_i(app_rd_data_valid_i),
    .v_o(dma_data_v_o),
    .data_o(dma_data_o),
    .yumi_i(fifo_yumi_li)
  );


  bsg_counter_clear_up_max_val_p3_init_val_p0
  counter
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .clear_i(counter_clear_li),
    .up_i(counter_up_li),
    .count_o(count_lo)
  );

  assign N2 = count_lo[0] & count_lo[1];
  assign counter_clear_li = (N0)? fifo_yumi_li : 
                            (N1)? 1'b0 : 1'b0;
  assign N0 = N2;
  assign counter_up_li = (N0)? 1'b0 : 
                         (N1)? fifo_yumi_li : 1'b0;
  assign fifo_yumi_li = dma_data_v_o & dma_data_ready_i;
  assign N1 = ~N2;

endmodule

