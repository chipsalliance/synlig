

module top
(
  clk_i,
  ready_i,
  unlock_i,
  reqs_i,
  grants_o
);

  input [15:0] reqs_i;
  output [15:0] grants_o;
  input clk_i;
  input ready_i;
  input unlock_i;

  bsg_locking_arb_fixed
  wrapper
  (
    .reqs_i(reqs_i),
    .grants_o(grants_o),
    .clk_i(clk_i),
    .ready_i(ready_i),
    .unlock_i(unlock_i)
  );


endmodule



module bsg_dff_reset_en_width_p16
(
  clk_i,
  reset_i,
  en_i,
  data_i,
  data_o
);

  input [15:0] data_i;
  output [15:0] data_o;
  input clk_i;
  input reset_i;
  input en_i;
  wire [15:0] data_o;
  wire N0,N1,N2;
  reg data_o_15_sv2v_reg,data_o_14_sv2v_reg,data_o_13_sv2v_reg,data_o_12_sv2v_reg,
  data_o_11_sv2v_reg,data_o_10_sv2v_reg,data_o_9_sv2v_reg,data_o_8_sv2v_reg,
  data_o_7_sv2v_reg,data_o_6_sv2v_reg,data_o_5_sv2v_reg,data_o_4_sv2v_reg,data_o_3_sv2v_reg,
  data_o_2_sv2v_reg,data_o_1_sv2v_reg,data_o_0_sv2v_reg;
  assign data_o[15] = data_o_15_sv2v_reg;
  assign data_o[14] = data_o_14_sv2v_reg;
  assign data_o[13] = data_o_13_sv2v_reg;
  assign data_o[12] = data_o_12_sv2v_reg;
  assign data_o[11] = data_o_11_sv2v_reg;
  assign data_o[10] = data_o_10_sv2v_reg;
  assign data_o[9] = data_o_9_sv2v_reg;
  assign data_o[8] = data_o_8_sv2v_reg;
  assign data_o[7] = data_o_7_sv2v_reg;
  assign data_o[6] = data_o_6_sv2v_reg;
  assign data_o[5] = data_o_5_sv2v_reg;
  assign data_o[4] = data_o_4_sv2v_reg;
  assign data_o[3] = data_o_3_sv2v_reg;
  assign data_o[2] = data_o_2_sv2v_reg;
  assign data_o[1] = data_o_1_sv2v_reg;
  assign data_o[0] = data_o_0_sv2v_reg;
  assign N2 = (N0)? 1'b1 : 
              (N1)? 1'b0 : 1'b0;
  assign N0 = en_i;
  assign N1 = ~en_i;

  always @(posedge clk_i) begin
    if(reset_i) begin
      data_o_15_sv2v_reg <= 1'b0;
      data_o_14_sv2v_reg <= 1'b0;
      data_o_13_sv2v_reg <= 1'b0;
      data_o_12_sv2v_reg <= 1'b0;
      data_o_11_sv2v_reg <= 1'b0;
      data_o_10_sv2v_reg <= 1'b0;
      data_o_9_sv2v_reg <= 1'b0;
      data_o_8_sv2v_reg <= 1'b0;
      data_o_7_sv2v_reg <= 1'b0;
      data_o_6_sv2v_reg <= 1'b0;
      data_o_5_sv2v_reg <= 1'b0;
      data_o_4_sv2v_reg <= 1'b0;
      data_o_3_sv2v_reg <= 1'b0;
      data_o_2_sv2v_reg <= 1'b0;
      data_o_1_sv2v_reg <= 1'b0;
      data_o_0_sv2v_reg <= 1'b0;
    end else if(N2) begin
      data_o_15_sv2v_reg <= data_i[15];
      data_o_14_sv2v_reg <= data_i[14];
      data_o_13_sv2v_reg <= data_i[13];
      data_o_12_sv2v_reg <= data_i[12];
      data_o_11_sv2v_reg <= data_i[11];
      data_o_10_sv2v_reg <= data_i[10];
      data_o_9_sv2v_reg <= data_i[9];
      data_o_8_sv2v_reg <= data_i[8];
      data_o_7_sv2v_reg <= data_i[7];
      data_o_6_sv2v_reg <= data_i[6];
      data_o_5_sv2v_reg <= data_i[5];
      data_o_4_sv2v_reg <= data_i[4];
      data_o_3_sv2v_reg <= data_i[3];
      data_o_2_sv2v_reg <= data_i[2];
      data_o_1_sv2v_reg <= data_i[1];
      data_o_0_sv2v_reg <= data_i[0];
    end 
  end


