

module top
(
  clk_i,
  reset_i,
  asm_v_i,
  asm_data_i,
  asm_yumi_o,
  asm_v_o,
  asm_data_o,
  asm_ready_i,
  node_v_o,
  node_data_o,
  node_ready_i,
  node_en_r_o,
  node_reset_r_o,
  node_v_i,
  node_data_i,
  node_yumi_o
);

  input [15:0] asm_data_i;
  output [15:0] asm_data_o;
  output [4:0] node_v_o;
  output [79:0] node_data_o;
  input [4:0] node_ready_i;
  output [4:0] node_en_r_o;
  output [4:0] node_reset_r_o;
  input [4:0] node_v_i;
  input [79:0] node_data_i;
  output [4:0] node_yumi_o;
  input clk_i;
  input reset_i;
  input asm_v_i;
  input asm_ready_i;
  output asm_yumi_o;
  output asm_v_o;

  bsg_fsb
  wrapper
  (
    .asm_data_i(asm_data_i),
    .asm_data_o(asm_data_o),
    .node_v_o(node_v_o),
    .node_data_o(node_data_o),
    .node_ready_i(node_ready_i),
    .node_en_r_o(node_en_r_o),
    .node_reset_r_o(node_reset_r_o),
    .node_v_i(node_v_i),
    .node_data_i(node_data_i),
    .node_yumi_o(node_yumi_o),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .asm_v_i(asm_v_i),
    .asm_ready_i(asm_ready_i),
    .asm_yumi_o(asm_yumi_o),
    .asm_v_o(asm_v_o)
  );


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



module bsg_front_side_bus_hop_in_width_p16_fan_out_p2
(
  clk_i,
  reset_i,
  ready_o,
  v_i,
  data_i,
  v_o,
  data_o,
  ready_i
);

  input [15:0] data_i;
  output [1:0] v_o;
  output [31:0] data_o;
  input [1:0] ready_i;
  input clk_i;
  input reset_i;
  input v_i;
  output ready_o;
  wire [1:0] v_o,sent_r,sent_n;
  wire [31:0] data_o;
  wire ready_o,N0,N1,data_o_0__15_,data_o_0__14_,data_o_0__13_,data_o_0__12_,
  data_o_0__11_,data_o_0__10_,data_o_0__9_,data_o_0__8_,data_o_0__7_,data_o_0__6_,
  data_o_0__5_,data_o_0__4_,data_o_0__3_,data_o_0__2_,data_o_0__1_,data_o_0__0_,fifo_v,
  fifo_yumi,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11;
  reg sent_r_0_sv2v_reg,sent_r_1_sv2v_reg;
  assign sent_r[0] = sent_r_0_sv2v_reg;
  assign sent_r[1] = sent_r_1_sv2v_reg;
  assign data_o[31] = data_o_0__15_;
  assign data_o[15] = data_o_0__15_;
  assign data_o[30] = data_o_0__14_;
  assign data_o[14] = data_o_0__14_;
  assign data_o[29] = data_o_0__13_;
  assign data_o[13] = data_o_0__13_;
  assign data_o[28] = data_o_0__12_;
  assign data_o[12] = data_o_0__12_;
  assign data_o[27] = data_o_0__11_;
  assign data_o[11] = data_o_0__11_;
  assign data_o[26] = data_o_0__10_;
  assign data_o[10] = data_o_0__10_;
  assign data_o[25] = data_o_0__9_;
  assign data_o[9] = data_o_0__9_;
  assign data_o[24] = data_o_0__8_;
  assign data_o[8] = data_o_0__8_;
  assign data_o[23] = data_o_0__7_;
  assign data_o[7] = data_o_0__7_;
  assign data_o[22] = data_o_0__6_;
  assign data_o[6] = data_o_0__6_;
  assign data_o[21] = data_o_0__5_;
  assign data_o[5] = data_o_0__5_;
  assign data_o[20] = data_o_0__4_;
  assign data_o[4] = data_o_0__4_;
  assign data_o[19] = data_o_0__3_;
  assign data_o[3] = data_o_0__3_;
  assign data_o[18] = data_o_0__2_;
  assign data_o[2] = data_o_0__2_;
  assign data_o[17] = data_o_0__1_;
  assign data_o[1] = data_o_0__1_;
  assign data_o[16] = data_o_0__0_;
  assign data_o[0] = data_o_0__0_;

  bsg_two_fifo_width_p16
  fifo
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(ready_o),
    .data_i(data_i),
    .v_i(v_i),
    .v_o(fifo_v),
    .data_o({ data_o_0__15_, data_o_0__14_, data_o_0__13_, data_o_0__12_, data_o_0__11_, data_o_0__10_, data_o_0__9_, data_o_0__8_, data_o_0__7_, data_o_0__6_, data_o_0__5_, data_o_0__4_, data_o_0__3_, data_o_0__2_, data_o_0__1_, data_o_0__0_ }),
    .yumi_i(fifo_yumi)
  );

  assign sent_n[0] = (N0)? 1'b1 : 
                     (N4)? sent_r[0] : 1'b0;
  assign N0 = N3;
  assign sent_n[1] = (N1)? 1'b1 : 
                     (N7)? sent_r[1] : 1'b0;
  assign N1 = N6;
  assign v_o[0] = fifo_v & N8;
  assign N8 = ~sent_r[0];
  assign N2 = sent_n[0] & N9;
  assign N9 = ~fifo_yumi;
  assign N3 = v_o[0] & ready_i[0];
  assign N4 = ~N3;
  assign v_o[1] = fifo_v & N10;
  assign N10 = ~sent_r[1];
  assign N5 = sent_n[1] & N11;
  assign N11 = ~fifo_yumi;
  assign N6 = v_o[1] & ready_i[1];
  assign N7 = ~N6;
  assign fifo_yumi = sent_n[1] & sent_n[0];

  always @(posedge clk_i) begin
    if(reset_i) begin
      sent_r_0_sv2v_reg <= 1'b0;
      sent_r_1_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      sent_r_0_sv2v_reg <= N2;
      sent_r_1_sv2v_reg <= N5;
    end 
  end


