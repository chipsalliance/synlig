

module top
(
  clk_i,
  reset_i,
  v_i,
  len_i,
  data_i,
  ready_o,
  v_o,
  len_v_o,
  data_o,
  yumi_i
);

  input [2:0] len_i;
  input [79:0] data_i;
  output [15:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output ready_o;
  output v_o;
  output len_v_o;

  bsg_parallel_in_serial_out_dynamic
  wrapper
  (
    .len_i(len_i),
    .data_i(data_i),
    .data_o(data_o),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(v_i),
    .yumi_i(yumi_i),
    .ready_o(ready_o),
    .v_o(v_o),
    .len_v_o(len_v_o)
  );


endmodule



module bsg_mem_1r1w_synth_width_p3_els_p2_read_write_same_addr_p0
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
  input [2:0] w_data_i;
  input [0:0] r_addr_i;
  output [2:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [2:0] r_data_o;
  wire N0,N1,N2,N3,N4,N5,N7,N8;
  wire [5:0] \nz.mem ;
  reg \nz.mem_5_sv2v_reg ,\nz.mem_4_sv2v_reg ,\nz.mem_3_sv2v_reg ,\nz.mem_2_sv2v_reg ,
  \nz.mem_1_sv2v_reg ,\nz.mem_0_sv2v_reg ;
  assign \nz.mem [5] = \nz.mem_5_sv2v_reg ;
  assign \nz.mem [4] = \nz.mem_4_sv2v_reg ;
  assign \nz.mem [3] = \nz.mem_3_sv2v_reg ;
  assign \nz.mem [2] = \nz.mem_2_sv2v_reg ;
  assign \nz.mem [1] = \nz.mem_1_sv2v_reg ;
  assign \nz.mem [0] = \nz.mem_0_sv2v_reg ;
  assign r_data_o[2] = (N3)? \nz.mem [2] : 
                       (N0)? \nz.mem [5] : 1'b0;
  assign N0 = r_addr_i[0];
  assign r_data_o[1] = (N3)? \nz.mem [1] : 
                       (N0)? \nz.mem [4] : 1'b0;
  assign r_data_o[0] = (N3)? \nz.mem [0] : 
                       (N0)? \nz.mem [3] : 1'b0;
  assign N5 = ~w_addr_i[0];
  assign { N8, N7 } = (N1)? { w_addr_i[0:0], N5 } : 
                      (N2)? { 1'b0, 1'b0 } : 1'b0;
  assign N1 = w_v_i;
  assign N2 = N4;
  assign N3 = ~r_addr_i[0];
  assign N4 = ~w_v_i;

  always @(posedge w_clk_i) begin
    if(N8) begin
      \nz.mem_5_sv2v_reg  <= w_data_i[2];
      \nz.mem_4_sv2v_reg  <= w_data_i[1];
      \nz.mem_3_sv2v_reg  <= w_data_i[0];
    end 
    if(N7) begin
      \nz.mem_2_sv2v_reg  <= w_data_i[2];
      \nz.mem_1_sv2v_reg  <= w_data_i[1];
      \nz.mem_0_sv2v_reg  <= w_data_i[0];
    end 
  end


endmodule



module bsg_mem_1r1w_width_p3_els_p2_read_write_same_addr_p0
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
  input [2:0] w_data_i;
  input [0:0] r_addr_i;
  output [2:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [2:0] r_data_o;

  bsg_mem_1r1w_synth_width_p3_els_p2_read_write_same_addr_p0
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



module bsg_two_fifo_width_p3
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

  input [2:0] data_i;
  output [2:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output ready_o;
  output v_o;
  wire [2:0] data_o;
  wire ready_o,v_o,enq_i,tail_r,_0_net_,head_r,empty_r,full_r,N0,N1,N2,N3,N4,N5,N6,N7,
  N8,N9,N10,N11,N12,N13,N14;
  reg full_r_sv2v_reg,tail_r_sv2v_reg,head_r_sv2v_reg,empty_r_sv2v_reg;
  assign full_r = full_r_sv2v_reg;
  assign tail_r = tail_r_sv2v_reg;
  assign head_r = head_r_sv2v_reg;
  assign empty_r = empty_r_sv2v_reg;

  bsg_mem_1r1w_width_p3_els_p2_read_write_same_addr_p0
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



module bsg_mem_1r1w_synth_width_p80_els_p2_read_write_same_addr_p0
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
  input [79:0] w_data_i;
  input [0:0] r_addr_i;
  output [79:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [79:0] r_data_o;
  wire N0,N1,N2,N3,N4,N5,N7,N8;
  wire [159:0] \nz.mem ;
  reg \nz.mem_159_sv2v_reg ,\nz.mem_158_sv2v_reg ,\nz.mem_157_sv2v_reg ,
  \nz.mem_156_sv2v_reg ,\nz.mem_155_sv2v_reg ,\nz.mem_154_sv2v_reg ,\nz.mem_153_sv2v_reg ,
  \nz.mem_152_sv2v_reg ,\nz.mem_151_sv2v_reg ,\nz.mem_150_sv2v_reg ,
  \nz.mem_149_sv2v_reg ,\nz.mem_148_sv2v_reg ,\nz.mem_147_sv2v_reg ,\nz.mem_146_sv2v_reg ,
  \nz.mem_145_sv2v_reg ,\nz.mem_144_sv2v_reg ,\nz.mem_143_sv2v_reg ,\nz.mem_142_sv2v_reg ,
  \nz.mem_141_sv2v_reg ,\nz.mem_140_sv2v_reg ,\nz.mem_139_sv2v_reg ,
  \nz.mem_138_sv2v_reg ,\nz.mem_137_sv2v_reg ,\nz.mem_136_sv2v_reg ,\nz.mem_135_sv2v_reg ,
  \nz.mem_134_sv2v_reg ,\nz.mem_133_sv2v_reg ,\nz.mem_132_sv2v_reg ,\nz.mem_131_sv2v_reg ,
  \nz.mem_130_sv2v_reg ,\nz.mem_129_sv2v_reg ,\nz.mem_128_sv2v_reg ,
  \nz.mem_127_sv2v_reg ,\nz.mem_126_sv2v_reg ,\nz.mem_125_sv2v_reg ,\nz.mem_124_sv2v_reg ,
  \nz.mem_123_sv2v_reg ,\nz.mem_122_sv2v_reg ,\nz.mem_121_sv2v_reg ,\nz.mem_120_sv2v_reg ,
  \nz.mem_119_sv2v_reg ,\nz.mem_118_sv2v_reg ,\nz.mem_117_sv2v_reg ,
  \nz.mem_116_sv2v_reg ,\nz.mem_115_sv2v_reg ,\nz.mem_114_sv2v_reg ,\nz.mem_113_sv2v_reg ,
  \nz.mem_112_sv2v_reg ,\nz.mem_111_sv2v_reg ,\nz.mem_110_sv2v_reg ,
  \nz.mem_109_sv2v_reg ,\nz.mem_108_sv2v_reg ,\nz.mem_107_sv2v_reg ,\nz.mem_106_sv2v_reg ,
  \nz.mem_105_sv2v_reg ,\nz.mem_104_sv2v_reg ,\nz.mem_103_sv2v_reg ,\nz.mem_102_sv2v_reg ,
  \nz.mem_101_sv2v_reg ,\nz.mem_100_sv2v_reg ,\nz.mem_99_sv2v_reg ,
  \nz.mem_98_sv2v_reg ,\nz.mem_97_sv2v_reg ,\nz.mem_96_sv2v_reg ,\nz.mem_95_sv2v_reg ,
  \nz.mem_94_sv2v_reg ,\nz.mem_93_sv2v_reg ,\nz.mem_92_sv2v_reg ,\nz.mem_91_sv2v_reg ,
  \nz.mem_90_sv2v_reg ,\nz.mem_89_sv2v_reg ,\nz.mem_88_sv2v_reg ,\nz.mem_87_sv2v_reg ,
  \nz.mem_86_sv2v_reg ,\nz.mem_85_sv2v_reg ,\nz.mem_84_sv2v_reg ,\nz.mem_83_sv2v_reg ,
  \nz.mem_82_sv2v_reg ,\nz.mem_81_sv2v_reg ,\nz.mem_80_sv2v_reg ,
  \nz.mem_79_sv2v_reg ,\nz.mem_78_sv2v_reg ,\nz.mem_77_sv2v_reg ,\nz.mem_76_sv2v_reg ,
  \nz.mem_75_sv2v_reg ,\nz.mem_74_sv2v_reg ,\nz.mem_73_sv2v_reg ,\nz.mem_72_sv2v_reg ,
  \nz.mem_71_sv2v_reg ,\nz.mem_70_sv2v_reg ,\nz.mem_69_sv2v_reg ,\nz.mem_68_sv2v_reg ,
  \nz.mem_67_sv2v_reg ,\nz.mem_66_sv2v_reg ,\nz.mem_65_sv2v_reg ,\nz.mem_64_sv2v_reg ,
  \nz.mem_63_sv2v_reg ,\nz.mem_62_sv2v_reg ,\nz.mem_61_sv2v_reg ,\nz.mem_60_sv2v_reg ,
  \nz.mem_59_sv2v_reg ,\nz.mem_58_sv2v_reg ,\nz.mem_57_sv2v_reg ,
  \nz.mem_56_sv2v_reg ,\nz.mem_55_sv2v_reg ,\nz.mem_54_sv2v_reg ,\nz.mem_53_sv2v_reg ,
  \nz.mem_52_sv2v_reg ,\nz.mem_51_sv2v_reg ,\nz.mem_50_sv2v_reg ,\nz.mem_49_sv2v_reg ,
  \nz.mem_48_sv2v_reg ,\nz.mem_47_sv2v_reg ,\nz.mem_46_sv2v_reg ,\nz.mem_45_sv2v_reg ,
  \nz.mem_44_sv2v_reg ,\nz.mem_43_sv2v_reg ,\nz.mem_42_sv2v_reg ,\nz.mem_41_sv2v_reg ,
  \nz.mem_40_sv2v_reg ,\nz.mem_39_sv2v_reg ,\nz.mem_38_sv2v_reg ,
  \nz.mem_37_sv2v_reg ,\nz.mem_36_sv2v_reg ,\nz.mem_35_sv2v_reg ,\nz.mem_34_sv2v_reg ,
  \nz.mem_33_sv2v_reg ,\nz.mem_32_sv2v_reg ,\nz.mem_31_sv2v_reg ,\nz.mem_30_sv2v_reg ,
  \nz.mem_29_sv2v_reg ,\nz.mem_28_sv2v_reg ,\nz.mem_27_sv2v_reg ,\nz.mem_26_sv2v_reg ,
  \nz.mem_25_sv2v_reg ,\nz.mem_24_sv2v_reg ,\nz.mem_23_sv2v_reg ,\nz.mem_22_sv2v_reg ,
  \nz.mem_21_sv2v_reg ,\nz.mem_20_sv2v_reg ,\nz.mem_19_sv2v_reg ,
  \nz.mem_18_sv2v_reg ,\nz.mem_17_sv2v_reg ,\nz.mem_16_sv2v_reg ,\nz.mem_15_sv2v_reg ,
  \nz.mem_14_sv2v_reg ,\nz.mem_13_sv2v_reg ,\nz.mem_12_sv2v_reg ,\nz.mem_11_sv2v_reg ,
  \nz.mem_10_sv2v_reg ,\nz.mem_9_sv2v_reg ,\nz.mem_8_sv2v_reg ,\nz.mem_7_sv2v_reg ,
  \nz.mem_6_sv2v_reg ,\nz.mem_5_sv2v_reg ,\nz.mem_4_sv2v_reg ,\nz.mem_3_sv2v_reg ,
  \nz.mem_2_sv2v_reg ,\nz.mem_1_sv2v_reg ,\nz.mem_0_sv2v_reg ;
  assign \nz.mem [159] = \nz.mem_159_sv2v_reg ;
  assign \nz.mem [158] = \nz.mem_158_sv2v_reg ;
  assign \nz.mem [157] = \nz.mem_157_sv2v_reg ;
  assign \nz.mem [156] = \nz.mem_156_sv2v_reg ;
  assign \nz.mem [155] = \nz.mem_155_sv2v_reg ;
  assign \nz.mem [154] = \nz.mem_154_sv2v_reg ;
  assign \nz.mem [153] = \nz.mem_153_sv2v_reg ;
  assign \nz.mem [152] = \nz.mem_152_sv2v_reg ;
  assign \nz.mem [151] = \nz.mem_151_sv2v_reg ;
  assign \nz.mem [150] = \nz.mem_150_sv2v_reg ;
  assign \nz.mem [149] = \nz.mem_149_sv2v_reg ;
  assign \nz.mem [148] = \nz.mem_148_sv2v_reg ;
  assign \nz.mem [147] = \nz.mem_147_sv2v_reg ;
  assign \nz.mem [146] = \nz.mem_146_sv2v_reg ;
  assign \nz.mem [145] = \nz.mem_145_sv2v_reg ;
  assign \nz.mem [144] = \nz.mem_144_sv2v_reg ;
  assign \nz.mem [143] = \nz.mem_143_sv2v_reg ;
  assign \nz.mem [142] = \nz.mem_142_sv2v_reg ;
  assign \nz.mem [141] = \nz.mem_141_sv2v_reg ;
  assign \nz.mem [140] = \nz.mem_140_sv2v_reg ;
  assign \nz.mem [139] = \nz.mem_139_sv2v_reg ;
  assign \nz.mem [138] = \nz.mem_138_sv2v_reg ;
  assign \nz.mem [137] = \nz.mem_137_sv2v_reg ;
  assign \nz.mem [136] = \nz.mem_136_sv2v_reg ;
  assign \nz.mem [135] = \nz.mem_135_sv2v_reg ;
  assign \nz.mem [134] = \nz.mem_134_sv2v_reg ;
  assign \nz.mem [133] = \nz.mem_133_sv2v_reg ;
  assign \nz.mem [132] = \nz.mem_132_sv2v_reg ;
  assign \nz.mem [131] = \nz.mem_131_sv2v_reg ;
  assign \nz.mem [130] = \nz.mem_130_sv2v_reg ;
  assign \nz.mem [129] = \nz.mem_129_sv2v_reg ;
  assign \nz.mem [128] = \nz.mem_128_sv2v_reg ;
  assign \nz.mem [127] = \nz.mem_127_sv2v_reg ;
  assign \nz.mem [126] = \nz.mem_126_sv2v_reg ;
  assign \nz.mem [125] = \nz.mem_125_sv2v_reg ;
  assign \nz.mem [124] = \nz.mem_124_sv2v_reg ;
  assign \nz.mem [123] = \nz.mem_123_sv2v_reg ;
  assign \nz.mem [122] = \nz.mem_122_sv2v_reg ;
  assign \nz.mem [121] = \nz.mem_121_sv2v_reg ;
  assign \nz.mem [120] = \nz.mem_120_sv2v_reg ;
  assign \nz.mem [119] = \nz.mem_119_sv2v_reg ;
  assign \nz.mem [118] = \nz.mem_118_sv2v_reg ;
  assign \nz.mem [117] = \nz.mem_117_sv2v_reg ;
  assign \nz.mem [116] = \nz.mem_116_sv2v_reg ;
  assign \nz.mem [115] = \nz.mem_115_sv2v_reg ;
  assign \nz.mem [114] = \nz.mem_114_sv2v_reg ;
  assign \nz.mem [113] = \nz.mem_113_sv2v_reg ;
  assign \nz.mem [112] = \nz.mem_112_sv2v_reg ;
  assign \nz.mem [111] = \nz.mem_111_sv2v_reg ;
  assign \nz.mem [110] = \nz.mem_110_sv2v_reg ;
  assign \nz.mem [109] = \nz.mem_109_sv2v_reg ;
  assign \nz.mem [108] = \nz.mem_108_sv2v_reg ;
  assign \nz.mem [107] = \nz.mem_107_sv2v_reg ;
  assign \nz.mem [106] = \nz.mem_106_sv2v_reg ;
  assign \nz.mem [105] = \nz.mem_105_sv2v_reg ;
  assign \nz.mem [104] = \nz.mem_104_sv2v_reg ;
  assign \nz.mem [103] = \nz.mem_103_sv2v_reg ;
  assign \nz.mem [102] = \nz.mem_102_sv2v_reg ;
  assign \nz.mem [101] = \nz.mem_101_sv2v_reg ;
  assign \nz.mem [100] = \nz.mem_100_sv2v_reg ;
  assign \nz.mem [99] = \nz.mem_99_sv2v_reg ;
  assign \nz.mem [98] = \nz.mem_98_sv2v_reg ;
  assign \nz.mem [97] = \nz.mem_97_sv2v_reg ;
  assign \nz.mem [96] = \nz.mem_96_sv2v_reg ;
  assign \nz.mem [95] = \nz.mem_95_sv2v_reg ;
  assign \nz.mem [94] = \nz.mem_94_sv2v_reg ;
  assign \nz.mem [93] = \nz.mem_93_sv2v_reg ;
  assign \nz.mem [92] = \nz.mem_92_sv2v_reg ;
  assign \nz.mem [91] = \nz.mem_91_sv2v_reg ;
  assign \nz.mem [90] = \nz.mem_90_sv2v_reg ;
  assign \nz.mem [89] = \nz.mem_89_sv2v_reg ;
  assign \nz.mem [88] = \nz.mem_88_sv2v_reg ;
  assign \nz.mem [87] = \nz.mem_87_sv2v_reg ;
  assign \nz.mem [86] = \nz.mem_86_sv2v_reg ;
  assign \nz.mem [85] = \nz.mem_85_sv2v_reg ;
  assign \nz.mem [84] = \nz.mem_84_sv2v_reg ;
  assign \nz.mem [83] = \nz.mem_83_sv2v_reg ;
  assign \nz.mem [82] = \nz.mem_82_sv2v_reg ;
  assign \nz.mem [81] = \nz.mem_81_sv2v_reg ;
  assign \nz.mem [80] = \nz.mem_80_sv2v_reg ;
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
  assign r_data_o[79] = (N3)? \nz.mem [79] : 
                        (N0)? \nz.mem [159] : 1'b0;
  assign N0 = r_addr_i[0];
  assign r_data_o[78] = (N3)? \nz.mem [78] : 
                        (N0)? \nz.mem [158] : 1'b0;
  assign r_data_o[77] = (N3)? \nz.mem [77] : 
                        (N0)? \nz.mem [157] : 1'b0;
  assign r_data_o[76] = (N3)? \nz.mem [76] : 
                        (N0)? \nz.mem [156] : 1'b0;
  assign r_data_o[75] = (N3)? \nz.mem [75] : 
                        (N0)? \nz.mem [155] : 1'b0;
  assign r_data_o[74] = (N3)? \nz.mem [74] : 
                        (N0)? \nz.mem [154] : 1'b0;
  assign r_data_o[73] = (N3)? \nz.mem [73] : 
                        (N0)? \nz.mem [153] : 1'b0;
  assign r_data_o[72] = (N3)? \nz.mem [72] : 
                        (N0)? \nz.mem [152] : 1'b0;
  assign r_data_o[71] = (N3)? \nz.mem [71] : 
                        (N0)? \nz.mem [151] : 1'b0;
  assign r_data_o[70] = (N3)? \nz.mem [70] : 
                        (N0)? \nz.mem [150] : 1'b0;
  assign r_data_o[69] = (N3)? \nz.mem [69] : 
                        (N0)? \nz.mem [149] : 1'b0;
  assign r_data_o[68] = (N3)? \nz.mem [68] : 
                        (N0)? \nz.mem [148] : 1'b0;
  assign r_data_o[67] = (N3)? \nz.mem [67] : 
                        (N0)? \nz.mem [147] : 1'b0;
  assign r_data_o[66] = (N3)? \nz.mem [66] : 
                        (N0)? \nz.mem [146] : 1'b0;
  assign r_data_o[65] = (N3)? \nz.mem [65] : 
                        (N0)? \nz.mem [145] : 1'b0;
  assign r_data_o[64] = (N3)? \nz.mem [64] : 
                        (N0)? \nz.mem [144] : 1'b0;
  assign r_data_o[63] = (N3)? \nz.mem [63] : 
                        (N0)? \nz.mem [143] : 1'b0;
  assign r_data_o[62] = (N3)? \nz.mem [62] : 
                        (N0)? \nz.mem [142] : 1'b0;
  assign r_data_o[61] = (N3)? \nz.mem [61] : 
                        (N0)? \nz.mem [141] : 1'b0;
  assign r_data_o[60] = (N3)? \nz.mem [60] : 
                        (N0)? \nz.mem [140] : 1'b0;
  assign r_data_o[59] = (N3)? \nz.mem [59] : 
                        (N0)? \nz.mem [139] : 1'b0;
  assign r_data_o[58] = (N3)? \nz.mem [58] : 
                        (N0)? \nz.mem [138] : 1'b0;
  assign r_data_o[57] = (N3)? \nz.mem [57] : 
                        (N0)? \nz.mem [137] : 1'b0;
  assign r_data_o[56] = (N3)? \nz.mem [56] : 
                        (N0)? \nz.mem [136] : 1'b0;
  assign r_data_o[55] = (N3)? \nz.mem [55] : 
                        (N0)? \nz.mem [135] : 1'b0;
  assign r_data_o[54] = (N3)? \nz.mem [54] : 
                        (N0)? \nz.mem [134] : 1'b0;
  assign r_data_o[53] = (N3)? \nz.mem [53] : 
                        (N0)? \nz.mem [133] : 1'b0;
  assign r_data_o[52] = (N3)? \nz.mem [52] : 
                        (N0)? \nz.mem [132] : 1'b0;
  assign r_data_o[51] = (N3)? \nz.mem [51] : 
                        (N0)? \nz.mem [131] : 1'b0;
  assign r_data_o[50] = (N3)? \nz.mem [50] : 
                        (N0)? \nz.mem [130] : 1'b0;
  assign r_data_o[49] = (N3)? \nz.mem [49] : 
                        (N0)? \nz.mem [129] : 1'b0;
  assign r_data_o[48] = (N3)? \nz.mem [48] : 
                        (N0)? \nz.mem [128] : 1'b0;
  assign r_data_o[47] = (N3)? \nz.mem [47] : 
                        (N0)? \nz.mem [127] : 1'b0;
  assign r_data_o[46] = (N3)? \nz.mem [46] : 
                        (N0)? \nz.mem [126] : 1'b0;
  assign r_data_o[45] = (N3)? \nz.mem [45] : 
                        (N0)? \nz.mem [125] : 1'b0;
  assign r_data_o[44] = (N3)? \nz.mem [44] : 
                        (N0)? \nz.mem [124] : 1'b0;
  assign r_data_o[43] = (N3)? \nz.mem [43] : 
                        (N0)? \nz.mem [123] : 1'b0;
  assign r_data_o[42] = (N3)? \nz.mem [42] : 
                        (N0)? \nz.mem [122] : 1'b0;
  assign r_data_o[41] = (N3)? \nz.mem [41] : 
                        (N0)? \nz.mem [121] : 1'b0;
  assign r_data_o[40] = (N3)? \nz.mem [40] : 
                        (N0)? \nz.mem [120] : 1'b0;
  assign r_data_o[39] = (N3)? \nz.mem [39] : 
                        (N0)? \nz.mem [119] : 1'b0;
  assign r_data_o[38] = (N3)? \nz.mem [38] : 
                        (N0)? \nz.mem [118] : 1'b0;
  assign r_data_o[37] = (N3)? \nz.mem [37] : 
                        (N0)? \nz.mem [117] : 1'b0;
  assign r_data_o[36] = (N3)? \nz.mem [36] : 
                        (N0)? \nz.mem [116] : 1'b0;
  assign r_data_o[35] = (N3)? \nz.mem [35] : 
                        (N0)? \nz.mem [115] : 1'b0;
  assign r_data_o[34] = (N3)? \nz.mem [34] : 
                        (N0)? \nz.mem [114] : 1'b0;
  assign r_data_o[33] = (N3)? \nz.mem [33] : 
                        (N0)? \nz.mem [113] : 1'b0;
  assign r_data_o[32] = (N3)? \nz.mem [32] : 
                        (N0)? \nz.mem [112] : 1'b0;
  assign r_data_o[31] = (N3)? \nz.mem [31] : 
                        (N0)? \nz.mem [111] : 1'b0;
  assign r_data_o[30] = (N3)? \nz.mem [30] : 
                        (N0)? \nz.mem [110] : 1'b0;
  assign r_data_o[29] = (N3)? \nz.mem [29] : 
                        (N0)? \nz.mem [109] : 1'b0;
  assign r_data_o[28] = (N3)? \nz.mem [28] : 
                        (N0)? \nz.mem [108] : 1'b0;
  assign r_data_o[27] = (N3)? \nz.mem [27] : 
                        (N0)? \nz.mem [107] : 1'b0;
  assign r_data_o[26] = (N3)? \nz.mem [26] : 
                        (N0)? \nz.mem [106] : 1'b0;
  assign r_data_o[25] = (N3)? \nz.mem [25] : 
                        (N0)? \nz.mem [105] : 1'b0;
  assign r_data_o[24] = (N3)? \nz.mem [24] : 
                        (N0)? \nz.mem [104] : 1'b0;
  assign r_data_o[23] = (N3)? \nz.mem [23] : 
                        (N0)? \nz.mem [103] : 1'b0;
  assign r_data_o[22] = (N3)? \nz.mem [22] : 
                        (N0)? \nz.mem [102] : 1'b0;
  assign r_data_o[21] = (N3)? \nz.mem [21] : 
                        (N0)? \nz.mem [101] : 1'b0;
  assign r_data_o[20] = (N3)? \nz.mem [20] : 
                        (N0)? \nz.mem [100] : 1'b0;
  assign r_data_o[19] = (N3)? \nz.mem [19] : 
                        (N0)? \nz.mem [99] : 1'b0;
  assign r_data_o[18] = (N3)? \nz.mem [18] : 
                        (N0)? \nz.mem [98] : 1'b0;
  assign r_data_o[17] = (N3)? \nz.mem [17] : 
                        (N0)? \nz.mem [97] : 1'b0;
  assign r_data_o[16] = (N3)? \nz.mem [16] : 
                        (N0)? \nz.mem [96] : 1'b0;
  assign r_data_o[15] = (N3)? \nz.mem [15] : 
                        (N0)? \nz.mem [95] : 1'b0;
  assign r_data_o[14] = (N3)? \nz.mem [14] : 
                        (N0)? \nz.mem [94] : 1'b0;
  assign r_data_o[13] = (N3)? \nz.mem [13] : 
                        (N0)? \nz.mem [93] : 1'b0;
  assign r_data_o[12] = (N3)? \nz.mem [12] : 
                        (N0)? \nz.mem [92] : 1'b0;
  assign r_data_o[11] = (N3)? \nz.mem [11] : 
                        (N0)? \nz.mem [91] : 1'b0;
  assign r_data_o[10] = (N3)? \nz.mem [10] : 
                        (N0)? \nz.mem [90] : 1'b0;
  assign r_data_o[9] = (N3)? \nz.mem [9] : 
                       (N0)? \nz.mem [89] : 1'b0;
  assign r_data_o[8] = (N3)? \nz.mem [8] : 
                       (N0)? \nz.mem [88] : 1'b0;
  assign r_data_o[7] = (N3)? \nz.mem [7] : 
                       (N0)? \nz.mem [87] : 1'b0;
  assign r_data_o[6] = (N3)? \nz.mem [6] : 
                       (N0)? \nz.mem [86] : 1'b0;
  assign r_data_o[5] = (N3)? \nz.mem [5] : 
                       (N0)? \nz.mem [85] : 1'b0;
  assign r_data_o[4] = (N3)? \nz.mem [4] : 
                       (N0)? \nz.mem [84] : 1'b0;
  assign r_data_o[3] = (N3)? \nz.mem [3] : 
                       (N0)? \nz.mem [83] : 1'b0;
  assign r_data_o[2] = (N3)? \nz.mem [2] : 
                       (N0)? \nz.mem [82] : 1'b0;
  assign r_data_o[1] = (N3)? \nz.mem [1] : 
                       (N0)? \nz.mem [81] : 1'b0;
  assign r_data_o[0] = (N3)? \nz.mem [0] : 
                       (N0)? \nz.mem [80] : 1'b0;
  assign N5 = ~w_addr_i[0];
  assign { N8, N7 } = (N1)? { w_addr_i[0:0], N5 } : 
                      (N2)? { 1'b0, 1'b0 } : 1'b0;
  assign N1 = w_v_i;
  assign N2 = N4;
  assign N3 = ~r_addr_i[0];
  assign N4 = ~w_v_i;

  always @(posedge w_clk_i) begin
    if(N8) begin
      \nz.mem_159_sv2v_reg  <= w_data_i[79];
      \nz.mem_158_sv2v_reg  <= w_data_i[78];
      \nz.mem_157_sv2v_reg  <= w_data_i[77];
      \nz.mem_156_sv2v_reg  <= w_data_i[76];
      \nz.mem_155_sv2v_reg  <= w_data_i[75];
      \nz.mem_154_sv2v_reg  <= w_data_i[74];
      \nz.mem_153_sv2v_reg  <= w_data_i[73];
      \nz.mem_152_sv2v_reg  <= w_data_i[72];
      \nz.mem_151_sv2v_reg  <= w_data_i[71];
      \nz.mem_150_sv2v_reg  <= w_data_i[70];
      \nz.mem_149_sv2v_reg  <= w_data_i[69];
      \nz.mem_148_sv2v_reg  <= w_data_i[68];
      \nz.mem_147_sv2v_reg  <= w_data_i[67];
      \nz.mem_146_sv2v_reg  <= w_data_i[66];
      \nz.mem_145_sv2v_reg  <= w_data_i[65];
      \nz.mem_144_sv2v_reg  <= w_data_i[64];
      \nz.mem_143_sv2v_reg  <= w_data_i[63];
      \nz.mem_142_sv2v_reg  <= w_data_i[62];
      \nz.mem_141_sv2v_reg  <= w_data_i[61];
      \nz.mem_140_sv2v_reg  <= w_data_i[60];
      \nz.mem_139_sv2v_reg  <= w_data_i[59];
      \nz.mem_138_sv2v_reg  <= w_data_i[58];
      \nz.mem_137_sv2v_reg  <= w_data_i[57];
      \nz.mem_136_sv2v_reg  <= w_data_i[56];
      \nz.mem_135_sv2v_reg  <= w_data_i[55];
      \nz.mem_134_sv2v_reg  <= w_data_i[54];
      \nz.mem_133_sv2v_reg  <= w_data_i[53];
      \nz.mem_132_sv2v_reg  <= w_data_i[52];
      \nz.mem_131_sv2v_reg  <= w_data_i[51];
      \nz.mem_130_sv2v_reg  <= w_data_i[50];
      \nz.mem_129_sv2v_reg  <= w_data_i[49];
      \nz.mem_128_sv2v_reg  <= w_data_i[48];
      \nz.mem_127_sv2v_reg  <= w_data_i[47];
      \nz.mem_126_sv2v_reg  <= w_data_i[46];
      \nz.mem_125_sv2v_reg  <= w_data_i[45];
      \nz.mem_124_sv2v_reg  <= w_data_i[44];
      \nz.mem_123_sv2v_reg  <= w_data_i[43];
      \nz.mem_122_sv2v_reg  <= w_data_i[42];
      \nz.mem_121_sv2v_reg  <= w_data_i[41];
      \nz.mem_120_sv2v_reg  <= w_data_i[40];
      \nz.mem_119_sv2v_reg  <= w_data_i[39];
      \nz.mem_118_sv2v_reg  <= w_data_i[38];
      \nz.mem_117_sv2v_reg  <= w_data_i[37];
      \nz.mem_116_sv2v_reg  <= w_data_i[36];
      \nz.mem_115_sv2v_reg  <= w_data_i[35];
      \nz.mem_114_sv2v_reg  <= w_data_i[34];
      \nz.mem_113_sv2v_reg  <= w_data_i[33];
      \nz.mem_112_sv2v_reg  <= w_data_i[32];
      \nz.mem_111_sv2v_reg  <= w_data_i[31];
      \nz.mem_110_sv2v_reg  <= w_data_i[30];
      \nz.mem_109_sv2v_reg  <= w_data_i[29];
      \nz.mem_108_sv2v_reg  <= w_data_i[28];
      \nz.mem_107_sv2v_reg  <= w_data_i[27];
      \nz.mem_106_sv2v_reg  <= w_data_i[26];
      \nz.mem_105_sv2v_reg  <= w_data_i[25];
      \nz.mem_104_sv2v_reg  <= w_data_i[24];
      \nz.mem_103_sv2v_reg  <= w_data_i[23];
      \nz.mem_102_sv2v_reg  <= w_data_i[22];
      \nz.mem_101_sv2v_reg  <= w_data_i[21];
      \nz.mem_100_sv2v_reg  <= w_data_i[20];
      \nz.mem_99_sv2v_reg  <= w_data_i[19];
      \nz.mem_98_sv2v_reg  <= w_data_i[18];
      \nz.mem_97_sv2v_reg  <= w_data_i[17];
      \nz.mem_96_sv2v_reg  <= w_data_i[16];
      \nz.mem_95_sv2v_reg  <= w_data_i[15];
      \nz.mem_94_sv2v_reg  <= w_data_i[14];
      \nz.mem_93_sv2v_reg  <= w_data_i[13];
      \nz.mem_92_sv2v_reg  <= w_data_i[12];
      \nz.mem_91_sv2v_reg  <= w_data_i[11];
      \nz.mem_90_sv2v_reg  <= w_data_i[10];
      \nz.mem_89_sv2v_reg  <= w_data_i[9];
      \nz.mem_88_sv2v_reg  <= w_data_i[8];
      \nz.mem_87_sv2v_reg  <= w_data_i[7];
      \nz.mem_86_sv2v_reg  <= w_data_i[6];
      \nz.mem_85_sv2v_reg  <= w_data_i[5];
      \nz.mem_84_sv2v_reg  <= w_data_i[4];
      \nz.mem_83_sv2v_reg  <= w_data_i[3];
      \nz.mem_82_sv2v_reg  <= w_data_i[2];
      \nz.mem_81_sv2v_reg  <= w_data_i[1];
      \nz.mem_80_sv2v_reg  <= w_data_i[0];
    end 
    if(N7) begin
      \nz.mem_79_sv2v_reg  <= w_data_i[79];
      \nz.mem_78_sv2v_reg  <= w_data_i[78];
      \nz.mem_77_sv2v_reg  <= w_data_i[77];
      \nz.mem_76_sv2v_reg  <= w_data_i[76];
      \nz.mem_75_sv2v_reg  <= w_data_i[75];
      \nz.mem_74_sv2v_reg  <= w_data_i[74];
      \nz.mem_73_sv2v_reg  <= w_data_i[73];
      \nz.mem_72_sv2v_reg  <= w_data_i[72];
      \nz.mem_71_sv2v_reg  <= w_data_i[71];
      \nz.mem_70_sv2v_reg  <= w_data_i[70];
      \nz.mem_69_sv2v_reg  <= w_data_i[69];
      \nz.mem_68_sv2v_reg  <= w_data_i[68];
      \nz.mem_67_sv2v_reg  <= w_data_i[67];
      \nz.mem_66_sv2v_reg  <= w_data_i[66];
      \nz.mem_65_sv2v_reg  <= w_data_i[65];
      \nz.mem_64_sv2v_reg  <= w_data_i[64];
      \nz.mem_63_sv2v_reg  <= w_data_i[63];
      \nz.mem_62_sv2v_reg  <= w_data_i[62];
      \nz.mem_61_sv2v_reg  <= w_data_i[61];
      \nz.mem_60_sv2v_reg  <= w_data_i[60];
      \nz.mem_59_sv2v_reg  <= w_data_i[59];
      \nz.mem_58_sv2v_reg  <= w_data_i[58];
      \nz.mem_57_sv2v_reg  <= w_data_i[57];
      \nz.mem_56_sv2v_reg  <= w_data_i[56];
      \nz.mem_55_sv2v_reg  <= w_data_i[55];
      \nz.mem_54_sv2v_reg  <= w_data_i[54];
      \nz.mem_53_sv2v_reg  <= w_data_i[53];
      \nz.mem_52_sv2v_reg  <= w_data_i[52];
      \nz.mem_51_sv2v_reg  <= w_data_i[51];
      \nz.mem_50_sv2v_reg  <= w_data_i[50];
      \nz.mem_49_sv2v_reg  <= w_data_i[49];
      \nz.mem_48_sv2v_reg  <= w_data_i[48];
      \nz.mem_47_sv2v_reg  <= w_data_i[47];
      \nz.mem_46_sv2v_reg  <= w_data_i[46];
      \nz.mem_45_sv2v_reg  <= w_data_i[45];
      \nz.mem_44_sv2v_reg  <= w_data_i[44];
      \nz.mem_43_sv2v_reg  <= w_data_i[43];
      \nz.mem_42_sv2v_reg  <= w_data_i[42];
      \nz.mem_41_sv2v_reg  <= w_data_i[41];
      \nz.mem_40_sv2v_reg  <= w_data_i[40];
      \nz.mem_39_sv2v_reg  <= w_data_i[39];
      \nz.mem_38_sv2v_reg  <= w_data_i[38];
      \nz.mem_37_sv2v_reg  <= w_data_i[37];
      \nz.mem_36_sv2v_reg  <= w_data_i[36];
      \nz.mem_35_sv2v_reg  <= w_data_i[35];
      \nz.mem_34_sv2v_reg  <= w_data_i[34];
      \nz.mem_33_sv2v_reg  <= w_data_i[33];
      \nz.mem_32_sv2v_reg  <= w_data_i[32];
      \nz.mem_31_sv2v_reg  <= w_data_i[31];
      \nz.mem_30_sv2v_reg  <= w_data_i[30];
      \nz.mem_29_sv2v_reg  <= w_data_i[29];
      \nz.mem_28_sv2v_reg  <= w_data_i[28];
      \nz.mem_27_sv2v_reg  <= w_data_i[27];
      \nz.mem_26_sv2v_reg  <= w_data_i[26];
      \nz.mem_25_sv2v_reg  <= w_data_i[25];
      \nz.mem_24_sv2v_reg  <= w_data_i[24];
      \nz.mem_23_sv2v_reg  <= w_data_i[23];
      \nz.mem_22_sv2v_reg  <= w_data_i[22];
      \nz.mem_21_sv2v_reg  <= w_data_i[21];
      \nz.mem_20_sv2v_reg  <= w_data_i[20];
      \nz.mem_19_sv2v_reg  <= w_data_i[19];
      \nz.mem_18_sv2v_reg  <= w_data_i[18];
      \nz.mem_17_sv2v_reg  <= w_data_i[17];
      \nz.mem_16_sv2v_reg  <= w_data_i[16];
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



module bsg_mem_1r1w_width_p80_els_p2_read_write_same_addr_p0
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
  input [79:0] w_data_i;
  input [0:0] r_addr_i;
  output [79:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [79:0] r_data_o;

  bsg_mem_1r1w_synth_width_p80_els_p2_read_write_same_addr_p0
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



module bsg_two_fifo_width_p80
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

  input [79:0] data_i;
  output [79:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output ready_o;
  output v_o;
  wire [79:0] data_o;
  wire ready_o,v_o,enq_i,tail_r,_0_net_,head_r,empty_r,full_r,N0,N1,N2,N3,N4,N5,N6,N7,
  N8,N9,N10,N11,N12,N13,N14;
  reg full_r_sv2v_reg,tail_r_sv2v_reg,head_r_sv2v_reg,empty_r_sv2v_reg;
  assign full_r = full_r_sv2v_reg;
  assign tail_r = tail_r_sv2v_reg;
  assign head_r = head_r_sv2v_reg;
  assign empty_r = empty_r_sv2v_reg;

  bsg_mem_1r1w_width_p80_els_p2_read_write_same_addr_p0
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



module bsg_counter_clear_up_max_val_p4_init_val_p0
(
  clk_i,
  reset_i,
  clear_i,
  up_i,
  count_o
);

  output [2:0] count_o;
  input clk_i;
  input reset_i;
  input clear_i;
  input up_i;
  wire [2:0] count_o;
  wire N0,N1,N4,N5,N6,N8,N9,N10,N11,N12,N13,N14,N15,N2,N3,N7,N30,N16;
  reg count_o_2_sv2v_reg,count_o_1_sv2v_reg,count_o_0_sv2v_reg;
  assign count_o[2] = count_o_2_sv2v_reg;
  assign count_o[1] = count_o_1_sv2v_reg;
  assign count_o[0] = count_o_0_sv2v_reg;
  assign N16 = reset_i | clear_i;
  assign { N8, N6, N5 } = count_o + 1'b1;
  assign N9 = (N0)? 1'b1 : 
              (N7)? 1'b1 : 
              (N3)? 1'b0 : 1'b0;
  assign N0 = clear_i;
  assign N11 = (N1)? 1'b1 : 
               (N30)? 1'b0 : 1'b0;
  assign N1 = up_i;
  assign N10 = (N0)? up_i : 
               (N7)? N5 : 1'b0;
  assign N4 = N15;
  assign N12 = ~reset_i;
  assign N13 = ~clear_i;
  assign N14 = N12 & N13;
  assign N15 = up_i & N14;
  assign N2 = up_i | clear_i;
  assign N3 = ~N2;
  assign N7 = up_i & N13;
  assign N30 = ~up_i;

  always @(posedge clk_i) begin
    if(N16) begin
      count_o_2_sv2v_reg <= 1'b0;
      count_o_1_sv2v_reg <= 1'b0;
    end else if(N11) begin
      count_o_2_sv2v_reg <= N8;
      count_o_1_sv2v_reg <= N6;
    end 
    if(reset_i) begin
      count_o_0_sv2v_reg <= 1'b0;
    end else if(N9) begin
      count_o_0_sv2v_reg <= N10;
    end 
  end


endmodule



module bsg_mux_width_p16_els_p5
(
  data_i,
  sel_i,
  data_o
);

  input [79:0] data_i;
  input [2:0] sel_i;
  output [15:0] data_o;
  wire [15:0] data_o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13;
  assign N10 = N0 & N1 & N2;
  assign N0 = ~sel_i[2];
  assign N1 = ~sel_i[0];
  assign N2 = ~sel_i[1];
  assign N11 = sel_i[0] & N3;
  assign N3 = ~sel_i[1];
  assign N12 = N4 & sel_i[1];
  assign N4 = ~sel_i[0];
  assign N13 = sel_i[0] & sel_i[1];
  assign data_o[15] = (N5)? data_i[15] : 
                      (N6)? data_i[31] : 
                      (N7)? data_i[47] : 
                      (N8)? data_i[63] : 
                      (N9)? data_i[79] : 1'b0;
  assign N5 = N10;
  assign N6 = N11;
  assign N7 = N12;
  assign N8 = N13;
  assign N9 = sel_i[2];
  assign data_o[14] = (N5)? data_i[14] : 
                      (N6)? data_i[30] : 
                      (N7)? data_i[46] : 
                      (N8)? data_i[62] : 
                      (N9)? data_i[78] : 1'b0;
  assign data_o[13] = (N5)? data_i[13] : 
                      (N6)? data_i[29] : 
                      (N7)? data_i[45] : 
                      (N8)? data_i[61] : 
                      (N9)? data_i[77] : 1'b0;
  assign data_o[12] = (N5)? data_i[12] : 
                      (N6)? data_i[28] : 
                      (N7)? data_i[44] : 
                      (N8)? data_i[60] : 
                      (N9)? data_i[76] : 1'b0;
  assign data_o[11] = (N5)? data_i[11] : 
                      (N6)? data_i[27] : 
                      (N7)? data_i[43] : 
                      (N8)? data_i[59] : 
                      (N9)? data_i[75] : 1'b0;
  assign data_o[10] = (N5)? data_i[10] : 
                      (N6)? data_i[26] : 
                      (N7)? data_i[42] : 
                      (N8)? data_i[58] : 
                      (N9)? data_i[74] : 1'b0;
  assign data_o[9] = (N5)? data_i[9] : 
                     (N6)? data_i[25] : 
                     (N7)? data_i[41] : 
                     (N8)? data_i[57] : 
                     (N9)? data_i[73] : 1'b0;
  assign data_o[8] = (N5)? data_i[8] : 
                     (N6)? data_i[24] : 
                     (N7)? data_i[40] : 
                     (N8)? data_i[56] : 
                     (N9)? data_i[72] : 1'b0;
  assign data_o[7] = (N5)? data_i[7] : 
                     (N6)? data_i[23] : 
                     (N7)? data_i[39] : 
                     (N8)? data_i[55] : 
                     (N9)? data_i[71] : 1'b0;
  assign data_o[6] = (N5)? data_i[6] : 
                     (N6)? data_i[22] : 
                     (N7)? data_i[38] : 
                     (N8)? data_i[54] : 
                     (N9)? data_i[70] : 1'b0;
  assign data_o[5] = (N5)? data_i[5] : 
                     (N6)? data_i[21] : 
                     (N7)? data_i[37] : 
                     (N8)? data_i[53] : 
                     (N9)? data_i[69] : 1'b0;
  assign data_o[4] = (N5)? data_i[4] : 
                     (N6)? data_i[20] : 
                     (N7)? data_i[36] : 
                     (N8)? data_i[52] : 
                     (N9)? data_i[68] : 1'b0;
  assign data_o[3] = (N5)? data_i[3] : 
                     (N6)? data_i[19] : 
                     (N7)? data_i[35] : 
                     (N8)? data_i[51] : 
                     (N9)? data_i[67] : 1'b0;
  assign data_o[2] = (N5)? data_i[2] : 
                     (N6)? data_i[18] : 
                     (N7)? data_i[34] : 
                     (N8)? data_i[50] : 
                     (N9)? data_i[66] : 1'b0;
  assign data_o[1] = (N5)? data_i[1] : 
                     (N6)? data_i[17] : 
                     (N7)? data_i[33] : 
                     (N8)? data_i[49] : 
                     (N9)? data_i[65] : 1'b0;
  assign data_o[0] = (N5)? data_i[0] : 
                     (N6)? data_i[16] : 
                     (N7)? data_i[32] : 
                     (N8)? data_i[48] : 
                     (N9)? data_i[64] : 1'b0;

endmodule



module bsg_parallel_in_serial_out_dynamic
(
  clk_i,
  reset_i,
  v_i,
  len_i,
  data_i,
  ready_o,
  v_o,
  len_v_o,
  data_o,
  yumi_i
);

  input [2:0] len_i;
  input [79:0] data_i;
  output [15:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output ready_o;
  output v_o;
  output len_v_o;
  wire [15:0] data_o;
  wire ready_o,v_o,len_v_o,count_r_is_last,up_li,clear_li,N0,N1,N3;
  wire [2:0] len_lo,count_lo;
  wire [79:0] fifo_data_lo;

  bsg_two_fifo_width_p3
  go_fifo
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(ready_o),
    .data_i(len_i),
    .v_i(v_i),
    .v_o(v_o),
    .data_o(len_lo),
    .yumi_i(clear_li)
  );


  bsg_two_fifo_width_p80
  data_fifo
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .data_i(data_i),
    .v_i(v_i),
    .data_o(fifo_data_lo),
    .yumi_i(clear_li)
  );

  assign count_r_is_last = count_lo == len_lo;

  bsg_counter_clear_up_max_val_p4_init_val_p0
  ctr
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .clear_i(clear_li),
    .up_i(up_li),
    .count_o(count_lo)
  );


  bsg_mux_width_p16_els_p5
  data_mux
  (
    .data_i(fifo_data_lo),
    .sel_i(count_lo),
    .data_o(data_o)
  );

  assign N0 = count_lo[1] | count_lo[2];
  assign N1 = count_lo[0] | N0;
  assign len_v_o = ~N1;
  assign up_li = yumi_i & N3;
  assign N3 = ~count_r_is_last;
  assign clear_li = yumi_i & count_r_is_last;

endmodule