endmodule



module bsg_scan_width_p16_or_p1_lo_to_hi_p0
(
  i,
  o
);

  input [15:0] i;
  output [15:0] o;
  wire [15:0] o;
  wire t_3__15_,t_3__14_,t_3__13_,t_3__12_,t_3__11_,t_3__10_,t_3__9_,t_3__8_,t_3__7_,
  t_3__6_,t_3__5_,t_3__4_,t_3__3_,t_3__2_,t_3__1_,t_3__0_,t_2__15_,t_2__14_,
  t_2__13_,t_2__12_,t_2__11_,t_2__10_,t_2__9_,t_2__8_,t_2__7_,t_2__6_,t_2__5_,t_2__4_,
  t_2__3_,t_2__2_,t_2__1_,t_2__0_,t_1__15_,t_1__14_,t_1__13_,t_1__12_,t_1__11_,
  t_1__10_,t_1__9_,t_1__8_,t_1__7_,t_1__6_,t_1__5_,t_1__4_,t_1__3_,t_1__2_,t_1__1_,
  t_1__0_;
  assign t_1__15_ = i[15] | 1'b0;
  assign t_1__14_ = i[14] | i[15];
  assign t_1__13_ = i[13] | i[14];
  assign t_1__12_ = i[12] | i[13];
  assign t_1__11_ = i[11] | i[12];
  assign t_1__10_ = i[10] | i[11];
  assign t_1__9_ = i[9] | i[10];
  assign t_1__8_ = i[8] | i[9];
  assign t_1__7_ = i[7] | i[8];
  assign t_1__6_ = i[6] | i[7];
  assign t_1__5_ = i[5] | i[6];
  assign t_1__4_ = i[4] | i[5];
  assign t_1__3_ = i[3] | i[4];
  assign t_1__2_ = i[2] | i[3];
  assign t_1__1_ = i[1] | i[2];
  assign t_1__0_ = i[0] | i[1];
  assign t_2__15_ = t_1__15_ | 1'b0;
  assign t_2__14_ = t_1__14_ | 1'b0;
  assign t_2__13_ = t_1__13_ | t_1__15_;
  assign t_2__12_ = t_1__12_ | t_1__14_;
  assign t_2__11_ = t_1__11_ | t_1__13_;
  assign t_2__10_ = t_1__10_ | t_1__12_;
  assign t_2__9_ = t_1__9_ | t_1__11_;
  assign t_2__8_ = t_1__8_ | t_1__10_;
  assign t_2__7_ = t_1__7_ | t_1__9_;
  assign t_2__6_ = t_1__6_ | t_1__8_;
  assign t_2__5_ = t_1__5_ | t_1__7_;
  assign t_2__4_ = t_1__4_ | t_1__6_;
  assign t_2__3_ = t_1__3_ | t_1__5_;
  assign t_2__2_ = t_1__2_ | t_1__4_;
  assign t_2__1_ = t_1__1_ | t_1__3_;
  assign t_2__0_ = t_1__0_ | t_1__2_;
  assign t_3__15_ = t_2__15_ | 1'b0;
  assign t_3__14_ = t_2__14_ | 1'b0;
  assign t_3__13_ = t_2__13_ | 1'b0;
  assign t_3__12_ = t_2__12_ | 1'b0;
  assign t_3__11_ = t_2__11_ | t_2__15_;
  assign t_3__10_ = t_2__10_ | t_2__14_;
  assign t_3__9_ = t_2__9_ | t_2__13_;
  assign t_3__8_ = t_2__8_ | t_2__12_;
  assign t_3__7_ = t_2__7_ | t_2__11_;
  assign t_3__6_ = t_2__6_ | t_2__10_;
  assign t_3__5_ = t_2__5_ | t_2__9_;
  assign t_3__4_ = t_2__4_ | t_2__8_;
  assign t_3__3_ = t_2__3_ | t_2__7_;
  assign t_3__2_ = t_2__2_ | t_2__6_;
  assign t_3__1_ = t_2__1_ | t_2__5_;
  assign t_3__0_ = t_2__0_ | t_2__4_;
  assign o[15] = t_3__15_ | 1'b0;
  assign o[14] = t_3__14_ | 1'b0;
  assign o[13] = t_3__13_ | 1'b0;
  assign o[12] = t_3__12_ | 1'b0;
  assign o[11] = t_3__11_ | 1'b0;
  assign o[10] = t_3__10_ | 1'b0;
  assign o[9] = t_3__9_ | 1'b0;
  assign o[8] = t_3__8_ | 1'b0;
  assign o[7] = t_3__7_ | t_3__15_;
  assign o[6] = t_3__6_ | t_3__14_;
  assign o[5] = t_3__5_ | t_3__13_;
  assign o[4] = t_3__4_ | t_3__12_;
  assign o[3] = t_3__3_ | t_3__11_;
  assign o[2] = t_3__2_ | t_3__10_;
  assign o[1] = t_3__1_ | t_3__9_;
  assign o[0] = t_3__0_ | t_3__8_;