endmodule



module bsg_front_side_bus_hop_out_width_p16
(
  clk_i,
  reset_i,
  v_i,
  data_i,
  ready_o,
  yumi_o,
  v_o,
  data_o,
  ready_i
);

  input [1:0] v_i;
  input [31:0] data_i;
  output [15:0] data_o;
  input clk_i;
  input reset_i;
  input ready_i;
  output ready_o;
  output yumi_o;
  output v_o;
  wire [15:0] data_o;
  wire ready_o,yumi_o,v_o,N0,N1,N2,v1_blocked_r,source_sel,fifo_ready,N3,N4,N5,
  _0_net__15_,_0_net__14_,_0_net__13_,_0_net__12_,_0_net__11_,_0_net__10_,_0_net__9_,
  _0_net__8_,_0_net__7_,_0_net__6_,_0_net__5_,_0_net__4_,_0_net__3_,_0_net__2_,
  _0_net__1_,_0_net__0_,_1_net_,_2_net_,N6,N7,N8,N9,N10;
  reg v1_blocked_r_sv2v_reg;
  assign v1_blocked_r = v1_blocked_r_sv2v_reg;

  bsg_two_fifo_width_p16
  fifo
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(fifo_ready),
    .data_i({ _0_net__15_, _0_net__14_, _0_net__13_, _0_net__12_, _0_net__11_, _0_net__10_, _0_net__9_, _0_net__8_, _0_net__7_, _0_net__6_, _0_net__5_, _0_net__4_, _0_net__3_, _0_net__2_, _0_net__1_, _0_net__0_ }),
    .v_i(_2_net_),
    .v_o(v_o),
    .data_o(data_o),
    .yumi_i(_1_net_)
  );

  assign _0_net__15_ = (N6)? data_i[15] : 
                       (N0)? data_i[31] : 1'b0;
  assign N0 = source_sel;
  assign _0_net__14_ = (N6)? data_i[14] : 
                       (N0)? data_i[30] : 1'b0;
  assign _0_net__13_ = (N6)? data_i[13] : 
                       (N0)? data_i[29] : 1'b0;
  assign _0_net__12_ = (N6)? data_i[12] : 
                       (N0)? data_i[28] : 1'b0;
  assign _0_net__11_ = (N6)? data_i[11] : 
                       (N0)? data_i[27] : 1'b0;
  assign _0_net__10_ = (N6)? data_i[10] : 
                       (N0)? data_i[26] : 1'b0;
  assign _0_net__9_ = (N6)? data_i[9] : 
                      (N0)? data_i[25] : 1'b0;
  assign _0_net__8_ = (N6)? data_i[8] : 
                      (N0)? data_i[24] : 1'b0;
  assign _0_net__7_ = (N6)? data_i[7] : 
                      (N0)? data_i[23] : 1'b0;
  assign _0_net__6_ = (N6)? data_i[6] : 
                      (N0)? data_i[22] : 1'b0;
  assign _0_net__5_ = (N6)? data_i[5] : 
                      (N0)? data_i[21] : 1'b0;
  assign _0_net__4_ = (N6)? data_i[4] : 
                      (N0)? data_i[20] : 1'b0;
  assign _0_net__3_ = (N6)? data_i[3] : 
                      (N0)? data_i[19] : 1'b0;
  assign _0_net__2_ = (N6)? data_i[2] : 
                      (N0)? data_i[18] : 1'b0;
  assign _0_net__1_ = (N6)? data_i[1] : 
                      (N0)? data_i[17] : 1'b0;
  assign _0_net__0_ = (N6)? data_i[0] : 
                      (N0)? data_i[16] : 1'b0;
  assign N5 = (N1)? N4 : 
              (N2)? v1_blocked_r : 1'b0;
  assign N1 = fifo_ready;
  assign N2 = N3;
  assign source_sel = N7 | v1_blocked_r;
  assign N7 = ~v_i[0];
  assign yumi_o = N8 & source_sel;
  assign N8 = fifo_ready & v_i[1];
  assign N3 = ~fifo_ready;
  assign N4 = v_i[1] & N9;
  assign N9 = ~source_sel;
  assign _2_net_ = v_i[1] | v_i[0];
  assign _1_net_ = v_o & ready_i;
  assign N6 = ~source_sel;
  assign ready_o = fifo_ready & N10;
  assign N10 = ~v1_blocked_r;

  always @(posedge clk_i) begin
    if(reset_i) begin
      v1_blocked_r_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      v1_blocked_r_sv2v_reg <= N5;
    end 
  end


endmodule



