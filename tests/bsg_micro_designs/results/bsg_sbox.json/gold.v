

module top
(
  clk_i,
  reset_i,
  calibration_done_i,
  channel_active_i,
  in_v_i,
  in_data_i,
  in_yumi_o,
  in_v_o,
  in_data_o,
  in_yumi_i,
  out_me_v_i,
  out_me_data_i,
  out_me_ready_o,
  out_me_v_o,
  out_me_data_o,
  out_me_ready_i
);

  input [3:0] channel_active_i;
  input [3:0] in_v_i;
  input [63:0] in_data_i;
  output [3:0] in_yumi_o;
  output [3:0] in_v_o;
  output [63:0] in_data_o;
  input [3:0] in_yumi_i;
  input [3:0] out_me_v_i;
  input [63:0] out_me_data_i;
  output [3:0] out_me_ready_o;
  output [3:0] out_me_v_o;
  output [63:0] out_me_data_o;
  input [3:0] out_me_ready_i;
  input clk_i;
  input reset_i;
  input calibration_done_i;

  bsg_sbox
  wrapper
  (
    .channel_active_i(channel_active_i),
    .in_v_i(in_v_i),
    .in_data_i(in_data_i),
    .in_yumi_o(in_yumi_o),
    .in_v_o(in_v_o),
    .in_data_o(in_data_o),
    .in_yumi_i(in_yumi_i),
    .out_me_v_i(out_me_v_i),
    .out_me_data_i(out_me_data_i),
    .out_me_ready_o(out_me_ready_o),
    .out_me_v_o(out_me_v_o),
    .out_me_data_o(out_me_data_o),
    .out_me_ready_i(out_me_ready_i),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .calibration_done_i(calibration_done_i)
  );


endmodule