endmodule



module bsg_priority_encode_one_hot_out_width_p16_lo_to_hi_p0
(
  i,
  o,
  v_o
);

  input [15:0] i;
  output [15:0] o;
  output v_o;
  wire [15:0] o;
  wire v_o,N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14;
  wire [14:1] scan_lo;

  bsg_scan_width_p16_or_p1_lo_to_hi_p0
  \nw1.scan 
  (
    .i(i),
    .o({ o[15:15], scan_lo, v_o })
  );

  assign o[14] = scan_lo[14] & N0;
  assign N0 = ~o[15];
  assign o[13] = scan_lo[13] & N1;
  assign N1 = ~scan_lo[14];
  assign o[12] = scan_lo[12] & N2;
  assign N2 = ~scan_lo[13];
  assign o[11] = scan_lo[11] & N3;
  assign N3 = ~scan_lo[12];
  assign o[10] = scan_lo[10] & N4;
  assign N4 = ~scan_lo[11];
  assign o[9] = scan_lo[9] & N5;
  assign N5 = ~scan_lo[10];
  assign o[8] = scan_lo[8] & N6;
  assign N6 = ~scan_lo[9];
  assign o[7] = scan_lo[7] & N7;
  assign N7 = ~scan_lo[8];
  assign o[6] = scan_lo[6] & N8;
  assign N8 = ~scan_lo[7];
  assign o[5] = scan_lo[5] & N9;
  assign N9 = ~scan_lo[6];
  assign o[4] = scan_lo[4] & N10;
  assign N10 = ~scan_lo[5];
  assign o[3] = scan_lo[3] & N11;
  assign N11 = ~scan_lo[4];
  assign o[2] = scan_lo[2] & N12;
  assign N12 = ~scan_lo[3];
  assign o[1] = scan_lo[1] & N13;
  assign N13 = ~scan_lo[2];
  assign o[0] = v_o & N14;
  assign N14 = ~scan_lo[1];

endmodule