module bsg_fsb_murn_gateway_16_0_3_x_x
(
  clk_i,
  reset_i,
  v_i,
  data_i,
  ready_o,
  v_o,
  ready_i,
  node_en_r_o,
  node_reset_r_o
);

  input [15:0] data_i;
  input clk_i;
  input reset_i;
  input v_i;
  input ready_i;
  output ready_o;
  output v_o;
  output node_en_r_o;
  output node_reset_r_o;
  wire ready_o,v_o,node_en_r_o,node_reset_r_o,N0,N1,N2,N3,N4,\genblk1.for_this_node ,
  \genblk1.for_switch ,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,
  N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,
  N41,N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53,N54,N55,N56,N57;
  reg node_en_r_o_sv2v_reg,node_reset_r_o_sv2v_reg;
  assign node_en_r_o = node_en_r_o_sv2v_reg;
  assign node_reset_r_o = node_reset_r_o_sv2v_reg;
  assign N5 = data_i[7] | N19;
  assign N6 = N5 | data_i[5];
  assign N7 = N23 | N6;
  assign N9 = data_i[7] | data_i[6];
  assign N10 = N9 | N13;
  assign N11 = N23 | N10;
  assign N14 = N18 | data_i[6];
  assign N15 = N14 | N13;
  assign N16 = N23 | N15;
  assign N20 = data_i[11] | data_i[10];
  assign N21 = data_i[9] | data_i[8];
  assign N22 = N18 | N19;
  assign N23 = N20 | N21;
  assign N24 = N22 | data_i[5];
  assign N25 = N23 | N24;
  assign N43 = data_i[14] | data_i[15];
  assign N44 = data_i[13] | N43;
  assign N45 = ~N44;
  assign N31 = (N0)? 1'b1 : 
               (N1)? 1'b0 : 
               (N30)? node_en_r_o : 1'b0;
  assign N0 = N8;
  assign N1 = N12;
  assign N32 = (N2)? 1'b1 : 
               (N3)? 1'b0 : 
               (N30)? node_reset_r_o : 1'b0;
  assign N2 = N17;
  assign N3 = N26;
  assign N4 = 1'b0;
  assign \genblk1.for_this_node  = v_i & N46;
  assign N46 = N45 | N4;
  assign \genblk1.for_switch  = N50 & data_i[12];
  assign N50 = N49 & N45;
  assign N49 = N48 & v_i;
  assign N48 = ~N47;
  assign N47 = N4 & node_en_r_o;
  assign v_o = N51 & N52;
  assign N51 = node_en_r_o & \genblk1.for_this_node ;
  assign N52 = ~\genblk1.for_switch ;
  assign ready_o = v_i & N57;
  assign N57 = N55 | N56;
  assign N55 = N54 | \genblk1.for_switch ;
  assign N54 = N53 | ready_i;
  assign N53 = ~node_en_r_o;
  assign N56 = ~\genblk1.for_this_node ;
  assign N8 = ~N7;
  assign N12 = ~N11;
  assign N13 = ~data_i[5];
  assign N17 = ~N16;
  assign N18 = ~data_i[7];
  assign N19 = ~data_i[6];
  assign N26 = ~N25;
  assign N27 = N12 | N8;
  assign N28 = N17 | N27;
  assign N29 = N26 | N28;
  assign N30 = ~N29;
  assign N33 = N17 & \genblk1.for_switch ;
  assign N34 = N26 & \genblk1.for_switch ;
  assign N35 = N33 | N34;
  assign N36 = N35 | N52;
  assign N37 = ~N36;
  assign N38 = N8 & \genblk1.for_switch ;
  assign N39 = N12 & \genblk1.for_switch ;
  assign N40 = N38 | N39;
  assign N41 = N40 | N52;
  assign N42 = ~N41;

  always @(posedge clk_i) begin
    if(reset_i) begin
      node_en_r_o_sv2v_reg <= 1'b0;
    end else if(N37) begin
      node_en_r_o_sv2v_reg <= N31;
    end 
    if(reset_i) begin
      node_reset_r_o_sv2v_reg <= 1'b1;
    end else if(N42) begin
      node_reset_r_o_sv2v_reg <= N32;
    end 
  end


endmodule



module bsg_fsb_murn_gateway_16_1_3_0_0
(
  clk_i,
  reset_i,
  v_i,
  data_i,
  ready_o,
  v_o,
  ready_i,
  node_en_r_o,
  node_reset_r_o
);

  input [15:0] data_i;
  input clk_i;
  input reset_i;
  input v_i;
  input ready_i;
  output ready_o;
  output v_o;
  output node_en_r_o;
  output node_reset_r_o;
  wire ready_o,v_o,node_en_r_o,node_reset_r_o,N0,N1,N2,N3,\genblk1.for_this_node ,
  \genblk1.for_switch ,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,
  N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,
  N41,N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53;
  reg node_en_r_o_sv2v_reg,node_reset_r_o_sv2v_reg;
  assign node_en_r_o = node_en_r_o_sv2v_reg;
  assign node_reset_r_o = node_reset_r_o_sv2v_reg;
  assign N4 = data_i[7] | N18;
  assign N5 = N4 | data_i[5];
  assign N6 = N22 | N5;
  assign N8 = data_i[7] | data_i[6];
  assign N9 = N8 | N12;
  assign N10 = N22 | N9;
  assign N13 = N17 | data_i[6];
  assign N14 = N13 | N12;
  assign N15 = N22 | N14;
  assign N19 = data_i[11] | data_i[10];
  assign N20 = data_i[9] | data_i[8];
  assign N21 = N17 | N18;
  assign N22 = N19 | N20;
  assign N23 = N21 | data_i[5];
  assign N24 = N22 | N23;
  assign N42 = ~data_i[13];
  assign N43 = data_i[14] | data_i[15];
  assign N44 = N42 | N43;
  assign N45 = ~N44;
  assign N30 = (N0)? 1'b1 : 
               (N1)? 1'b0 : 
               (N29)? node_en_r_o : 1'b0;
  assign N0 = N7;
  assign N1 = N11;
  assign N31 = (N2)? 1'b1 : 
               (N3)? 1'b0 : 
               (N29)? node_reset_r_o : 1'b0;
  assign N2 = N16;
  assign N3 = N25;
  assign \genblk1.for_this_node  = v_i & N45;
  assign \genblk1.for_switch  = N46 & data_i[12];
  assign N46 = v_i & N45;
  assign v_o = N47 & N48;
  assign N47 = node_en_r_o & \genblk1.for_this_node ;
  assign N48 = ~\genblk1.for_switch ;
  assign ready_o = v_i & N53;
  assign N53 = N51 | N52;
  assign N51 = N50 | \genblk1.for_switch ;
  assign N50 = N49 | ready_i;
  assign N49 = ~node_en_r_o;
  assign N52 = ~\genblk1.for_this_node ;
  assign N7 = ~N6;
  assign N11 = ~N10;
  assign N12 = ~data_i[5];
  assign N16 = ~N15;
  assign N17 = ~data_i[7];
  assign N18 = ~data_i[6];
  assign N25 = ~N24;
  assign N26 = N11 | N7;
  assign N27 = N16 | N26;
  assign N28 = N25 | N27;
  assign N29 = ~N28;
  assign N32 = N16 & \genblk1.for_switch ;
  assign N33 = N25 & \genblk1.for_switch ;
  assign N34 = N32 | N33;
  assign N35 = N34 | N48;
  assign N36 = ~N35;
  assign N37 = N7 & \genblk1.for_switch ;
  assign N38 = N11 & \genblk1.for_switch ;
  assign N39 = N37 | N38;
  assign N40 = N39 | N48;
  assign N41 = ~N40;

  always @(posedge clk_i) begin
    if(reset_i) begin
      node_en_r_o_sv2v_reg <= 1'b0;
    end else if(N36) begin
      node_en_r_o_sv2v_reg <= N30;
    end 
    if(reset_i) begin
      node_reset_r_o_sv2v_reg <= 1'b1;
    end else if(N41) begin
      node_reset_r_o_sv2v_reg <= N31;
    end 
  end