module bsg_scatter_gather_vec_size_lp4
(
  vec_i,
  fwd_o,
  fwd_datapath_o,
  bk_o,
  bk_datapath_o
);

  input [3:0] vec_i;
  output [7:0] fwd_o;
  output [7:0] fwd_datapath_o;
  output [7:0] bk_o;
  output [7:0] bk_datapath_o;
  wire [7:0] fwd_o,fwd_datapath_o,bk_o,bk_datapath_o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,
  N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,N41,
  N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53,N54,N55,N56,N57,N58,N59,N60,N61;
  assign fwd_datapath_o[5] = 1'b0;
  assign fwd_datapath_o[6] = 1'b0;
  assign fwd_datapath_o[7] = 1'b0;
  assign bk_datapath_o[0] = 1'b0;
  assign bk_datapath_o[1] = 1'b0;
  assign bk_datapath_o[3] = 1'b0;
  assign N20 = N16 & N17;
  assign N21 = N18 & N19;
  assign N22 = N20 & N21;
  assign N23 = vec_i[3] | vec_i[2];
  assign N24 = vec_i[1] | N19;
  assign N25 = N23 | N24;
  assign N27 = N18 | vec_i[0];
  assign N28 = N23 | N27;
  assign N30 = N18 | N19;
  assign N31 = N23 | N30;
  assign N33 = vec_i[3] | N17;
  assign N34 = vec_i[1] | vec_i[0];
  assign N35 = N33 | N34;
  assign N37 = N33 | N24;
  assign N39 = N33 | N27;
  assign N41 = N33 | N30;
  assign N43 = N16 | vec_i[2];
  assign N44 = N43 | N34;
  assign N46 = N43 | N24;
  assign N48 = N43 | N27;
  assign N50 = N43 | N30;
  assign N52 = N16 | N17;
  assign N53 = N52 | N34;
  assign N55 = N52 | N24;
  assign N57 = N52 | N27;
  assign N59 = vec_i[3] & vec_i[2];
  assign N60 = vec_i[1] & vec_i[0];
  assign N61 = N59 & N60;
  assign bk_o = (N0)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 } : 
                (N1)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                (N2)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1 } : 
                (N3)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                (N4)? { 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1 } : 
                (N5)? { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                (N6)? { 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1 } : 
                (N7)? { 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                (N8)? { 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 } : 
                (N9)? { 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                (N10)? { 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1 } : 
                (N11)? { 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                (N12)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1 } : 
                (N13)? { 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                (N14)? { 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1 } : 
                (N15)? { 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 } : 1'b0;
  assign N0 = N22;
  assign N1 = N26;
  assign N2 = N29;
  assign N3 = N32;
  assign N4 = N36;
  assign N5 = N38;
  assign N6 = N40;
  assign N7 = N42;
  assign N8 = N45;
  assign N9 = N47;
  assign N10 = N49;
  assign N11 = N51;
  assign N12 = N54;
  assign N13 = N56;
  assign N14 = N58;
  assign N15 = N61;
  assign { bk_datapath_o[7:4], bk_datapath_o[2:2] } = (N0)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                      (N1)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                      (N2)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                      (N3)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 } : 
                                                      (N4)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                      (N5)? { 1'b0, 1'b0, 1'b0, 1'b1, 1'b0 } : 
                                                      (N6)? { 1'b0, 1'b0, 1'b0, 1'b1, 1'b0 } : 
                                                      (N7)? { 1'b0, 1'b0, 1'b1, 1'b0, 1'b1 } : 
                                                      (N8)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                      (N9)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                                                      (N10)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                                                      (N11)? { 1'b1, 1'b0, 1'b0, 1'b0, 1'b1 } : 
                                                      (N12)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                                                      (N13)? { 1'b1, 1'b0, 1'b0, 1'b1, 1'b0 } : 
                                                      (N14)? { 1'b1, 1'b0, 1'b0, 1'b1, 1'b0 } : 
                                                      (N15)? { 1'b1, 1'b1, 1'b1, 1'b0, 1'b1 } : 1'b0;
  assign fwd_o = (N0)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 } : 
                 (N1)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                 (N2)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1 } : 
                 (N3)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                 (N4)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0 } : 
                 (N5)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                 (N6)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1 } : 
                 (N7)? { 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                 (N8)? { 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1 } : 
                 (N9)? { 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                 (N10)? { 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1 } : 
                 (N11)? { 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                 (N12)? { 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0 } : 
                 (N13)? { 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                 (N14)? { 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1 } : 
                 (N15)? { 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 } : 1'b0;
  assign fwd_datapath_o[4:0] = (N0)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                               (N1)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                               (N2)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 } : 
                               (N3)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                               (N4)? { 1'b0, 1'b0, 1'b0, 1'b1, 1'b0 } : 
                               (N5)? { 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                               (N6)? { 1'b0, 1'b0, 1'b1, 1'b0, 1'b1 } : 
                               (N7)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                               (N8)? { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1 } : 
                               (N9)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                               (N10)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b1 } : 
                               (N11)? { 1'b1, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                               (N12)? { 1'b0, 1'b1, 1'b0, 1'b1, 1'b0 } : 
                               (N13)? { 1'b1, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                               (N14)? { 1'b1, 1'b0, 1'b1, 1'b0, 1'b1 } : 
                               (N15)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 1'b0;
  assign N16 = ~vec_i[3];
  assign N17 = ~vec_i[2];
  assign N18 = ~vec_i[1];
  assign N19 = ~vec_i[0];
  assign N26 = ~N25;
  assign N29 = ~N28;
  assign N32 = ~N31;
  assign N36 = ~N35;
  assign N38 = ~N37;
  assign N40 = ~N39;
  assign N42 = ~N41;
  assign N45 = ~N44;
  assign N47 = ~N46;
  assign N49 = ~N48;
  assign N51 = ~N50;
  assign N54 = ~N53;
  assign N56 = ~N55;
  assign N58 = ~N57;

endmodule



module bsg_sbox
(
  clk_i,
  reset_i,
  calibration_done_i,
  channel_active_i,
  in_v_i,
  in_data_i,
  in_yumi_o,
  in_v_o,
  in_data_o,
  in_yumi_i,
  out_me_v_i,
  out_me_data_i,
  out_me_ready_o,
  out_me_v_o,
  out_me_data_o,
  out_me_ready_i
);

  input [3:0] channel_active_i;
  input [3:0] in_v_i;
  input [63:0] in_data_i;
  output [3:0] in_yumi_o;
  output [3:0] in_v_o;
  output [63:0] in_data_o;
  input [3:0] in_yumi_i;
  input [3:0] out_me_v_i;
  input [63:0] out_me_data_i;
  output [3:0] out_me_ready_o;
  output [3:0] out_me_v_o;
  output [63:0] out_me_data_o;
  input [3:0] out_me_ready_i;
  input clk_i;
  input reset_i;
  input calibration_done_i;
  wire [3:0] in_yumi_o,in_v_o,out_me_ready_o,out_me_v_o;
  wire [63:0] in_data_o,out_me_data_o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,in_data_i_3__15_,in_data_i_3__14_,
  in_data_i_3__13_,in_data_i_3__12_,in_data_i_3__11_,in_data_i_3__10_,in_data_i_3__9_,
  in_data_i_3__8_,in_data_i_3__7_,in_data_i_3__6_,in_data_i_3__5_,in_data_i_3__4_,
  in_data_i_3__3_,in_data_i_3__2_,in_data_i_3__1_,in_data_i_3__0_,
  out_me_data_i_0__15_,out_me_data_i_0__14_,out_me_data_i_0__13_,out_me_data_i_0__12_,
  out_me_data_i_0__11_,out_me_data_i_0__10_,out_me_data_i_0__9_,out_me_data_i_0__8_,
  out_me_data_i_0__7_,out_me_data_i_0__6_,out_me_data_i_0__5_,out_me_data_i_0__4_,
  out_me_data_i_0__3_,out_me_data_i_0__2_,out_me_data_i_0__1_,out_me_data_i_0__0_,
  bk_dpath_sel_r_2,N12,N13,N14,N15,\sbox_0_.fi1hot.fwd_sel_one_hot_r_0__3_ ,
  \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__2_ ,\sbox_0_.fi1hot.fwd_sel_one_hot_r_0__1_ ,
  \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__0_ ,N16,N17,N18,N19,N20,N21,N22,N23,N24,N25,N26,N27,N28,N29,
  N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,N41,
  \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__3_ ,\sbox_1_.fi1hot.fwd_sel_one_hot_r_1__2_ ,
  \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__1_ ,\sbox_1_.fi1hot.fwd_sel_one_hot_r_1__0_ ,N42,N43,N44,N45,N46,N47,N48,
  N49,N50,N51,N52,N53,N54,N55,N56,N57,N58,N59,N60,N61,N62,N63,
  \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__3_ ,\sbox_2_.fi1hot.fwd_sel_one_hot_r_2__2_ ,
  \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__1_ ,\sbox_2_.fi1hot.fwd_sel_one_hot_r_2__0_ ,N64,N65,N66,N67,
  N68,N69,N70,N71,N72,N73,N74,N75,N76,N77,N78,N79,N80,N81,N82,N83,N84,N85,
  \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__3_ ,\sbox_3_.fi1hot.fwd_sel_one_hot_r_3__2_ ,
  \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__1_ ,\sbox_3_.fi1hot.fwd_sel_one_hot_r_3__0_ ,N86,
  N87,N88,N89,N90,N91,N92,N93,N94,N95,N96,N97,N98,N99,N100,N101,N102,N103,N104,
  N105,N106,N107,N108,N109,N110,N111,N112,N113,N114,N115,N116,N117,N118,N119,N120,
  N121,N122,N123,N124,N125,N126,N127,N128,N129,N130,N131;
  wire [7:0] fwd_sel,fwd_dpath_sel,bk_sel,bk_dpath_sel,fwd_sel_r,bk_sel_r;
  wire [4:0] fwd_dpath_sel_r;
  wire [7:4] bk_dpath_sel_r;
  reg fwd_sel_r_7_sv2v_reg,fwd_sel_r_6_sv2v_reg,fwd_sel_r_5_sv2v_reg,
  fwd_sel_r_4_sv2v_reg,fwd_sel_r_3_sv2v_reg,fwd_sel_r_2_sv2v_reg,fwd_sel_r_1_sv2v_reg,
  fwd_sel_r_0_sv2v_reg,fwd_dpath_sel_r_4_sv2v_reg,fwd_dpath_sel_r_3_sv2v_reg,
  fwd_dpath_sel_r_2_sv2v_reg,fwd_dpath_sel_r_1_sv2v_reg,fwd_dpath_sel_r_0_sv2v_reg,
  bk_sel_r_7_sv2v_reg,bk_sel_r_6_sv2v_reg,bk_sel_r_5_sv2v_reg,bk_sel_r_4_sv2v_reg,
  bk_sel_r_3_sv2v_reg,bk_sel_r_2_sv2v_reg,bk_sel_r_1_sv2v_reg,bk_sel_r_0_sv2v_reg,
  bk_dpath_sel_r_7_sv2v_reg,bk_dpath_sel_r_6_sv2v_reg,bk_dpath_sel_r_5_sv2v_reg,
  bk_dpath_sel_r_4_sv2v_reg,bk_dpath_sel_r_2_sv2v_reg,
  \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__3__sv2v_reg ,\sbox_0_.fi1hot.fwd_sel_one_hot_r_0__2__sv2v_reg ,
  \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__1__sv2v_reg ,\sbox_0_.fi1hot.fwd_sel_one_hot_r_0__0__sv2v_reg ,
  \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__3__sv2v_reg ,
  \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__2__sv2v_reg ,\sbox_1_.fi1hot.fwd_sel_one_hot_r_1__1__sv2v_reg ,
  \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__0__sv2v_reg ,
  \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__3__sv2v_reg ,\sbox_2_.fi1hot.fwd_sel_one_hot_r_2__2__sv2v_reg ,
  \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__1__sv2v_reg ,\sbox_2_.fi1hot.fwd_sel_one_hot_r_2__0__sv2v_reg ,
  \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__3__sv2v_reg ,
  \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__2__sv2v_reg ,\sbox_3_.fi1hot.fwd_sel_one_hot_r_3__1__sv2v_reg ,
  \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__0__sv2v_reg ;
  assign fwd_sel_r[7] = fwd_sel_r_7_sv2v_reg;
  assign fwd_sel_r[6] = fwd_sel_r_6_sv2v_reg;
  assign fwd_sel_r[5] = fwd_sel_r_5_sv2v_reg;
  assign fwd_sel_r[4] = fwd_sel_r_4_sv2v_reg;
  assign fwd_sel_r[3] = fwd_sel_r_3_sv2v_reg;
  assign fwd_sel_r[2] = fwd_sel_r_2_sv2v_reg;
  assign fwd_sel_r[1] = fwd_sel_r_1_sv2v_reg;
  assign fwd_sel_r[0] = fwd_sel_r_0_sv2v_reg;
  assign fwd_dpath_sel_r[4] = fwd_dpath_sel_r_4_sv2v_reg;
  assign fwd_dpath_sel_r[3] = fwd_dpath_sel_r_3_sv2v_reg;
  assign fwd_dpath_sel_r[2] = fwd_dpath_sel_r_2_sv2v_reg;
  assign fwd_dpath_sel_r[1] = fwd_dpath_sel_r_1_sv2v_reg;
  assign fwd_dpath_sel_r[0] = fwd_dpath_sel_r_0_sv2v_reg;
  assign bk_sel_r[7] = bk_sel_r_7_sv2v_reg;
  assign bk_sel_r[6] = bk_sel_r_6_sv2v_reg;
  assign bk_sel_r[5] = bk_sel_r_5_sv2v_reg;
  assign bk_sel_r[4] = bk_sel_r_4_sv2v_reg;
  assign bk_sel_r[3] = bk_sel_r_3_sv2v_reg;
  assign bk_sel_r[2] = bk_sel_r_2_sv2v_reg;
  assign bk_sel_r[1] = bk_sel_r_1_sv2v_reg;
  assign bk_sel_r[0] = bk_sel_r_0_sv2v_reg;
  assign bk_dpath_sel_r[7] = bk_dpath_sel_r_7_sv2v_reg;
  assign bk_dpath_sel_r[6] = bk_dpath_sel_r_6_sv2v_reg;
  assign bk_dpath_sel_r[5] = bk_dpath_sel_r_5_sv2v_reg;
  assign bk_dpath_sel_r[4] = bk_dpath_sel_r_4_sv2v_reg;
  assign bk_dpath_sel_r_2 = bk_dpath_sel_r_2_sv2v_reg;
  assign \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__3_  = \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__3__sv2v_reg ;
  assign \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__2_  = \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__2__sv2v_reg ;
  assign \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__1_  = \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__1__sv2v_reg ;
  assign \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__0_  = \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__0__sv2v_reg ;
  assign \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__3_  = \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__3__sv2v_reg ;
  assign \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__2_  = \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__2__sv2v_reg ;
  assign \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__1_  = \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__1__sv2v_reg ;
  assign \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__0_  = \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__0__sv2v_reg ;
  assign \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__3_  = \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__3__sv2v_reg ;
  assign \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__2_  = \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__2__sv2v_reg ;
  assign \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__1_  = \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__1__sv2v_reg ;
  assign \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__0_  = \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__0__sv2v_reg ;
  assign \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__3_  = \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__3__sv2v_reg ;
  assign \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__2_  = \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__2__sv2v_reg ;
  assign \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__1_  = \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__1__sv2v_reg ;
  assign \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__0_  = \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__0__sv2v_reg ;
  assign in_data_i_3__15_ = in_data_i[63];
  assign in_data_o[63] = in_data_i_3__15_;
  assign in_data_i_3__14_ = in_data_i[62];
  assign in_data_o[62] = in_data_i_3__14_;
  assign in_data_i_3__13_ = in_data_i[61];
  assign in_data_o[61] = in_data_i_3__13_;
  assign in_data_i_3__12_ = in_data_i[60];
  assign in_data_o[60] = in_data_i_3__12_;
  assign in_data_i_3__11_ = in_data_i[59];
  assign in_data_o[59] = in_data_i_3__11_;
  assign in_data_i_3__10_ = in_data_i[58];
  assign in_data_o[58] = in_data_i_3__10_;
  assign in_data_i_3__9_ = in_data_i[57];
  assign in_data_o[57] = in_data_i_3__9_;
  assign in_data_i_3__8_ = in_data_i[56];
  assign in_data_o[56] = in_data_i_3__8_;
  assign in_data_i_3__7_ = in_data_i[55];
  assign in_data_o[55] = in_data_i_3__7_;
  assign in_data_i_3__6_ = in_data_i[54];
  assign in_data_o[54] = in_data_i_3__6_;
  assign in_data_i_3__5_ = in_data_i[53];
  assign in_data_o[53] = in_data_i_3__5_;
  assign in_data_i_3__4_ = in_data_i[52];
  assign in_data_o[52] = in_data_i_3__4_;
  assign in_data_i_3__3_ = in_data_i[51];
  assign in_data_o[51] = in_data_i_3__3_;
  assign in_data_i_3__2_ = in_data_i[50];
  assign in_data_o[50] = in_data_i_3__2_;
  assign in_data_i_3__1_ = in_data_i[49];
  assign in_data_o[49] = in_data_i_3__1_;
  assign in_data_i_3__0_ = in_data_i[48];
  assign in_data_o[48] = in_data_i_3__0_;
  assign out_me_data_i_0__15_ = out_me_data_i[15];
  assign out_me_data_o[15] = out_me_data_i_0__15_;
  assign out_me_data_i_0__14_ = out_me_data_i[14];
  assign out_me_data_o[14] = out_me_data_i_0__14_;
  assign out_me_data_i_0__13_ = out_me_data_i[13];
  assign out_me_data_o[13] = out_me_data_i_0__13_;
  assign out_me_data_i_0__12_ = out_me_data_i[12];
  assign out_me_data_o[12] = out_me_data_i_0__12_;
  assign out_me_data_i_0__11_ = out_me_data_i[11];
  assign out_me_data_o[11] = out_me_data_i_0__11_;
  assign out_me_data_i_0__10_ = out_me_data_i[10];
  assign out_me_data_o[10] = out_me_data_i_0__10_;
  assign out_me_data_i_0__9_ = out_me_data_i[9];
  assign out_me_data_o[9] = out_me_data_i_0__9_;
  assign out_me_data_i_0__8_ = out_me_data_i[8];
  assign out_me_data_o[8] = out_me_data_i_0__8_;
  assign out_me_data_i_0__7_ = out_me_data_i[7];
  assign out_me_data_o[7] = out_me_data_i_0__7_;
  assign out_me_data_i_0__6_ = out_me_data_i[6];
  assign out_me_data_o[6] = out_me_data_i_0__6_;
  assign out_me_data_i_0__5_ = out_me_data_i[5];
  assign out_me_data_o[5] = out_me_data_i_0__5_;
  assign out_me_data_i_0__4_ = out_me_data_i[4];
  assign out_me_data_o[4] = out_me_data_i_0__4_;
  assign out_me_data_i_0__3_ = out_me_data_i[3];
  assign out_me_data_o[3] = out_me_data_i_0__3_;
  assign out_me_data_i_0__2_ = out_me_data_i[2];
  assign out_me_data_o[2] = out_me_data_i_0__2_;
  assign out_me_data_i_0__1_ = out_me_data_i[1];
  assign out_me_data_o[1] = out_me_data_i_0__1_;
  assign out_me_data_i_0__0_ = out_me_data_i[0];
  assign out_me_data_o[0] = out_me_data_i_0__0_;

  bsg_scatter_gather_vec_size_lp4
  bsg
  (
    .vec_i(channel_active_i),
    .fwd_o(fwd_sel),
    .fwd_datapath_o(fwd_dpath_sel),
    .bk_o(bk_sel),
    .bk_datapath_o(bk_dpath_sel)
  );

  assign in_yumi_o[0] = (N18)? in_yumi_i[0] : 
                        (N20)? in_yumi_i[1] : 
                        (N19)? in_yumi_i[2] : 
                        (N21)? in_yumi_i[3] : 1'b0;
  assign in_data_o[15] = (N24)? in_data_i[15] : 
                         (N26)? in_data_i[31] : 
                         (N25)? in_data_i[47] : 
                         (N27)? in_data_i_3__15_ : 1'b0;
  assign in_data_o[14] = (N24)? in_data_i[14] : 
                         (N26)? in_data_i[30] : 
                         (N25)? in_data_i[46] : 
                         (N27)? in_data_i_3__14_ : 1'b0;
  assign in_data_o[13] = (N24)? in_data_i[13] : 
                         (N26)? in_data_i[29] : 
                         (N25)? in_data_i[45] : 
                         (N27)? in_data_i_3__13_ : 1'b0;
  assign in_data_o[12] = (N24)? in_data_i[12] : 
                         (N26)? in_data_i[28] : 
                         (N25)? in_data_i[44] : 
                         (N27)? in_data_i_3__12_ : 1'b0;
  assign in_data_o[11] = (N24)? in_data_i[11] : 
                         (N26)? in_data_i[27] : 
                         (N25)? in_data_i[43] : 
                         (N27)? in_data_i_3__11_ : 1'b0;
  assign in_data_o[10] = (N24)? in_data_i[10] : 
                         (N26)? in_data_i[26] : 
                         (N25)? in_data_i[42] : 
                         (N27)? in_data_i_3__10_ : 1'b0;
  assign in_data_o[9] = (N24)? in_data_i[9] : 
                        (N26)? in_data_i[25] : 
                        (N25)? in_data_i[41] : 
                        (N27)? in_data_i_3__9_ : 1'b0;
  assign in_data_o[8] = (N24)? in_data_i[8] : 
                        (N26)? in_data_i[24] : 
                        (N25)? in_data_i[40] : 
                        (N27)? in_data_i_3__8_ : 1'b0;
  assign in_data_o[7] = (N24)? in_data_i[7] : 
                        (N26)? in_data_i[23] : 
                        (N25)? in_data_i[39] : 
                        (N27)? in_data_i_3__7_ : 1'b0;
  assign in_data_o[6] = (N24)? in_data_i[6] : 
                        (N26)? in_data_i[22] : 
                        (N25)? in_data_i[38] : 
                        (N27)? in_data_i_3__6_ : 1'b0;
  assign in_data_o[5] = (N24)? in_data_i[5] : 
                        (N26)? in_data_i[21] : 
                        (N25)? in_data_i[37] : 
                        (N27)? in_data_i_3__5_ : 1'b0;
  assign in_data_o[4] = (N24)? in_data_i[4] : 
                        (N26)? in_data_i[20] : 
                        (N25)? in_data_i[36] : 
                        (N27)? in_data_i_3__4_ : 1'b0;
  assign in_data_o[3] = (N24)? in_data_i[3] : 
                        (N26)? in_data_i[19] : 
                        (N25)? in_data_i[35] : 
                        (N27)? in_data_i_3__3_ : 1'b0;
  assign in_data_o[2] = (N24)? in_data_i[2] : 
                        (N26)? in_data_i[18] : 
                        (N25)? in_data_i[34] : 
                        (N27)? in_data_i_3__2_ : 1'b0;
  assign in_data_o[1] = (N24)? in_data_i[1] : 
                        (N26)? in_data_i[17] : 
                        (N25)? in_data_i[33] : 
                        (N27)? in_data_i_3__1_ : 1'b0;
  assign in_data_o[0] = (N24)? in_data_i[0] : 
                        (N26)? in_data_i[16] : 
                        (N25)? in_data_i[32] : 
                        (N27)? in_data_i_3__0_ : 1'b0;
  assign out_me_v_o[0] = (N28)? out_me_v_i[0] : 
                         (N30)? out_me_v_i[1] : 
                         (N29)? out_me_v_i[2] : 
                         (N31)? out_me_v_i[3] : 1'b0;
  assign out_me_ready_o[0] = (N34)? out_me_ready_i[0] : 
                             (N36)? out_me_ready_i[1] : 
                             (N35)? out_me_ready_i[2] : 
                             (N37)? out_me_ready_i[3] : 1'b0;
  assign in_yumi_o[1] = (N44)? in_yumi_i[0] : 
                        (N46)? in_yumi_i[1] : 
                        (N45)? in_yumi_i[2] : 
                        (N47)? in_yumi_i[3] : 1'b0;
  assign out_me_v_o[1] = (N49)? out_me_v_i[0] : 
                         (N51)? out_me_v_i[1] : 
                         (N50)? out_me_v_i[2] : 
                         (N52)? out_me_v_i[3] : 1'b0;
  assign out_me_ready_o[1] = (N55)? out_me_ready_i[0] : 
                             (N57)? out_me_ready_i[1] : 
                             (N56)? out_me_ready_i[2] : 
                             (N58)? out_me_ready_i[3] : 1'b0;
  assign out_me_data_o[31] = (N59)? out_me_data_i_0__15_ : 
                             (N0)? out_me_data_i[31] : 1'b0;
  assign N0 = bk_dpath_sel_r_2;
  assign out_me_data_o[30] = (N59)? out_me_data_i_0__14_ : 
                             (N0)? out_me_data_i[30] : 1'b0;
  assign out_me_data_o[29] = (N59)? out_me_data_i_0__13_ : 
                             (N0)? out_me_data_i[29] : 1'b0;
  assign out_me_data_o[28] = (N59)? out_me_data_i_0__12_ : 
                             (N0)? out_me_data_i[28] : 1'b0;
  assign out_me_data_o[27] = (N59)? out_me_data_i_0__11_ : 
                             (N0)? out_me_data_i[27] : 1'b0;
  assign out_me_data_o[26] = (N59)? out_me_data_i_0__10_ : 
                             (N0)? out_me_data_i[26] : 1'b0;
  assign out_me_data_o[25] = (N59)? out_me_data_i_0__9_ : 
                             (N0)? out_me_data_i[25] : 1'b0;
  assign out_me_data_o[24] = (N59)? out_me_data_i_0__8_ : 
                             (N0)? out_me_data_i[24] : 1'b0;
  assign out_me_data_o[23] = (N59)? out_me_data_i_0__7_ : 
                             (N0)? out_me_data_i[23] : 1'b0;
  assign out_me_data_o[22] = (N59)? out_me_data_i_0__6_ : 
                             (N0)? out_me_data_i[22] : 1'b0;
  assign out_me_data_o[21] = (N59)? out_me_data_i_0__5_ : 
                             (N0)? out_me_data_i[21] : 1'b0;
  assign out_me_data_o[20] = (N59)? out_me_data_i_0__4_ : 
                             (N0)? out_me_data_i[20] : 1'b0;
  assign out_me_data_o[19] = (N59)? out_me_data_i_0__3_ : 
                             (N0)? out_me_data_i[19] : 1'b0;
  assign out_me_data_o[18] = (N59)? out_me_data_i_0__2_ : 
                             (N0)? out_me_data_i[18] : 1'b0;
  assign out_me_data_o[17] = (N59)? out_me_data_i_0__1_ : 
                             (N0)? out_me_data_i[17] : 1'b0;
  assign out_me_data_o[16] = (N59)? out_me_data_i_0__0_ : 
                             (N0)? out_me_data_i[16] : 1'b0;
  assign in_yumi_o[2] = (N66)? in_yumi_i[0] : 
                        (N68)? in_yumi_i[1] : 
                        (N67)? in_yumi_i[2] : 
                        (N69)? in_yumi_i[3] : 1'b0;
  assign in_data_o[47] = (N70)? in_data_i[47] : 
                         (N1)? in_data_i_3__15_ : 1'b0;
  assign N1 = fwd_dpath_sel_r[4];
  assign in_data_o[46] = (N70)? in_data_i[46] : 
                         (N1)? in_data_i_3__14_ : 1'b0;
  assign in_data_o[45] = (N70)? in_data_i[45] : 
                         (N1)? in_data_i_3__13_ : 1'b0;
  assign in_data_o[44] = (N70)? in_data_i[44] : 
                         (N1)? in_data_i_3__12_ : 1'b0;
  assign in_data_o[43] = (N70)? in_data_i[43] : 
                         (N1)? in_data_i_3__11_ : 1'b0;
  assign in_data_o[42] = (N70)? in_data_i[42] : 
                         (N1)? in_data_i_3__10_ : 1'b0;
  assign in_data_o[41] = (N70)? in_data_i[41] : 
                         (N1)? in_data_i_3__9_ : 1'b0;
  assign in_data_o[40] = (N70)? in_data_i[40] : 
                         (N1)? in_data_i_3__8_ : 1'b0;
  assign in_data_o[39] = (N70)? in_data_i[39] : 
                         (N1)? in_data_i_3__7_ : 1'b0;
  assign in_data_o[38] = (N70)? in_data_i[38] : 
                         (N1)? in_data_i_3__6_ : 1'b0;
  assign in_data_o[37] = (N70)? in_data_i[37] : 
                         (N1)? in_data_i_3__5_ : 1'b0;
  assign in_data_o[36] = (N70)? in_data_i[36] : 
                         (N1)? in_data_i_3__4_ : 1'b0;
  assign in_data_o[35] = (N70)? in_data_i[35] : 
                         (N1)? in_data_i_3__3_ : 1'b0;
  assign in_data_o[34] = (N70)? in_data_i[34] : 
                         (N1)? in_data_i_3__2_ : 1'b0;
  assign in_data_o[33] = (N70)? in_data_i[33] : 
                         (N1)? in_data_i_3__1_ : 1'b0;
  assign in_data_o[32] = (N70)? in_data_i[32] : 
                         (N1)? in_data_i_3__0_ : 1'b0;
  assign out_me_v_o[2] = (N71)? out_me_v_i[0] : 
                         (N73)? out_me_v_i[1] : 
                         (N72)? out_me_v_i[2] : 
                         (N74)? out_me_v_i[3] : 1'b0;
  assign out_me_ready_o[2] = (N77)? out_me_ready_i[0] : 
                             (N79)? out_me_ready_i[1] : 
                             (N78)? out_me_ready_i[2] : 
                             (N80)? out_me_ready_i[3] : 1'b0;
  assign in_yumi_o[3] = (N88)? in_yumi_i[0] : 
                        (N90)? in_yumi_i[1] : 
                        (N89)? in_yumi_i[2] : 
                        (N91)? in_yumi_i[3] : 1'b0;
  assign out_me_v_o[3] = (N92)? out_me_v_i[0] : 
                         (N94)? out_me_v_i[1] : 
                         (N93)? out_me_v_i[2] : 
                         (N95)? out_me_v_i[3] : 1'b0;
  assign out_me_ready_o[3] = (N98)? out_me_ready_i[0] : 
                             (N100)? out_me_ready_i[1] : 
                             (N99)? out_me_ready_i[2] : 
                             (N101)? out_me_ready_i[3] : 1'b0;
  assign out_me_data_o[63] = (N104)? out_me_data_i_0__15_ : 
                             (N106)? out_me_data_i[31] : 
                             (N105)? out_me_data_i[47] : 
                             (N107)? out_me_data_i[63] : 1'b0;
  assign out_me_data_o[62] = (N104)? out_me_data_i_0__14_ : 
                             (N106)? out_me_data_i[30] : 
                             (N105)? out_me_data_i[46] : 
                             (N107)? out_me_data_i[62] : 1'b0;
  assign out_me_data_o[61] = (N104)? out_me_data_i_0__13_ : 
                             (N106)? out_me_data_i[29] : 
                             (N105)? out_me_data_i[45] : 
                             (N107)? out_me_data_i[61] : 1'b0;
  assign out_me_data_o[60] = (N104)? out_me_data_i_0__12_ : 
                             (N106)? out_me_data_i[28] : 
                             (N105)? out_me_data_i[44] : 
                             (N107)? out_me_data_i[60] : 1'b0;
  assign out_me_data_o[59] = (N104)? out_me_data_i_0__11_ : 
                             (N106)? out_me_data_i[27] : 
                             (N105)? out_me_data_i[43] : 
                             (N107)? out_me_data_i[59] : 1'b0;
  assign out_me_data_o[58] = (N104)? out_me_data_i_0__10_ : 
                             (N106)? out_me_data_i[26] : 
                             (N105)? out_me_data_i[42] : 
                             (N107)? out_me_data_i[58] : 1'b0;
  assign out_me_data_o[57] = (N104)? out_me_data_i_0__9_ : 
                             (N106)? out_me_data_i[25] : 
                             (N105)? out_me_data_i[41] : 
                             (N107)? out_me_data_i[57] : 1'b0;
  assign out_me_data_o[56] = (N104)? out_me_data_i_0__8_ : 
                             (N106)? out_me_data_i[24] : 
                             (N105)? out_me_data_i[40] : 
                             (N107)? out_me_data_i[56] : 1'b0;
  assign out_me_data_o[55] = (N104)? out_me_data_i_0__7_ : 
                             (N106)? out_me_data_i[23] : 
                             (N105)? out_me_data_i[39] : 
                             (N107)? out_me_data_i[55] : 1'b0;
  assign out_me_data_o[54] = (N104)? out_me_data_i_0__6_ : 
                             (N106)? out_me_data_i[22] : 
                             (N105)? out_me_data_i[38] : 
                             (N107)? out_me_data_i[54] : 1'b0;
  assign out_me_data_o[53] = (N104)? out_me_data_i_0__5_ : 
                             (N106)? out_me_data_i[21] : 
                             (N105)? out_me_data_i[37] : 
                             (N107)? out_me_data_i[53] : 1'b0;
  assign out_me_data_o[52] = (N104)? out_me_data_i_0__4_ : 
                             (N106)? out_me_data_i[20] : 
                             (N105)? out_me_data_i[36] : 
                             (N107)? out_me_data_i[52] : 1'b0;
  assign out_me_data_o[51] = (N104)? out_me_data_i_0__3_ : 
                             (N106)? out_me_data_i[19] : 
                             (N105)? out_me_data_i[35] : 
                             (N107)? out_me_data_i[51] : 1'b0;
  assign out_me_data_o[50] = (N104)? out_me_data_i_0__2_ : 
                             (N106)? out_me_data_i[18] : 
                             (N105)? out_me_data_i[34] : 
                             (N107)? out_me_data_i[50] : 1'b0;
  assign out_me_data_o[49] = (N104)? out_me_data_i_0__1_ : 
                             (N106)? out_me_data_i[17] : 
                             (N105)? out_me_data_i[33] : 
                             (N107)? out_me_data_i[49] : 1'b0;
  assign out_me_data_o[48] = (N104)? out_me_data_i_0__0_ : 
                             (N106)? out_me_data_i[16] : 
                             (N105)? out_me_data_i[32] : 
                             (N107)? out_me_data_i[48] : 1'b0;
  assign { N15, N14, N13, N12 } = { 1'b0, 1'b0, 1'b0, 1'b1 } << fwd_sel[1:0];
  assign { N41, N40, N39, N38 } = { 1'b0, 1'b0, 1'b0, 1'b1 } << fwd_sel[3:2];
  assign { N63, N62, N61, N60 } = { 1'b0, 1'b0, 1'b0, 1'b1 } << fwd_sel[5:4];
  assign { N85, N84, N83, N82 } = { 1'b0, 1'b0, 1'b0, 1'b1 } << fwd_sel[7:6];
  assign N48 = N2 & N3;
  assign N2 = ~fwd_dpath_sel_r[2];
  assign N3 = ~fwd_dpath_sel_r[3];
  assign N81 = N4 & N5;
  assign N4 = ~bk_dpath_sel_r[4];
  assign N5 = ~bk_dpath_sel_r[5];
  assign in_data_o[31] = (N6)? in_data_i[31] : 
                         (N7)? in_data_i[47] : 
                         (N8)? in_data_i_3__15_ : 1'b0;
  assign N6 = N48;
  assign N7 = fwd_dpath_sel_r[2];
  assign N8 = fwd_dpath_sel_r[3];
  assign in_data_o[30] = (N6)? in_data_i[30] : 
                         (N7)? in_data_i[46] : 
                         (N8)? in_data_i_3__14_ : 1'b0;
  assign in_data_o[29] = (N6)? in_data_i[29] : 
                         (N7)? in_data_i[45] : 
                         (N8)? in_data_i_3__13_ : 1'b0;
  assign in_data_o[28] = (N6)? in_data_i[28] : 
                         (N7)? in_data_i[44] : 
                         (N8)? in_data_i_3__12_ : 1'b0;
  assign in_data_o[27] = (N6)? in_data_i[27] : 
                         (N7)? in_data_i[43] : 
                         (N8)? in_data_i_3__11_ : 1'b0;
  assign in_data_o[26] = (N6)? in_data_i[26] : 
                         (N7)? in_data_i[42] : 
                         (N8)? in_data_i_3__10_ : 1'b0;
  assign in_data_o[25] = (N6)? in_data_i[25] : 
                         (N7)? in_data_i[41] : 
                         (N8)? in_data_i_3__9_ : 1'b0;
  assign in_data_o[24] = (N6)? in_data_i[24] : 
                         (N7)? in_data_i[40] : 
                         (N8)? in_data_i_3__8_ : 1'b0;
  assign in_data_o[23] = (N6)? in_data_i[23] : 
                         (N7)? in_data_i[39] : 
                         (N8)? in_data_i_3__7_ : 1'b0;
  assign in_data_o[22] = (N6)? in_data_i[22] : 
                         (N7)? in_data_i[38] : 
                         (N8)? in_data_i_3__6_ : 1'b0;
  assign in_data_o[21] = (N6)? in_data_i[21] : 
                         (N7)? in_data_i[37] : 
                         (N8)? in_data_i_3__5_ : 1'b0;
  assign in_data_o[20] = (N6)? in_data_i[20] : 
                         (N7)? in_data_i[36] : 
                         (N8)? in_data_i_3__4_ : 1'b0;
  assign in_data_o[19] = (N6)? in_data_i[19] : 
                         (N7)? in_data_i[35] : 
                         (N8)? in_data_i_3__3_ : 1'b0;
  assign in_data_o[18] = (N6)? in_data_i[18] : 
                         (N7)? in_data_i[34] : 
                         (N8)? in_data_i_3__2_ : 1'b0;
  assign in_data_o[17] = (N6)? in_data_i[17] : 
                         (N7)? in_data_i[33] : 
                         (N8)? in_data_i_3__1_ : 1'b0;
  assign in_data_o[16] = (N6)? in_data_i[16] : 
                         (N7)? in_data_i[32] : 
                         (N8)? in_data_i_3__0_ : 1'b0;
  assign out_me_data_o[47] = (N9)? out_me_data_i_0__15_ : 
                             (N10)? out_me_data_i[31] : 
                             (N11)? out_me_data_i[47] : 1'b0;
  assign N9 = N81;
  assign N10 = bk_dpath_sel_r[4];
  assign N11 = bk_dpath_sel_r[5];
  assign out_me_data_o[46] = (N9)? out_me_data_i_0__14_ : 
                             (N10)? out_me_data_i[30] : 
                             (N11)? out_me_data_i[46] : 1'b0;
  assign out_me_data_o[45] = (N9)? out_me_data_i_0__13_ : 
                             (N10)? out_me_data_i[29] : 
                             (N11)? out_me_data_i[45] : 1'b0;
  assign out_me_data_o[44] = (N9)? out_me_data_i_0__12_ : 
                             (N10)? out_me_data_i[28] : 
                             (N11)? out_me_data_i[44] : 1'b0;
  assign out_me_data_o[43] = (N9)? out_me_data_i_0__11_ : 
                             (N10)? out_me_data_i[27] : 
                             (N11)? out_me_data_i[43] : 1'b0;
  assign out_me_data_o[42] = (N9)? out_me_data_i_0__10_ : 
                             (N10)? out_me_data_i[26] : 
                             (N11)? out_me_data_i[42] : 1'b0;
  assign out_me_data_o[41] = (N9)? out_me_data_i_0__9_ : 
                             (N10)? out_me_data_i[25] : 
                             (N11)? out_me_data_i[41] : 1'b0;
  assign out_me_data_o[40] = (N9)? out_me_data_i_0__8_ : 
                             (N10)? out_me_data_i[24] : 
                             (N11)? out_me_data_i[40] : 1'b0;
  assign out_me_data_o[39] = (N9)? out_me_data_i_0__7_ : 
                             (N10)? out_me_data_i[23] : 
                             (N11)? out_me_data_i[39] : 1'b0;
  assign out_me_data_o[38] = (N9)? out_me_data_i_0__6_ : 
                             (N10)? out_me_data_i[22] : 
                             (N11)? out_me_data_i[38] : 1'b0;
  assign out_me_data_o[37] = (N9)? out_me_data_i_0__5_ : 
                             (N10)? out_me_data_i[21] : 
                             (N11)? out_me_data_i[37] : 1'b0;
  assign out_me_data_o[36] = (N9)? out_me_data_i_0__4_ : 
                             (N10)? out_me_data_i[20] : 
                             (N11)? out_me_data_i[36] : 1'b0;
  assign out_me_data_o[35] = (N9)? out_me_data_i_0__3_ : 
                             (N10)? out_me_data_i[19] : 
                             (N11)? out_me_data_i[35] : 1'b0;
  assign out_me_data_o[34] = (N9)? out_me_data_i_0__2_ : 
                             (N10)? out_me_data_i[18] : 
                             (N11)? out_me_data_i[34] : 1'b0;
  assign out_me_data_o[33] = (N9)? out_me_data_i_0__1_ : 
                             (N10)? out_me_data_i[17] : 
                             (N11)? out_me_data_i[33] : 1'b0;
  assign out_me_data_o[32] = (N9)? out_me_data_i_0__0_ : 
                             (N10)? out_me_data_i[16] : 
                             (N11)? out_me_data_i[32] : 1'b0;
  assign in_v_o[0] = N112 | N113;
  assign N112 = N110 | N111;
  assign N110 = N108 | N109;
  assign N108 = in_v_i[3] & \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__3_ ;
  assign N109 = in_v_i[2] & \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__2_ ;
  assign N111 = in_v_i[1] & \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__1_ ;
  assign N113 = in_v_i[0] & \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__0_ ;
  assign N16 = ~bk_sel_r[0];
  assign N17 = ~bk_sel_r[1];
  assign N18 = N16 & N17;
  assign N19 = N16 & bk_sel_r[1];
  assign N20 = bk_sel_r[0] & N17;
  assign N21 = bk_sel_r[0] & bk_sel_r[1];
  assign N22 = ~fwd_dpath_sel_r[0];
  assign N23 = ~fwd_dpath_sel_r[1];
  assign N24 = N22 & N23;
  assign N25 = N22 & fwd_dpath_sel_r[1];
  assign N26 = fwd_dpath_sel_r[0] & N23;
  assign N27 = fwd_dpath_sel_r[0] & fwd_dpath_sel_r[1];
  assign N28 = N16 & N17;
  assign N29 = N16 & bk_sel_r[1];
  assign N30 = bk_sel_r[0] & N17;
  assign N31 = bk_sel_r[0] & bk_sel_r[1];
  assign N32 = ~fwd_sel_r[0];
  assign N33 = ~fwd_sel_r[1];
  assign N34 = N32 & N33;
  assign N35 = N32 & fwd_sel_r[1];
  assign N36 = fwd_sel_r[0] & N33;
  assign N37 = fwd_sel_r[0] & fwd_sel_r[1];
  assign in_v_o[1] = N118 | N119;
  assign N118 = N116 | N117;
  assign N116 = N114 | N115;
  assign N114 = in_v_i[3] & \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__3_ ;
  assign N115 = in_v_i[2] & \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__2_ ;
  assign N117 = in_v_i[1] & \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__1_ ;
  assign N119 = in_v_i[0] & \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__0_ ;
  assign N42 = ~bk_sel_r[2];
  assign N43 = ~bk_sel_r[3];
  assign N44 = N42 & N43;
  assign N45 = N42 & bk_sel_r[3];
  assign N46 = bk_sel_r[2] & N43;
  assign N47 = bk_sel_r[2] & bk_sel_r[3];
  assign N49 = N42 & N43;
  assign N50 = N42 & bk_sel_r[3];
  assign N51 = bk_sel_r[2] & N43;
  assign N52 = bk_sel_r[2] & bk_sel_r[3];
  assign N53 = ~fwd_sel_r[2];
  assign N54 = ~fwd_sel_r[3];
  assign N55 = N53 & N54;
  assign N56 = N53 & fwd_sel_r[3];
  assign N57 = fwd_sel_r[2] & N54;
  assign N58 = fwd_sel_r[2] & fwd_sel_r[3];
  assign N59 = ~bk_dpath_sel_r_2;
  assign in_v_o[2] = N124 | N125;
  assign N124 = N122 | N123;
  assign N122 = N120 | N121;
  assign N120 = in_v_i[3] & \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__3_ ;
  assign N121 = in_v_i[2] & \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__2_ ;
  assign N123 = in_v_i[1] & \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__1_ ;
  assign N125 = in_v_i[0] & \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__0_ ;
  assign N64 = ~bk_sel_r[4];
  assign N65 = ~bk_sel_r[5];
  assign N66 = N64 & N65;
  assign N67 = N64 & bk_sel_r[5];
  assign N68 = bk_sel_r[4] & N65;
  assign N69 = bk_sel_r[4] & bk_sel_r[5];
  assign N70 = ~fwd_dpath_sel_r[4];
  assign N71 = N64 & N65;
  assign N72 = N64 & bk_sel_r[5];
  assign N73 = bk_sel_r[4] & N65;
  assign N74 = bk_sel_r[4] & bk_sel_r[5];
  assign N75 = ~fwd_sel_r[4];
  assign N76 = ~fwd_sel_r[5];
  assign N77 = N75 & N76;
  assign N78 = N75 & fwd_sel_r[5];
  assign N79 = fwd_sel_r[4] & N76;
  assign N80 = fwd_sel_r[4] & fwd_sel_r[5];
  assign in_v_o[3] = N130 | N131;
  assign N130 = N128 | N129;
  assign N128 = N126 | N127;
  assign N126 = in_v_i[3] & \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__3_ ;
  assign N127 = in_v_i[2] & \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__2_ ;
  assign N129 = in_v_i[1] & \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__1_ ;
  assign N131 = in_v_i[0] & \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__0_ ;
  assign N86 = ~bk_sel_r[6];
  assign N87 = ~bk_sel_r[7];
  assign N88 = N86 & N87;
  assign N89 = N86 & bk_sel_r[7];
  assign N90 = bk_sel_r[6] & N87;
  assign N91 = bk_sel_r[6] & bk_sel_r[7];
  assign N92 = N86 & N87;
  assign N93 = N86 & bk_sel_r[7];
  assign N94 = bk_sel_r[6] & N87;
  assign N95 = bk_sel_r[6] & bk_sel_r[7];
  assign N96 = ~fwd_sel_r[6];
  assign N97 = ~fwd_sel_r[7];
  assign N98 = N96 & N97;
  assign N99 = N96 & fwd_sel_r[7];
  assign N100 = fwd_sel_r[6] & N97;
  assign N101 = fwd_sel_r[6] & fwd_sel_r[7];
  assign N102 = ~bk_dpath_sel_r[6];
  assign N103 = ~bk_dpath_sel_r[7];
  assign N104 = N102 & N103;
  assign N105 = N102 & bk_dpath_sel_r[7];
  assign N106 = bk_dpath_sel_r[6] & N103;
  assign N107 = bk_dpath_sel_r[6] & bk_dpath_sel_r[7];

  always @(posedge clk_i) begin
    if(1'b1) begin
      fwd_sel_r_7_sv2v_reg <= fwd_sel[7];
      fwd_sel_r_6_sv2v_reg <= fwd_sel[6];
      fwd_sel_r_5_sv2v_reg <= fwd_sel[5];
      fwd_sel_r_4_sv2v_reg <= fwd_sel[4];
      fwd_sel_r_3_sv2v_reg <= fwd_sel[3];
      fwd_sel_r_2_sv2v_reg <= fwd_sel[2];
      fwd_sel_r_1_sv2v_reg <= fwd_sel[1];
      fwd_sel_r_0_sv2v_reg <= fwd_sel[0];
      fwd_dpath_sel_r_4_sv2v_reg <= fwd_dpath_sel[4];
      fwd_dpath_sel_r_3_sv2v_reg <= fwd_dpath_sel[3];
      fwd_dpath_sel_r_2_sv2v_reg <= fwd_dpath_sel[2];
      fwd_dpath_sel_r_1_sv2v_reg <= fwd_dpath_sel[1];
      fwd_dpath_sel_r_0_sv2v_reg <= fwd_dpath_sel[0];
      bk_sel_r_7_sv2v_reg <= bk_sel[7];
      bk_sel_r_6_sv2v_reg <= bk_sel[6];
      bk_sel_r_5_sv2v_reg <= bk_sel[5];
      bk_sel_r_4_sv2v_reg <= bk_sel[4];
      bk_sel_r_3_sv2v_reg <= bk_sel[3];
      bk_sel_r_2_sv2v_reg <= bk_sel[2];
      bk_sel_r_1_sv2v_reg <= bk_sel[1];
      bk_sel_r_0_sv2v_reg <= bk_sel[0];
      bk_dpath_sel_r_7_sv2v_reg <= bk_dpath_sel[7];
      bk_dpath_sel_r_6_sv2v_reg <= bk_dpath_sel[6];
      bk_dpath_sel_r_5_sv2v_reg <= bk_dpath_sel[5];
      bk_dpath_sel_r_4_sv2v_reg <= bk_dpath_sel[4];
      bk_dpath_sel_r_2_sv2v_reg <= bk_dpath_sel[2];
      \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__3__sv2v_reg  <= N15;
      \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__2__sv2v_reg  <= N14;
      \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__1__sv2v_reg  <= N13;
      \sbox_0_.fi1hot.fwd_sel_one_hot_r_0__0__sv2v_reg  <= N12;
      \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__3__sv2v_reg  <= N41;
      \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__2__sv2v_reg  <= N40;
      \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__1__sv2v_reg  <= N39;
      \sbox_1_.fi1hot.fwd_sel_one_hot_r_1__0__sv2v_reg  <= N38;
      \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__3__sv2v_reg  <= N63;
      \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__2__sv2v_reg  <= N62;
      \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__1__sv2v_reg  <= N61;
      \sbox_2_.fi1hot.fwd_sel_one_hot_r_2__0__sv2v_reg  <= N60;
      \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__3__sv2v_reg  <= N85;
      \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__2__sv2v_reg  <= N84;
      \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__1__sv2v_reg  <= N83;
      \sbox_3_.fi1hot.fwd_sel_one_hot_r_3__0__sv2v_reg  <= N82;
    end 
  end


endmodule