module bsg_arb_fixed_inputs_p16_lo_to_hi_p0
(
  ready_i,
  reqs_i,
  grants_o
);

  input [15:0] reqs_i;
  output [15:0] grants_o;
  input ready_i;
  wire [15:0] grants_o,grants_unmasked_lo;

  bsg_priority_encode_one_hot_out_width_p16_lo_to_hi_p0
  enc
  (
    .i(reqs_i),
    .o(grants_unmasked_lo)
  );

  assign grants_o[15] = grants_unmasked_lo[15] & ready_i;
  assign grants_o[14] = grants_unmasked_lo[14] & ready_i;
  assign grants_o[13] = grants_unmasked_lo[13] & ready_i;
  assign grants_o[12] = grants_unmasked_lo[12] & ready_i;
  assign grants_o[11] = grants_unmasked_lo[11] & ready_i;
  assign grants_o[10] = grants_unmasked_lo[10] & ready_i;
  assign grants_o[9] = grants_unmasked_lo[9] & ready_i;
  assign grants_o[8] = grants_unmasked_lo[8] & ready_i;
  assign grants_o[7] = grants_unmasked_lo[7] & ready_i;
  assign grants_o[6] = grants_unmasked_lo[6] & ready_i;
  assign grants_o[5] = grants_unmasked_lo[5] & ready_i;
  assign grants_o[4] = grants_unmasked_lo[4] & ready_i;
  assign grants_o[3] = grants_unmasked_lo[3] & ready_i;
  assign grants_o[2] = grants_unmasked_lo[2] & ready_i;
  assign grants_o[1] = grants_unmasked_lo[1] & ready_i;
  assign grants_o[0] = grants_unmasked_lo[0] & ready_i;

endmodule