endmodule



module bsg_fsb_murn_gateway_16_2_3_0_0
(
  clk_i,
  reset_i,
  v_i,
  data_i,
  ready_o,
  v_o,
  ready_i,
  node_en_r_o,
  node_reset_r_o
);

  input [15:0] data_i;
  input clk_i;
  input reset_i;
  input v_i;
  input ready_i;
  output ready_o;
  output v_o;
  output node_en_r_o;
  output node_reset_r_o;
  wire ready_o,v_o,node_en_r_o,node_reset_r_o,N0,N1,N2,N3,\genblk1.for_this_node ,
  \genblk1.for_switch ,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,
  N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,
  N41,N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53;
  reg node_en_r_o_sv2v_reg,node_reset_r_o_sv2v_reg;
  assign node_en_r_o = node_en_r_o_sv2v_reg;
  assign node_reset_r_o = node_reset_r_o_sv2v_reg;
  assign N4 = data_i[7] | N18;
  assign N5 = N4 | data_i[5];
  assign N6 = N22 | N5;
  assign N8 = data_i[7] | data_i[6];
  assign N9 = N8 | N12;
  assign N10 = N22 | N9;
  assign N13 = N17 | data_i[6];
  assign N14 = N13 | N12;
  assign N15 = N22 | N14;
  assign N19 = data_i[11] | data_i[10];
  assign N20 = data_i[9] | data_i[8];
  assign N21 = N17 | N18;
  assign N22 = N19 | N20;
  assign N23 = N21 | data_i[5];
  assign N24 = N22 | N23;
  assign N42 = ~data_i[14];
  assign N43 = N42 | data_i[15];
  assign N44 = data_i[13] | N43;
  assign N45 = ~N44;
  assign N30 = (N0)? 1'b1 : 
               (N1)? 1'b0 : 
               (N29)? node_en_r_o : 1'b0;
  assign N0 = N7;
  assign N1 = N11;
  assign N31 = (N2)? 1'b1 : 
               (N3)? 1'b0 : 
               (N29)? node_reset_r_o : 1'b0;
  assign N2 = N16;
  assign N3 = N25;
  assign \genblk1.for_this_node  = v_i & N45;
  assign \genblk1.for_switch  = N46 & data_i[12];
  assign N46 = v_i & N45;
  assign v_o = N47 & N48;
  assign N47 = node_en_r_o & \genblk1.for_this_node ;
  assign N48 = ~\genblk1.for_switch ;
  assign ready_o = v_i & N53;
  assign N53 = N51 | N52;
  assign N51 = N50 | \genblk1.for_switch ;
  assign N50 = N49 | ready_i;
  assign N49 = ~node_en_r_o;
  assign N52 = ~\genblk1.for_this_node ;
  assign N7 = ~N6;
  assign N11 = ~N10;
  assign N12 = ~data_i[5];
  assign N16 = ~N15;
  assign N17 = ~data_i[7];
  assign N18 = ~data_i[6];
  assign N25 = ~N24;
  assign N26 = N11 | N7;
  assign N27 = N16 | N26;
  assign N28 = N25 | N27;
  assign N29 = ~N28;
  assign N32 = N16 & \genblk1.for_switch ;
  assign N33 = N25 & \genblk1.for_switch ;
  assign N34 = N32 | N33;
  assign N35 = N34 | N48;
  assign N36 = ~N35;
  assign N37 = N7 & \genblk1.for_switch ;
  assign N38 = N11 & \genblk1.for_switch ;
  assign N39 = N37 | N38;
  assign N40 = N39 | N48;
  assign N41 = ~N40;

  always @(posedge clk_i) begin
    if(reset_i) begin
      node_en_r_o_sv2v_reg <= 1'b0;
    end else if(N36) begin
      node_en_r_o_sv2v_reg <= N30;
    end 
    if(reset_i) begin
      node_reset_r_o_sv2v_reg <= 1'b1;
    end else if(N41) begin
      node_reset_r_o_sv2v_reg <= N31;
    end 
  end


endmodule



