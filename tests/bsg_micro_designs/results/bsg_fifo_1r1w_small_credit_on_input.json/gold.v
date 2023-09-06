

module top
(
  clk_i,
  reset_i,
  data_i,
  v_i,
  credit_o,
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
  output credit_o;
  output v_o;

  bsg_fifo_1r1w_small_credit_on_input
  wrapper
  (
    .data_i(data_i),
    .data_o(data_o),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(v_i),
    .yumi_i(yumi_i),
    .credit_o(credit_o),
    .v_o(v_o)
  );


endmodule



module bsg_circular_ptr_slots_p5_max_add_p1
(
  clk,
  reset_i,
  add_i,
  o,
  n_o
);

  input [0:0] add_i;
  output [2:0] o;
  output [2:0] n_o;
  input clk;
  input reset_i;
  wire [2:0] o,n_o,ptr_nowrap;
  wire N0,N1,N2,N3,N4,N5,N6;
  wire [3:0] ptr_wrap;
  reg o_2_sv2v_reg,o_1_sv2v_reg,o_0_sv2v_reg;
  assign o[2] = o_2_sv2v_reg;
  assign o[1] = o_1_sv2v_reg;
  assign o[0] = o_0_sv2v_reg;
  assign ptr_nowrap = o + add_i[0];
  assign { N5, N4, N3, N2 } = o - { 1'b1, 1'b0, 1'b1 };
  assign ptr_wrap = { N5, N4, N3, N2 } + add_i[0];
  assign n_o = (N0)? ptr_wrap[2:0] : 
               (N1)? ptr_nowrap : 1'b0;
  assign N0 = N6;
  assign N1 = ptr_wrap[3];
  assign N6 = ~ptr_wrap[3];

  always @(posedge clk) begin
    if(reset_i) begin
      o_2_sv2v_reg <= 1'b0;
      o_1_sv2v_reg <= 1'b0;
      o_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      o_2_sv2v_reg <= n_o[2];
      o_1_sv2v_reg <= n_o[1];
      o_0_sv2v_reg <= n_o[0];
    end 
  end


endmodule



module bsg_fifo_tracker_els_p5
(
  clk_i,
  reset_i,
  enq_i,
  deq_i,
  wptr_r_o,
  rptr_r_o,
  rptr_n_o,
  full_o,
  empty_o
);

  output [2:0] wptr_r_o;
  output [2:0] rptr_r_o;
  output [2:0] rptr_n_o;
  input clk_i;
  input reset_i;
  input enq_i;
  input deq_i;
  output full_o;
  output empty_o;
  wire [2:0] wptr_r_o,rptr_r_o,rptr_n_o;
  wire full_o,empty_o,enq_r,deq_r,N0,equal_ptrs,sv2v_dc_1,sv2v_dc_2,sv2v_dc_3;
  reg deq_r_sv2v_reg,enq_r_sv2v_reg;
  assign deq_r = deq_r_sv2v_reg;
  assign enq_r = enq_r_sv2v_reg;

  bsg_circular_ptr_slots_p5_max_add_p1
  rptr
  (
    .clk(clk_i),
    .reset_i(reset_i),
    .add_i(deq_i),
    .o(rptr_r_o),
    .n_o(rptr_n_o)
  );


  bsg_circular_ptr_slots_p5_max_add_p1
  wptr
  (
    .clk(clk_i),
    .reset_i(reset_i),
    .add_i(enq_i),
    .o(wptr_r_o),
    .n_o({ sv2v_dc_1, sv2v_dc_2, sv2v_dc_3 })
  );

  assign equal_ptrs = rptr_r_o == wptr_r_o;
  assign N0 = enq_i | deq_i;
  assign empty_o = equal_ptrs & deq_r;
  assign full_o = equal_ptrs & enq_r;

  always @(posedge clk_i) begin
    if(reset_i) begin
      deq_r_sv2v_reg <= 1'b1;
      enq_r_sv2v_reg <= 1'b0;
    end else if(N0) begin
      deq_r_sv2v_reg <= deq_i;
      enq_r_sv2v_reg <= enq_i;
    end 
  end


endmodule



module bsg_mem_1r1w_synth_width_p16_els_p5_read_write_same_addr_p0
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

  input [2:0] w_addr_i;
  input [15:0] w_data_i;
  input [2:0] r_addr_i;
  output [15:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [15:0] r_data_o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,
  N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38;
  wire [79:0] \nz.mem ;
  reg \nz.mem_79_sv2v_reg ,\nz.mem_78_sv2v_reg ,\nz.mem_77_sv2v_reg ,
  \nz.mem_76_sv2v_reg ,\nz.mem_75_sv2v_reg ,\nz.mem_74_sv2v_reg ,\nz.mem_73_sv2v_reg ,
  \nz.mem_72_sv2v_reg ,\nz.mem_71_sv2v_reg ,\nz.mem_70_sv2v_reg ,\nz.mem_69_sv2v_reg ,
  \nz.mem_68_sv2v_reg ,\nz.mem_67_sv2v_reg ,\nz.mem_66_sv2v_reg ,\nz.mem_65_sv2v_reg ,
  \nz.mem_64_sv2v_reg ,\nz.mem_63_sv2v_reg ,\nz.mem_62_sv2v_reg ,\nz.mem_61_sv2v_reg ,
  \nz.mem_60_sv2v_reg ,\nz.mem_59_sv2v_reg ,\nz.mem_58_sv2v_reg ,
  \nz.mem_57_sv2v_reg ,\nz.mem_56_sv2v_reg ,\nz.mem_55_sv2v_reg ,\nz.mem_54_sv2v_reg ,
  \nz.mem_53_sv2v_reg ,\nz.mem_52_sv2v_reg ,\nz.mem_51_sv2v_reg ,\nz.mem_50_sv2v_reg ,
  \nz.mem_49_sv2v_reg ,\nz.mem_48_sv2v_reg ,\nz.mem_47_sv2v_reg ,\nz.mem_46_sv2v_reg ,
  \nz.mem_45_sv2v_reg ,\nz.mem_44_sv2v_reg ,\nz.mem_43_sv2v_reg ,\nz.mem_42_sv2v_reg ,
  \nz.mem_41_sv2v_reg ,\nz.mem_40_sv2v_reg ,\nz.mem_39_sv2v_reg ,
  \nz.mem_38_sv2v_reg ,\nz.mem_37_sv2v_reg ,\nz.mem_36_sv2v_reg ,\nz.mem_35_sv2v_reg ,
  \nz.mem_34_sv2v_reg ,\nz.mem_33_sv2v_reg ,\nz.mem_32_sv2v_reg ,\nz.mem_31_sv2v_reg ,
  \nz.mem_30_sv2v_reg ,\nz.mem_29_sv2v_reg ,\nz.mem_28_sv2v_reg ,\nz.mem_27_sv2v_reg ,
  \nz.mem_26_sv2v_reg ,\nz.mem_25_sv2v_reg ,\nz.mem_24_sv2v_reg ,\nz.mem_23_sv2v_reg ,
  \nz.mem_22_sv2v_reg ,\nz.mem_21_sv2v_reg ,\nz.mem_20_sv2v_reg ,
  \nz.mem_19_sv2v_reg ,\nz.mem_18_sv2v_reg ,\nz.mem_17_sv2v_reg ,\nz.mem_16_sv2v_reg ,
  \nz.mem_15_sv2v_reg ,\nz.mem_14_sv2v_reg ,\nz.mem_13_sv2v_reg ,\nz.mem_12_sv2v_reg ,
  \nz.mem_11_sv2v_reg ,\nz.mem_10_sv2v_reg ,\nz.mem_9_sv2v_reg ,\nz.mem_8_sv2v_reg ,
  \nz.mem_7_sv2v_reg ,\nz.mem_6_sv2v_reg ,\nz.mem_5_sv2v_reg ,\nz.mem_4_sv2v_reg ,
  \nz.mem_3_sv2v_reg ,\nz.mem_2_sv2v_reg ,\nz.mem_1_sv2v_reg ,\nz.mem_0_sv2v_reg ;
  assign \nz.mem [79] = \nz.mem_79_sv2v_reg ;
  assign \nz.mem [78] = \nz.mem_78_sv2v_reg ;
  assign \nz.mem [77] = \nz.mem_77_sv2v_reg ;
  assign \nz.mem [76] = \nz.mem_76_sv2v_reg ;
  assign \nz.mem [75] = \nz.mem_75_sv2v_reg ;
  assign \nz.mem [74] = \nz.mem_74_sv2v_reg ;
  assign \nz.mem [73] = \nz.mem_73_sv2v_reg ;
  assign \nz.mem [72] = \nz.mem_72_sv2v_reg ;
  assign \nz.mem [71] = \nz.mem_71_sv2v_reg ;
  assign \nz.mem [70] = \nz.mem_70_sv2v_reg ;
  assign \nz.mem [69] = \nz.mem_69_sv2v_reg ;
  assign \nz.mem [68] = \nz.mem_68_sv2v_reg ;
  assign \nz.mem [67] = \nz.mem_67_sv2v_reg ;
  assign \nz.mem [66] = \nz.mem_66_sv2v_reg ;
  assign \nz.mem [65] = \nz.mem_65_sv2v_reg ;
  assign \nz.mem [64] = \nz.mem_64_sv2v_reg ;
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
  assign N35 = N0 & N1;
  assign N0 = ~w_addr_i[0];
  assign N1 = ~w_addr_i[1];
  assign N29 = N35 & w_addr_i[2];
  assign N36 = w_addr_i[0] & w_addr_i[1];
  assign N28 = N36 & N2;
  assign N2 = ~w_addr_i[2];
  assign N37 = N3 & w_addr_i[1];
  assign N3 = ~w_addr_i[0];
  assign N27 = N37 & N4;
  assign N4 = ~w_addr_i[2];
  assign N38 = w_addr_i[0] & N5;
  assign N5 = ~w_addr_i[1];
  assign N26 = N38 & N6;
  assign N6 = ~w_addr_i[2];
  assign N25 = N35 & N7;
  assign N7 = ~w_addr_i[2];
  assign N20 = N8 & N9 & N10;
  assign N8 = ~r_addr_i[2];
  assign N9 = ~r_addr_i[0];
  assign N10 = ~r_addr_i[1];
  assign N21 = r_addr_i[0] & N11;
  assign N11 = ~r_addr_i[1];
  assign N22 = N12 & r_addr_i[1];
  assign N12 = ~r_addr_i[0];
  assign N23 = r_addr_i[0] & r_addr_i[1];
  assign { N34, N33, N32, N31, N30 } = (N13)? { N29, N28, N27, N26, N25 } : 
                                       (N14)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 1'b0;
  assign N13 = w_v_i;
  assign N14 = N24;
  assign r_data_o[15] = (N15)? \nz.mem [15] : 
                        (N16)? \nz.mem [31] : 
                        (N17)? \nz.mem [47] : 
                        (N18)? \nz.mem [63] : 
                        (N19)? \nz.mem [79] : 1'b0;
  assign N15 = N20;
  assign N16 = N21;
  assign N17 = N22;
  assign N18 = N23;
  assign N19 = r_addr_i[2];
  assign r_data_o[14] = (N15)? \nz.mem [14] : 
                        (N16)? \nz.mem [30] : 
                        (N17)? \nz.mem [46] : 
                        (N18)? \nz.mem [62] : 
                        (N19)? \nz.mem [78] : 1'b0;
  assign r_data_o[13] = (N15)? \nz.mem [13] : 
                        (N16)? \nz.mem [29] : 
                        (N17)? \nz.mem [45] : 
                        (N18)? \nz.mem [61] : 
                        (N19)? \nz.mem [77] : 1'b0;
  assign r_data_o[12] = (N15)? \nz.mem [12] : 
                        (N16)? \nz.mem [28] : 
                        (N17)? \nz.mem [44] : 
                        (N18)? \nz.mem [60] : 
                        (N19)? \nz.mem [76] : 1'b0;
  assign r_data_o[11] = (N15)? \nz.mem [11] : 
                        (N16)? \nz.mem [27] : 
                        (N17)? \nz.mem [43] : 
                        (N18)? \nz.mem [59] : 
                        (N19)? \nz.mem [75] : 1'b0;
  assign r_data_o[10] = (N15)? \nz.mem [10] : 
                        (N16)? \nz.mem [26] : 
                        (N17)? \nz.mem [42] : 
                        (N18)? \nz.mem [58] : 
                        (N19)? \nz.mem [74] : 1'b0;
  assign r_data_o[9] = (N15)? \nz.mem [9] : 
                       (N16)? \nz.mem [25] : 
                       (N17)? \nz.mem [41] : 
                       (N18)? \nz.mem [57] : 
                       (N19)? \nz.mem [73] : 1'b0;
  assign r_data_o[8] = (N15)? \nz.mem [8] : 
                       (N16)? \nz.mem [24] : 
                       (N17)? \nz.mem [40] : 
                       (N18)? \nz.mem [56] : 
                       (N19)? \nz.mem [72] : 1'b0;
  assign r_data_o[7] = (N15)? \nz.mem [7] : 
                       (N16)? \nz.mem [23] : 
                       (N17)? \nz.mem [39] : 
                       (N18)? \nz.mem [55] : 
                       (N19)? \nz.mem [71] : 1'b0;
  assign r_data_o[6] = (N15)? \nz.mem [6] : 
                       (N16)? \nz.mem [22] : 
                       (N17)? \nz.mem [38] : 
                       (N18)? \nz.mem [54] : 
                       (N19)? \nz.mem [70] : 1'b0;
  assign r_data_o[5] = (N15)? \nz.mem [5] : 
                       (N16)? \nz.mem [21] : 
                       (N17)? \nz.mem [37] : 
                       (N18)? \nz.mem [53] : 
                       (N19)? \nz.mem [69] : 1'b0;
  assign r_data_o[4] = (N15)? \nz.mem [4] : 
                       (N16)? \nz.mem [20] : 
                       (N17)? \nz.mem [36] : 
                       (N18)? \nz.mem [52] : 
                       (N19)? \nz.mem [68] : 1'b0;
  assign r_data_o[3] = (N15)? \nz.mem [3] : 
                       (N16)? \nz.mem [19] : 
                       (N17)? \nz.mem [35] : 
                       (N18)? \nz.mem [51] : 
                       (N19)? \nz.mem [67] : 1'b0;
  assign r_data_o[2] = (N15)? \nz.mem [2] : 
                       (N16)? \nz.mem [18] : 
                       (N17)? \nz.mem [34] : 
                       (N18)? \nz.mem [50] : 
                       (N19)? \nz.mem [66] : 1'b0;
  assign r_data_o[1] = (N15)? \nz.mem [1] : 
                       (N16)? \nz.mem [17] : 
                       (N17)? \nz.mem [33] : 
                       (N18)? \nz.mem [49] : 
                       (N19)? \nz.mem [65] : 1'b0;
  assign r_data_o[0] = (N15)? \nz.mem [0] : 
                       (N16)? \nz.mem [16] : 
                       (N17)? \nz.mem [32] : 
                       (N18)? \nz.mem [48] : 
                       (N19)? \nz.mem [64] : 1'b0;
  assign N24 = ~w_v_i;

  always @(posedge w_clk_i) begin
    if(N34) begin
      \nz.mem_79_sv2v_reg  <= w_data_i[15];
      \nz.mem_78_sv2v_reg  <= w_data_i[14];
      \nz.mem_77_sv2v_reg  <= w_data_i[13];
      \nz.mem_76_sv2v_reg  <= w_data_i[12];
      \nz.mem_75_sv2v_reg  <= w_data_i[11];
      \nz.mem_74_sv2v_reg  <= w_data_i[10];
      \nz.mem_73_sv2v_reg  <= w_data_i[9];
      \nz.mem_72_sv2v_reg  <= w_data_i[8];
      \nz.mem_71_sv2v_reg  <= w_data_i[7];
      \nz.mem_70_sv2v_reg  <= w_data_i[6];
      \nz.mem_69_sv2v_reg  <= w_data_i[5];
      \nz.mem_68_sv2v_reg  <= w_data_i[4];
      \nz.mem_67_sv2v_reg  <= w_data_i[3];
      \nz.mem_66_sv2v_reg  <= w_data_i[2];
      \nz.mem_65_sv2v_reg  <= w_data_i[1];
      \nz.mem_64_sv2v_reg  <= w_data_i[0];
    end 
    if(N33) begin
      \nz.mem_63_sv2v_reg  <= w_data_i[15];
      \nz.mem_62_sv2v_reg  <= w_data_i[14];
      \nz.mem_61_sv2v_reg  <= w_data_i[13];
      \nz.mem_60_sv2v_reg  <= w_data_i[12];
      \nz.mem_59_sv2v_reg  <= w_data_i[11];
      \nz.mem_58_sv2v_reg  <= w_data_i[10];
      \nz.mem_57_sv2v_reg  <= w_data_i[9];
      \nz.mem_56_sv2v_reg  <= w_data_i[8];
      \nz.mem_55_sv2v_reg  <= w_data_i[7];
      \nz.mem_54_sv2v_reg  <= w_data_i[6];
      \nz.mem_53_sv2v_reg  <= w_data_i[5];
      \nz.mem_52_sv2v_reg  <= w_data_i[4];
      \nz.mem_51_sv2v_reg  <= w_data_i[3];
      \nz.mem_50_sv2v_reg  <= w_data_i[2];
      \nz.mem_49_sv2v_reg  <= w_data_i[1];
      \nz.mem_48_sv2v_reg  <= w_data_i[0];
    end 
    if(N32) begin
      \nz.mem_47_sv2v_reg  <= w_data_i[15];
      \nz.mem_46_sv2v_reg  <= w_data_i[14];
      \nz.mem_45_sv2v_reg  <= w_data_i[13];
      \nz.mem_44_sv2v_reg  <= w_data_i[12];
      \nz.mem_43_sv2v_reg  <= w_data_i[11];
      \nz.mem_42_sv2v_reg  <= w_data_i[10];
      \nz.mem_41_sv2v_reg  <= w_data_i[9];
      \nz.mem_40_sv2v_reg  <= w_data_i[8];
      \nz.mem_39_sv2v_reg  <= w_data_i[7];
      \nz.mem_38_sv2v_reg  <= w_data_i[6];
      \nz.mem_37_sv2v_reg  <= w_data_i[5];
      \nz.mem_36_sv2v_reg  <= w_data_i[4];
      \nz.mem_35_sv2v_reg  <= w_data_i[3];
      \nz.mem_34_sv2v_reg  <= w_data_i[2];
      \nz.mem_33_sv2v_reg  <= w_data_i[1];
      \nz.mem_32_sv2v_reg  <= w_data_i[0];
    end 
    if(N31) begin
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
    if(N30) begin
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



module bsg_mem_1r1w_width_p16_els_p5_read_write_same_addr_p0
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

  input [2:0] w_addr_i;
  input [15:0] w_data_i;
  input [2:0] r_addr_i;
  output [15:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [15:0] r_data_o;

  bsg_mem_1r1w_synth_width_p16_els_p5_read_write_same_addr_p0
  synth
  (
    .w_clk_i(w_clk_i),
    .w_reset_i(w_reset_i),
    .w_v_i(w_v_i),
    .w_addr_i(w_addr_i),
    .w_data_i(w_data_i),
    .r_v_i(r_v_i),
    .r_addr_i(r_addr_i),
    .r_data_o(r_data_o)
  );


endmodule



module bsg_fifo_1r1w_small_unhardened_width_p16_els_p5_ready_THEN_valid_p1
(
  clk_i,
  reset_i,
  v_i,
  ready_o,
  data_i,
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
  wire ready_o,v_o,full,empty,sv2v_dc_1,sv2v_dc_2,sv2v_dc_3;
  wire [2:0] wptr_r,rptr_r;

  bsg_fifo_tracker_els_p5
  ft
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .enq_i(v_i),
    .deq_i(yumi_i),
    .wptr_r_o(wptr_r),
    .rptr_r_o(rptr_r),
    .rptr_n_o({ sv2v_dc_1, sv2v_dc_2, sv2v_dc_3 }),
    .full_o(full),
    .empty_o(empty)
  );


  bsg_mem_1r1w_width_p16_els_p5_read_write_same_addr_p0
  mem_1r1w
  (
    .w_clk_i(clk_i),
    .w_reset_i(reset_i),
    .w_v_i(v_i),
    .w_addr_i(wptr_r),
    .w_data_i(data_i),
    .r_v_i(v_o),
    .r_addr_i(rptr_r),
    .r_data_o(data_o)
  );

  assign ready_o = ~full;
  assign v_o = ~empty;

endmodule



module bsg_fifo_1r1w_small_width_p16_els_p5_harden_p0_ready_THEN_valid_p1
(
  clk_i,
  reset_i,
  v_i,
  ready_o,
  data_i,
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
  wire ready_o,v_o;

  bsg_fifo_1r1w_small_unhardened_width_p16_els_p5_ready_THEN_valid_p1
  \unhardened.un.fifo 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(v_i),
    .ready_o(ready_o),
    .data_i(data_i),
    .v_o(v_o),
    .data_o(data_o),
    .yumi_i(yumi_i)
  );


endmodule



module bsg_fifo_1r1w_small_credit_on_input
(
  clk_i,
  reset_i,
  data_i,
  v_i,
  credit_o,
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
  output credit_o;
  output v_o;
  wire [15:0] data_o;
  wire credit_o,v_o,ready;
  reg credit_o_sv2v_reg;
  assign credit_o = credit_o_sv2v_reg;

  bsg_fifo_1r1w_small_width_p16_els_p5_harden_p0_ready_THEN_valid_p1
  fifo
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(v_i),
    .ready_o(ready),
    .data_i(data_i),
    .v_o(v_o),
    .data_o(data_o),
    .yumi_i(yumi_i)
  );


  always @(posedge clk_i) begin
    if(reset_i) begin
      credit_o_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      credit_o_sv2v_reg <= yumi_i;
    end 
  end


endmodule