module bsg_locking_arb_fixed
(
  clk_i,
  ready_i,
  unlock_i,
  reqs_i,
  grants_o
);

  input [15:0] reqs_i;
  output [15:0] grants_o;
  input clk_i;
  input ready_i;
  input unlock_i;
  wire [15:0] grants_o,not_req_mask_r,req_mask_r;
  wire _0_net_,_1_net__15_,_1_net__14_,_1_net__13_,_1_net__12_,_1_net__11_,_1_net__10_,
  _1_net__9_,_1_net__8_,_1_net__7_,_1_net__6_,_1_net__5_,_1_net__4_,_1_net__3_,
  _1_net__2_,_1_net__1_,_1_net__0_,_2_net__15_,_2_net__14_,_2_net__13_,_2_net__12_,
  _2_net__11_,_2_net__10_,_2_net__9_,_2_net__8_,_2_net__7_,_2_net__6_,_2_net__5_,
  _2_net__4_,_2_net__3_,_2_net__2_,_2_net__1_,_2_net__0_,N0,N1,N2,N3,N4,N5,N6,N7,N8,
  N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,N22,N23,N24,N25,N26,N27,N28,
  N29;

  bsg_dff_reset_en_width_p16
  req_words_reg
  (
    .clk_i(clk_i),
    .reset_i(unlock_i),
    .en_i(_0_net_),
    .data_i({ _1_net__15_, _1_net__14_, _1_net__13_, _1_net__12_, _1_net__11_, _1_net__10_, _1_net__9_, _1_net__8_, _1_net__7_, _1_net__6_, _1_net__5_, _1_net__4_, _1_net__3_, _1_net__2_, _1_net__1_, _1_net__0_ }),
    .data_o(not_req_mask_r)
  );


  bsg_arb_fixed_inputs_p16_lo_to_hi_p0
  fixed_arb
  (
    .ready_i(ready_i),
    .reqs_i({ _2_net__15_, _2_net__14_, _2_net__13_, _2_net__12_, _2_net__11_, _2_net__10_, _2_net__9_, _2_net__8_, _2_net__7_, _2_net__6_, _2_net__5_, _2_net__4_, _2_net__3_, _2_net__2_, _2_net__1_, _2_net__0_ }),
    .grants_o(grants_o)
  );

  assign _1_net__15_ = ~grants_o[15];
  assign _1_net__14_ = ~grants_o[14];
  assign _1_net__13_ = ~grants_o[13];
  assign _1_net__12_ = ~grants_o[12];
  assign _1_net__11_ = ~grants_o[11];
  assign _1_net__10_ = ~grants_o[10];
  assign _1_net__9_ = ~grants_o[9];
  assign _1_net__8_ = ~grants_o[8];
  assign _1_net__7_ = ~grants_o[7];
  assign _1_net__6_ = ~grants_o[6];
  assign _1_net__5_ = ~grants_o[5];
  assign _1_net__4_ = ~grants_o[4];
  assign _1_net__3_ = ~grants_o[3];
  assign _1_net__2_ = ~grants_o[2];
  assign _1_net__1_ = ~grants_o[1];
  assign _1_net__0_ = ~grants_o[0];
  assign _0_net_ = N14 & N29;
  assign N14 = N13 & req_mask_r[0];
  assign N13 = N12 & req_mask_r[1];
  assign N12 = N11 & req_mask_r[2];
  assign N11 = N10 & req_mask_r[3];
  assign N10 = N9 & req_mask_r[4];
  assign N9 = N8 & req_mask_r[5];
  assign N8 = N7 & req_mask_r[6];
  assign N7 = N6 & req_mask_r[7];
  assign N6 = N5 & req_mask_r[8];
  assign N5 = N4 & req_mask_r[9];
  assign N4 = N3 & req_mask_r[10];
  assign N3 = N2 & req_mask_r[11];
  assign N2 = N1 & req_mask_r[12];
  assign N1 = N0 & req_mask_r[13];
  assign N0 = req_mask_r[15] & req_mask_r[14];
  assign N29 = N28 | grants_o[0];
  assign N28 = N27 | grants_o[1];
  assign N27 = N26 | grants_o[2];
  assign N26 = N25 | grants_o[3];
  assign N25 = N24 | grants_o[4];
  assign N24 = N23 | grants_o[5];
  assign N23 = N22 | grants_o[6];
  assign N22 = N21 | grants_o[7];
  assign N21 = N20 | grants_o[8];
  assign N20 = N19 | grants_o[9];
  assign N19 = N18 | grants_o[10];
  assign N18 = N17 | grants_o[11];
  assign N17 = N16 | grants_o[12];
  assign N16 = N15 | grants_o[13];
  assign N15 = grants_o[15] | grants_o[14];
  assign req_mask_r[15] = ~not_req_mask_r[15];
  assign req_mask_r[14] = ~not_req_mask_r[14];
  assign req_mask_r[13] = ~not_req_mask_r[13];
  assign req_mask_r[12] = ~not_req_mask_r[12];
  assign req_mask_r[11] = ~not_req_mask_r[11];
  assign req_mask_r[10] = ~not_req_mask_r[10];
  assign req_mask_r[9] = ~not_req_mask_r[9];
  assign req_mask_r[8] = ~not_req_mask_r[8];
  assign req_mask_r[7] = ~not_req_mask_r[7];
  assign req_mask_r[6] = ~not_req_mask_r[6];
  assign req_mask_r[5] = ~not_req_mask_r[5];
  assign req_mask_r[4] = ~not_req_mask_r[4];
  assign req_mask_r[3] = ~not_req_mask_r[3];
  assign req_mask_r[2] = ~not_req_mask_r[2];
  assign req_mask_r[1] = ~not_req_mask_r[1];
  assign req_mask_r[0] = ~not_req_mask_r[0];
  assign _2_net__15_ = reqs_i[15] & req_mask_r[15];
  assign _2_net__14_ = reqs_i[14] & req_mask_r[14];
  assign _2_net__13_ = reqs_i[13] & req_mask_r[13];
  assign _2_net__12_ = reqs_i[12] & req_mask_r[12];
  assign _2_net__11_ = reqs_i[11] & req_mask_r[11];
  assign _2_net__10_ = reqs_i[10] & req_mask_r[10];
  assign _2_net__9_ = reqs_i[9] & req_mask_r[9];
  assign _2_net__8_ = reqs_i[8] & req_mask_r[8];
  assign _2_net__7_ = reqs_i[7] & req_mask_r[7];
  assign _2_net__6_ = reqs_i[6] & req_mask_r[6];
  assign _2_net__5_ = reqs_i[5] & req_mask_r[5];
  assign _2_net__4_ = reqs_i[4] & req_mask_r[4];
  assign _2_net__3_ = reqs_i[3] & req_mask_r[3];
  assign _2_net__2_ = reqs_i[2] & req_mask_r[2];
  assign _2_net__1_ = reqs_i[1] & req_mask_r[1];
  assign _2_net__0_ = reqs_i[0] & req_mask_r[0];

endmodule