module bsg_fsb_murn_gateway_16_3_3_0_0
(
  clk_i,
  reset_i,
  v_i,
  data_i,
  ready_o,
  v_o,
  ready_i,
  node_en_r_o,
  node_reset_r_o
);

  input [15:0] data_i;
  input clk_i;
  input reset_i;
  input v_i;
  input ready_i;
  output ready_o;
  output v_o;
  output node_en_r_o;
  output node_reset_r_o;
  wire ready_o,v_o,node_en_r_o,node_reset_r_o,N0,N1,N2,N3,\genblk1.for_this_node ,
  \genblk1.for_switch ,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,
  N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,
  N41,N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53,N54;
  reg node_en_r_o_sv2v_reg,node_reset_r_o_sv2v_reg;
  assign node_en_r_o = node_en_r_o_sv2v_reg;
  assign node_reset_r_o = node_reset_r_o_sv2v_reg;
  assign N4 = data_i[7] | N18;
  assign N5 = N4 | data_i[5];
  assign N6 = N22 | N5;
  assign N8 = data_i[7] | data_i[6];
  assign N9 = N8 | N12;
  assign N10 = N22 | N9;
  assign N13 = N17 | data_i[6];
  assign N14 = N13 | N12;
  assign N15 = N22 | N14;
  assign N19 = data_i[11] | data_i[10];
  assign N20 = data_i[9] | data_i[8];
  assign N21 = N17 | N18;
  assign N22 = N19 | N20;
  assign N23 = N21 | data_i[5];
  assign N24 = N22 | N23;
  assign N42 = ~data_i[14];
  assign N43 = ~data_i[13];
  assign N44 = N42 | data_i[15];
  assign N45 = N43 | N44;
  assign N46 = ~N45;
  assign N30 = (N0)? 1'b1 : 
               (N1)? 1'b0 : 
               (N29)? node_en_r_o : 1'b0;
  assign N0 = N7;
  assign N1 = N11;
  assign N31 = (N2)? 1'b1 : 
               (N3)? 1'b0 : 
               (N29)? node_reset_r_o : 1'b0;
  assign N2 = N16;
  assign N3 = N25;
  assign \genblk1.for_this_node  = v_i & N46;
  assign \genblk1.for_switch  = N47 & data_i[12];
  assign N47 = v_i & N46;
  assign v_o = N48 & N49;
  assign N48 = node_en_r_o & \genblk1.for_this_node ;
  assign N49 = ~\genblk1.for_switch ;
  assign ready_o = v_i & N54;
  assign N54 = N52 | N53;
  assign N52 = N51 | \genblk1.for_switch ;
  assign N51 = N50 | ready_i;
  assign N50 = ~node_en_r_o;
  assign N53 = ~\genblk1.for_this_node ;
  assign N7 = ~N6;
  assign N11 = ~N10;
  assign N12 = ~data_i[5];
  assign N16 = ~N15;
  assign N17 = ~data_i[7];
  assign N18 = ~data_i[6];
  assign N25 = ~N24;
  assign N26 = N11 | N7;
  assign N27 = N16 | N26;
  assign N28 = N25 | N27;
  assign N29 = ~N28;
  assign N32 = N16 & \genblk1.for_switch ;
  assign N33 = N25 & \genblk1.for_switch ;
  assign N34 = N32 | N33;
  assign N35 = N34 | N49;
  assign N36 = ~N35;
  assign N37 = N7 & \genblk1.for_switch ;
  assign N38 = N11 & \genblk1.for_switch ;
  assign N39 = N37 | N38;
  assign N40 = N39 | N49;
  assign N41 = ~N40;

  always @(posedge clk_i) begin
    if(reset_i) begin
      node_en_r_o_sv2v_reg <= 1'b0;
    end else if(N36) begin
      node_en_r_o_sv2v_reg <= N30;
    end 
    if(reset_i) begin
      node_reset_r_o_sv2v_reg <= 1'b1;
    end else if(N41) begin
      node_reset_r_o_sv2v_reg <= N31;
    end 
  end


endmodule



