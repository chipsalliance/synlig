

module top
(
  clk_i,
  en_i,
  set_i,
  val_i,
  count_o,
  overflow_o
);

  input [23:0] val_i;
  output [23:0] count_o;
  input clk_i;
  input en_i;
  input set_i;
  output overflow_o;

  bsg_counter_overflow_set_en
  wrapper
  (
    .val_i(val_i),
    .count_o(count_o),
    .clk_i(clk_i),
    .en_i(en_i),
    .set_i(set_i),
    .overflow_o(overflow_o)
  );


endmodule



module bsg_counter_overflow_set_en
(
  clk_i,
  en_i,
  set_i,
  val_i,
  count_o,
  overflow_o
);

  input [23:0] val_i;
  output [23:0] count_o;
  input clk_i;
  input en_i;
  input set_i;
  output overflow_o;
  wire [23:0] count_o;
  wire overflow_o,N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,
  N19,N20,N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,
  N39,N40,N41,N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53,N54,N55,N56,N57,N58,
  N59,N60,N61,N62,N63,N64,N65,N66,N67,N68,N69,N70,N71,N72,N73,N74,N75,N76,N77,N78,
  N79,N80,N81,N82,N83,N84,N85,N86,N87,N88;
  reg count_o_23_sv2v_reg,count_o_22_sv2v_reg,count_o_21_sv2v_reg,count_o_20_sv2v_reg,
  count_o_19_sv2v_reg,count_o_18_sv2v_reg,count_o_17_sv2v_reg,count_o_16_sv2v_reg,
  count_o_15_sv2v_reg,count_o_14_sv2v_reg,count_o_13_sv2v_reg,count_o_12_sv2v_reg,
  count_o_11_sv2v_reg,count_o_10_sv2v_reg,count_o_9_sv2v_reg,count_o_8_sv2v_reg,
  count_o_7_sv2v_reg,count_o_6_sv2v_reg,count_o_5_sv2v_reg,count_o_4_sv2v_reg,
  count_o_3_sv2v_reg,count_o_2_sv2v_reg,count_o_1_sv2v_reg,count_o_0_sv2v_reg;
  assign count_o[23] = count_o_23_sv2v_reg;
  assign count_o[22] = count_o_22_sv2v_reg;
  assign count_o[21] = count_o_21_sv2v_reg;
  assign count_o[20] = count_o_20_sv2v_reg;
  assign count_o[19] = count_o_19_sv2v_reg;
  assign count_o[18] = count_o_18_sv2v_reg;
  assign count_o[17] = count_o_17_sv2v_reg;
  assign count_o[16] = count_o_16_sv2v_reg;
  assign count_o[15] = count_o_15_sv2v_reg;
  assign count_o[14] = count_o_14_sv2v_reg;
  assign count_o[13] = count_o_13_sv2v_reg;
  assign count_o[12] = count_o_12_sv2v_reg;
  assign count_o[11] = count_o_11_sv2v_reg;
  assign count_o[10] = count_o_10_sv2v_reg;
  assign count_o[9] = count_o_9_sv2v_reg;
  assign count_o[8] = count_o_8_sv2v_reg;
  assign count_o[7] = count_o_7_sv2v_reg;
  assign count_o[6] = count_o_6_sv2v_reg;
  assign count_o[5] = count_o_5_sv2v_reg;
  assign count_o[4] = count_o_4_sv2v_reg;
  assign count_o[3] = count_o_3_sv2v_reg;
  assign count_o[2] = count_o_2_sv2v_reg;
  assign count_o[1] = count_o_1_sv2v_reg;
  assign count_o[0] = count_o_0_sv2v_reg;
  assign N58 = ~count_o[23];
  assign N59 = ~count_o[20];
  assign N60 = ~count_o[19];
  assign N61 = ~count_o[15];
  assign N62 = ~count_o[12];
  assign N63 = ~count_o[10];
  assign N64 = ~count_o[9];
  assign N65 = ~count_o[7];
  assign N66 = count_o[22] | N58;
  assign N67 = count_o[21] | N66;
  assign N68 = N59 | N67;
  assign N69 = N60 | N68;
  assign N70 = count_o[18] | N69;
  assign N71 = count_o[17] | N70;
  assign N72 = count_o[16] | N71;
  assign N73 = N61 | N72;
  assign N74 = count_o[14] | N73;
  assign N75 = count_o[13] | N74;
  assign N76 = N62 | N75;
  assign N77 = count_o[11] | N76;
  assign N78 = N63 | N77;
  assign N79 = N64 | N78;
  assign N80 = count_o[8] | N79;
  assign N81 = N65 | N80;
  assign N82 = count_o[6] | N81;
  assign N83 = count_o[5] | N82;
  assign N84 = count_o[4] | N83;
  assign N85 = count_o[3] | N84;
  assign N86 = count_o[2] | N85;
  assign N87 = count_o[1] | N86;
  assign N88 = count_o[0] | N87;
  assign overflow_o = ~N88;
  assign { N28, N27, N26, N25, N24, N23, N22, N21, N20, N19, N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5 } = count_o + 1'b1;
  assign N29 = (N0)? 1'b1 : 
               (N55)? 1'b1 : 
               (N57)? 1'b1 : 
               (N3)? 1'b0 : 1'b0;
  assign N0 = set_i;
  assign { N53, N52, N51, N50, N49, N48, N47, N46, N45, N44, N43, N42, N41, N40, N39, N38, N37, N36, N35, N34, N33, N32, N31, N30 } = (N0)? val_i : 
                                                                                                                                      (N55)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                                                                                                      (N57)? { N28, N27, N26, N25, N24, N23, N22, N21, N20, N19, N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5 } : 1'b0;
  assign N1 = overflow_o | set_i;
  assign N2 = en_i | N1;
  assign N3 = ~N2;
  assign N4 = N57;
  assign N54 = ~set_i;
  assign N55 = overflow_o & N54;
  assign N56 = N54 & N88;
  assign N57 = en_i & N56;

  always @(posedge clk_i) begin
    if(N29) begin
      count_o_23_sv2v_reg <= N53;
      count_o_22_sv2v_reg <= N52;
      count_o_21_sv2v_reg <= N51;
      count_o_20_sv2v_reg <= N50;
      count_o_19_sv2v_reg <= N49;
      count_o_18_sv2v_reg <= N48;
      count_o_17_sv2v_reg <= N47;
      count_o_16_sv2v_reg <= N46;
      count_o_15_sv2v_reg <= N45;
      count_o_14_sv2v_reg <= N44;
      count_o_13_sv2v_reg <= N43;
      count_o_12_sv2v_reg <= N42;
      count_o_11_sv2v_reg <= N41;
      count_o_10_sv2v_reg <= N40;
      count_o_9_sv2v_reg <= N39;
      count_o_8_sv2v_reg <= N38;
      count_o_7_sv2v_reg <= N37;
      count_o_6_sv2v_reg <= N36;
      count_o_5_sv2v_reg <= N35;
      count_o_4_sv2v_reg <= N34;
      count_o_3_sv2v_reg <= N33;
      count_o_2_sv2v_reg <= N32;
      count_o_1_sv2v_reg <= N31;
      count_o_0_sv2v_reg <= N30;
    end 
  end


endmodule