module bsg_fsb_murn_gateway_16_4_3_0_0
(
  clk_i,
  reset_i,
  v_i,
  data_i,
  ready_o,
  v_o,
  ready_i,
  node_en_r_o,
  node_reset_r_o
);

  input [15:0] data_i;
  input clk_i;
  input reset_i;
  input v_i;
  input ready_i;
  output ready_o;
  output v_o;
  output node_en_r_o;
  output node_reset_r_o;
  wire ready_o,v_o,node_en_r_o,node_reset_r_o,N0,N1,N2,N3,\genblk1.for_this_node ,
  \genblk1.for_switch ,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,
  N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,
  N41,N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53;
  reg node_en_r_o_sv2v_reg,node_reset_r_o_sv2v_reg;
  assign node_en_r_o = node_en_r_o_sv2v_reg;
  assign node_reset_r_o = node_reset_r_o_sv2v_reg;
  assign N4 = data_i[7] | N18;
  assign N5 = N4 | data_i[5];
  assign N6 = N22 | N5;
  assign N8 = data_i[7] | data_i[6];
  assign N9 = N8 | N12;
  assign N10 = N22 | N9;
  assign N13 = N17 | data_i[6];
  assign N14 = N13 | N12;
  assign N15 = N22 | N14;
  assign N19 = data_i[11] | data_i[10];
  assign N20 = data_i[9] | data_i[8];
  assign N21 = N17 | N18;
  assign N22 = N19 | N20;
  assign N23 = N21 | data_i[5];
  assign N24 = N22 | N23;
  assign N42 = ~data_i[15];
  assign N43 = data_i[14] | N42;
  assign N44 = data_i[13] | N43;
  assign N45 = ~N44;
  assign N30 = (N0)? 1'b1 : 
               (N1)? 1'b0 : 
               (N29)? node_en_r_o : 1'b0;
  assign N0 = N7;
  assign N1 = N11;
  assign N31 = (N2)? 1'b1 : 
               (N3)? 1'b0 : 
               (N29)? node_reset_r_o : 1'b0;
  assign N2 = N16;
  assign N3 = N25;
  assign \genblk1.for_this_node  = v_i & N45;
  assign \genblk1.for_switch  = N46 & data_i[12];
  assign N46 = v_i & N45;
  assign v_o = N47 & N48;
  assign N47 = node_en_r_o & \genblk1.for_this_node ;
  assign N48 = ~\genblk1.for_switch ;
  assign ready_o = v_i & N53;
  assign N53 = N51 | N52;
  assign N51 = N50 | \genblk1.for_switch ;
  assign N50 = N49 | ready_i;
  assign N49 = ~node_en_r_o;
  assign N52 = ~\genblk1.for_this_node ;
  assign N7 = ~N6;
  assign N11 = ~N10;
  assign N12 = ~data_i[5];
  assign N16 = ~N15;
  assign N17 = ~data_i[7];
  assign N18 = ~data_i[6];
  assign N25 = ~N24;
  assign N26 = N11 | N7;
  assign N27 = N16 | N26;
  assign N28 = N25 | N27;
  assign N29 = ~N28;
  assign N32 = N16 & \genblk1.for_switch ;
  assign N33 = N25 & \genblk1.for_switch ;
  assign N34 = N32 | N33;
  assign N35 = N34 | N48;
  assign N36 = ~N35;
  assign N37 = N7 & \genblk1.for_switch ;
  assign N38 = N11 & \genblk1.for_switch ;
  assign N39 = N37 | N38;
  assign N40 = N39 | N48;
  assign N41 = ~N40;

  always @(posedge clk_i) begin
    if(reset_i) begin
      node_en_r_o_sv2v_reg <= 1'b0;
    end else if(N36) begin
      node_en_r_o_sv2v_reg <= N30;
    end 
    if(reset_i) begin
      node_reset_r_o_sv2v_reg <= 1'b1;
    end else if(N41) begin
      node_reset_r_o_sv2v_reg <= N31;
    end 
  end


endmodule



module bsg_fsb
(
  clk_i,
  reset_i,
  asm_v_i,
  asm_data_i,
  asm_yumi_o,
  asm_v_o,
  asm_data_o,
  asm_ready_i,
  node_v_o,
  node_data_o,
  node_ready_i,
  node_en_r_o,
  node_reset_r_o,
  node_v_i,
  node_data_i,
  node_yumi_o
);

  input [15:0] asm_data_i;
  output [15:0] asm_data_o;
  output [4:0] node_v_o;
  output [79:0] node_data_o;
  input [4:0] node_ready_i;
  output [4:0] node_en_r_o;
  output [4:0] node_reset_r_o;
  input [4:0] node_v_i;
  input [79:0] node_data_i;
  output [4:0] node_yumi_o;
  input clk_i;
  input reset_i;
  input asm_v_i;
  input asm_ready_i;
  output asm_yumi_o;
  output asm_v_o;
  wire [15:0] asm_data_o;
  wire [4:0] node_v_o,node_en_r_o,node_reset_r_o,node_yumi_o,in_hop_v,out_hop_ready;
  wire [79:0] node_data_o,in_hop_data;
  wire asm_yumi_o,asm_v_o,out_hop_data_3__15_,out_hop_data_3__14_,out_hop_data_3__13_,
  out_hop_data_3__12_,out_hop_data_3__11_,out_hop_data_3__10_,out_hop_data_3__9_,
  out_hop_data_3__8_,out_hop_data_3__7_,out_hop_data_3__6_,out_hop_data_3__5_,
  out_hop_data_3__4_,out_hop_data_3__3_,out_hop_data_3__2_,out_hop_data_3__1_,
  out_hop_data_3__0_,out_hop_data_2__15_,out_hop_data_2__14_,out_hop_data_2__13_,
  out_hop_data_2__12_,out_hop_data_2__11_,out_hop_data_2__10_,out_hop_data_2__9_,
  out_hop_data_2__8_,out_hop_data_2__7_,out_hop_data_2__6_,out_hop_data_2__5_,
  out_hop_data_2__4_,out_hop_data_2__3_,out_hop_data_2__2_,out_hop_data_2__1_,out_hop_data_2__0_,
  out_hop_data_1__15_,out_hop_data_1__14_,out_hop_data_1__13_,out_hop_data_1__12_,
  out_hop_data_1__11_,out_hop_data_1__10_,out_hop_data_1__9_,out_hop_data_1__8_,
  out_hop_data_1__7_,out_hop_data_1__6_,out_hop_data_1__5_,out_hop_data_1__4_,
  out_hop_data_1__3_,out_hop_data_1__2_,out_hop_data_1__1_,out_hop_data_1__0_,
  out_hop_data_0__15_,out_hop_data_0__14_,out_hop_data_0__13_,out_hop_data_0__12_,
  out_hop_data_0__11_,out_hop_data_0__10_,out_hop_data_0__9_,out_hop_data_0__8_,
  out_hop_data_0__7_,out_hop_data_0__6_,out_hop_data_0__5_,out_hop_data_0__4_,
  out_hop_data_0__3_,out_hop_data_0__2_,out_hop_data_0__1_,out_hop_data_0__0_,to_asm_ready,
  \fsb_node_0_.node_ready_int ,\fsb_node_0_.node_v_int ,_3_net__1_,
  \fsb_node_1_.node_ready_int ,\fsb_node_1_.node_v_int ,_8_net__1_,\fsb_node_2_.node_ready_int ,
  \fsb_node_2_.node_v_int ,_13_net__1_,\fsb_node_3_.node_ready_int ,
  \fsb_node_3_.node_v_int ,_18_net__1_,\fsb_node_4_.node_ready_int ,\fsb_node_4_.node_v_int ,_23_net__1_;
  wire [3:0] out_hop_v,in_hop_ready;

  bsg_front_side_bus_hop_in_width_p16_fan_out_p2
  \fsb_node_0_.hopin 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(to_asm_ready),
    .v_i(asm_v_i),
    .data_i(asm_data_i),
    .v_o({ \fsb_node_0_.node_v_int , in_hop_v[0:0] }),
    .data_o({ node_data_o[15:0], in_hop_data[15:0] }),
    .ready_i({ \fsb_node_0_.node_ready_int , in_hop_ready[0:0] })
  );


  bsg_front_side_bus_hop_out_width_p16
  \fsb_node_0_.hopout 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i({ _3_net__1_, out_hop_v[0:0] }),
    .data_i({ node_data_i[15:0], out_hop_data_0__15_, out_hop_data_0__14_, out_hop_data_0__13_, out_hop_data_0__12_, out_hop_data_0__11_, out_hop_data_0__10_, out_hop_data_0__9_, out_hop_data_0__8_, out_hop_data_0__7_, out_hop_data_0__6_, out_hop_data_0__5_, out_hop_data_0__4_, out_hop_data_0__3_, out_hop_data_0__2_, out_hop_data_0__1_, out_hop_data_0__0_ }),
    .ready_o(out_hop_ready[0]),
    .yumi_o(node_yumi_o[0]),
    .v_o(asm_v_o),
    .data_o(asm_data_o),
    .ready_i(asm_ready_i)
  );


  bsg_fsb_murn_gateway_16_0_3_x_x
  \fsb_node_0_.murn_gateway 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(\fsb_node_0_.node_v_int ),
    .data_i(node_data_o[15:0]),
    .ready_o(\fsb_node_0_.node_ready_int ),
    .v_o(node_v_o[0]),
    .ready_i(node_ready_i[0]),
    .node_en_r_o(node_en_r_o[0]),
    .node_reset_r_o(node_reset_r_o[0])
  );


  bsg_front_side_bus_hop_in_width_p16_fan_out_p2
  \fsb_node_1_.hopin 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(in_hop_ready[0]),
    .v_i(in_hop_v[0]),
    .data_i(in_hop_data[15:0]),
    .v_o({ \fsb_node_1_.node_v_int , in_hop_v[1:1] }),
    .data_o({ node_data_o[31:16], in_hop_data[31:16] }),
    .ready_i({ \fsb_node_1_.node_ready_int , in_hop_ready[1:1] })
  );


  bsg_front_side_bus_hop_out_width_p16
  \fsb_node_1_.hopout 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i({ _8_net__1_, out_hop_v[1:1] }),
    .data_i({ node_data_i[31:16], out_hop_data_1__15_, out_hop_data_1__14_, out_hop_data_1__13_, out_hop_data_1__12_, out_hop_data_1__11_, out_hop_data_1__10_, out_hop_data_1__9_, out_hop_data_1__8_, out_hop_data_1__7_, out_hop_data_1__6_, out_hop_data_1__5_, out_hop_data_1__4_, out_hop_data_1__3_, out_hop_data_1__2_, out_hop_data_1__1_, out_hop_data_1__0_ }),
    .ready_o(out_hop_ready[1]),
    .yumi_o(node_yumi_o[1]),
    .v_o(out_hop_v[0]),
    .data_o({ out_hop_data_0__15_, out_hop_data_0__14_, out_hop_data_0__13_, out_hop_data_0__12_, out_hop_data_0__11_, out_hop_data_0__10_, out_hop_data_0__9_, out_hop_data_0__8_, out_hop_data_0__7_, out_hop_data_0__6_, out_hop_data_0__5_, out_hop_data_0__4_, out_hop_data_0__3_, out_hop_data_0__2_, out_hop_data_0__1_, out_hop_data_0__0_ }),
    .ready_i(out_hop_ready[0])
  );


  bsg_fsb_murn_gateway_16_1_3_0_0
  \fsb_node_1_.murn_gateway 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(\fsb_node_1_.node_v_int ),
    .data_i(node_data_o[31:16]),
    .ready_o(\fsb_node_1_.node_ready_int ),
    .v_o(node_v_o[1]),
    .ready_i(node_ready_i[1]),
    .node_en_r_o(node_en_r_o[1]),
    .node_reset_r_o(node_reset_r_o[1])
  );


  bsg_front_side_bus_hop_in_width_p16_fan_out_p2
  \fsb_node_2_.hopin 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(in_hop_ready[1]),
    .v_i(in_hop_v[1]),
    .data_i(in_hop_data[31:16]),
    .v_o({ \fsb_node_2_.node_v_int , in_hop_v[2:2] }),
    .data_o({ node_data_o[47:32], in_hop_data[47:32] }),
    .ready_i({ \fsb_node_2_.node_ready_int , in_hop_ready[2:2] })
  );


  bsg_front_side_bus_hop_out_width_p16
  \fsb_node_2_.hopout 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i({ _13_net__1_, out_hop_v[2:2] }),
    .data_i({ node_data_i[47:32], out_hop_data_2__15_, out_hop_data_2__14_, out_hop_data_2__13_, out_hop_data_2__12_, out_hop_data_2__11_, out_hop_data_2__10_, out_hop_data_2__9_, out_hop_data_2__8_, out_hop_data_2__7_, out_hop_data_2__6_, out_hop_data_2__5_, out_hop_data_2__4_, out_hop_data_2__3_, out_hop_data_2__2_, out_hop_data_2__1_, out_hop_data_2__0_ }),
    .ready_o(out_hop_ready[2]),
    .yumi_o(node_yumi_o[2]),
    .v_o(out_hop_v[1]),
    .data_o({ out_hop_data_1__15_, out_hop_data_1__14_, out_hop_data_1__13_, out_hop_data_1__12_, out_hop_data_1__11_, out_hop_data_1__10_, out_hop_data_1__9_, out_hop_data_1__8_, out_hop_data_1__7_, out_hop_data_1__6_, out_hop_data_1__5_, out_hop_data_1__4_, out_hop_data_1__3_, out_hop_data_1__2_, out_hop_data_1__1_, out_hop_data_1__0_ }),
    .ready_i(out_hop_ready[1])
  );


  bsg_fsb_murn_gateway_16_2_3_0_0
  \fsb_node_2_.murn_gateway 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(\fsb_node_2_.node_v_int ),
    .data_i(node_data_o[47:32]),
    .ready_o(\fsb_node_2_.node_ready_int ),
    .v_o(node_v_o[2]),
    .ready_i(node_ready_i[2]),
    .node_en_r_o(node_en_r_o[2]),
    .node_reset_r_o(node_reset_r_o[2])
  );


  bsg_front_side_bus_hop_in_width_p16_fan_out_p2
  \fsb_node_3_.hopin 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(in_hop_ready[2]),
    .v_i(in_hop_v[2]),
    .data_i(in_hop_data[47:32]),
    .v_o({ \fsb_node_3_.node_v_int , in_hop_v[3:3] }),
    .data_o({ node_data_o[63:48], in_hop_data[63:48] }),
    .ready_i({ \fsb_node_3_.node_ready_int , in_hop_ready[3:3] })
  );


  bsg_front_side_bus_hop_out_width_p16
  \fsb_node_3_.hopout 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i({ _18_net__1_, out_hop_v[3:3] }),
    .data_i({ node_data_i[63:48], out_hop_data_3__15_, out_hop_data_3__14_, out_hop_data_3__13_, out_hop_data_3__12_, out_hop_data_3__11_, out_hop_data_3__10_, out_hop_data_3__9_, out_hop_data_3__8_, out_hop_data_3__7_, out_hop_data_3__6_, out_hop_data_3__5_, out_hop_data_3__4_, out_hop_data_3__3_, out_hop_data_3__2_, out_hop_data_3__1_, out_hop_data_3__0_ }),
    .ready_o(out_hop_ready[3]),
    .yumi_o(node_yumi_o[3]),
    .v_o(out_hop_v[2]),
    .data_o({ out_hop_data_2__15_, out_hop_data_2__14_, out_hop_data_2__13_, out_hop_data_2__12_, out_hop_data_2__11_, out_hop_data_2__10_, out_hop_data_2__9_, out_hop_data_2__8_, out_hop_data_2__7_, out_hop_data_2__6_, out_hop_data_2__5_, out_hop_data_2__4_, out_hop_data_2__3_, out_hop_data_2__2_, out_hop_data_2__1_, out_hop_data_2__0_ }),
    .ready_i(out_hop_ready[2])
  );


  bsg_fsb_murn_gateway_16_3_3_0_0
  \fsb_node_3_.murn_gateway 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(\fsb_node_3_.node_v_int ),
    .data_i(node_data_o[63:48]),
    .ready_o(\fsb_node_3_.node_ready_int ),
    .v_o(node_v_o[3]),
    .ready_i(node_ready_i[3]),
    .node_en_r_o(node_en_r_o[3]),
    .node_reset_r_o(node_reset_r_o[3])
  );


  bsg_front_side_bus_hop_in_width_p16_fan_out_p2
  \fsb_node_4_.hopin 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(in_hop_ready[3]),
    .v_i(in_hop_v[3]),
    .data_i(in_hop_data[63:48]),
    .v_o({ \fsb_node_4_.node_v_int , in_hop_v[4:4] }),
    .data_o({ node_data_o[79:64], in_hop_data[79:64] }),
    .ready_i({ \fsb_node_4_.node_ready_int , 1'b1 })
  );


  bsg_front_side_bus_hop_out_width_p16
  \fsb_node_4_.hopout 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i({ _23_net__1_, 1'b0 }),
    .data_i({ node_data_i[79:64], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 }),
    .ready_o(out_hop_ready[4]),
    .yumi_o(node_yumi_o[4]),
    .v_o(out_hop_v[3]),
    .data_o({ out_hop_data_3__15_, out_hop_data_3__14_, out_hop_data_3__13_, out_hop_data_3__12_, out_hop_data_3__11_, out_hop_data_3__10_, out_hop_data_3__9_, out_hop_data_3__8_, out_hop_data_3__7_, out_hop_data_3__6_, out_hop_data_3__5_, out_hop_data_3__4_, out_hop_data_3__3_, out_hop_data_3__2_, out_hop_data_3__1_, out_hop_data_3__0_ }),
    .ready_i(out_hop_ready[3])
  );


  bsg_fsb_murn_gateway_16_4_3_0_0
  \fsb_node_4_.murn_gateway 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(\fsb_node_4_.node_v_int ),
    .data_i(node_data_o[79:64]),
    .ready_o(\fsb_node_4_.node_ready_int ),
    .v_o(node_v_o[4]),
    .ready_i(node_ready_i[4]),
    .node_en_r_o(node_en_r_o[4]),
    .node_reset_r_o(node_reset_r_o[4])
  );

  assign asm_yumi_o = to_asm_ready & asm_v_i;
  assign _3_net__1_ = node_en_r_o[0] & node_v_i[0];
  assign _8_net__1_ = node_en_r_o[1] & node_v_i[1];
  assign _13_net__1_ = node_en_r_o[2] & node_v_i[2];
  assign _18_net__1_ = node_en_r_o[3] & node_v_i[3];
  assign _23_net__1_ = node_en_r_o[4] & node_v_i[4];

endmodule

