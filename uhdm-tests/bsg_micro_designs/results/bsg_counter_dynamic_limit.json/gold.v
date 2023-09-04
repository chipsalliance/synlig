

module top
(
  clk_i,
  reset_i,
  limit_i,
  counter_o
);

  input [15:0] limit_i;
  output [15:0] counter_o;
  input clk_i;
  input reset_i;

  bsg_counter_dynamic_limit
  wrapper
  (
    .limit_i(limit_i),
    .counter_o(counter_o),
    .clk_i(clk_i),
    .reset_i(reset_i)
  );


endmodule



module bsg_counter_dynamic_limit
(
  clk_i,
  reset_i,
  limit_i,
  counter_o
);

  input [15:0] limit_i;
  output [15:0] counter_o;
  input clk_i;
  input reset_i;
  wire [15:0] counter_o;
  wire N0,N1,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,N22,
  N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N2;
  reg counter_o_15_sv2v_reg,counter_o_14_sv2v_reg,counter_o_13_sv2v_reg,
  counter_o_12_sv2v_reg,counter_o_11_sv2v_reg,counter_o_10_sv2v_reg,counter_o_9_sv2v_reg,
  counter_o_8_sv2v_reg,counter_o_7_sv2v_reg,counter_o_6_sv2v_reg,counter_o_5_sv2v_reg,
  counter_o_4_sv2v_reg,counter_o_3_sv2v_reg,counter_o_2_sv2v_reg,
  counter_o_1_sv2v_reg,counter_o_0_sv2v_reg;
  assign counter_o[15] = counter_o_15_sv2v_reg;
  assign counter_o[14] = counter_o_14_sv2v_reg;
  assign counter_o[13] = counter_o_13_sv2v_reg;
  assign counter_o[12] = counter_o_12_sv2v_reg;
  assign counter_o[11] = counter_o_11_sv2v_reg;
  assign counter_o[10] = counter_o_10_sv2v_reg;
  assign counter_o[9] = counter_o_9_sv2v_reg;
  assign counter_o[8] = counter_o_8_sv2v_reg;
  assign counter_o[7] = counter_o_7_sv2v_reg;
  assign counter_o[6] = counter_o_6_sv2v_reg;
  assign counter_o[5] = counter_o_5_sv2v_reg;
  assign counter_o[4] = counter_o_4_sv2v_reg;
  assign counter_o[3] = counter_o_3_sv2v_reg;
  assign counter_o[2] = counter_o_2_sv2v_reg;
  assign counter_o[1] = counter_o_1_sv2v_reg;
  assign counter_o[0] = counter_o_0_sv2v_reg;
  assign N1 = counter_o == limit_i;
  assign { N20, N19, N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5 } = counter_o + 1'b1;
  assign { N36, N35, N34, N33, N32, N31, N30, N29, N28, N27, N26, N25, N24, N23, N22, N21 } = (N0)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                                                              (N2)? { N20, N19, N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5 } : 1'b0;
  assign N0 = N1;
  assign N3 = N1 | reset_i;
  assign N4 = ~N3;
  assign N2 = ~N1;

  always @(posedge clk_i) begin
    if(reset_i) begin
      counter_o_15_sv2v_reg <= 1'b0;
      counter_o_14_sv2v_reg <= 1'b0;
      counter_o_13_sv2v_reg <= 1'b0;
      counter_o_12_sv2v_reg <= 1'b0;
      counter_o_11_sv2v_reg <= 1'b0;
      counter_o_10_sv2v_reg <= 1'b0;
      counter_o_9_sv2v_reg <= 1'b0;
      counter_o_8_sv2v_reg <= 1'b0;
      counter_o_7_sv2v_reg <= 1'b0;
      counter_o_6_sv2v_reg <= 1'b0;
      counter_o_5_sv2v_reg <= 1'b0;
      counter_o_4_sv2v_reg <= 1'b0;
      counter_o_3_sv2v_reg <= 1'b0;
      counter_o_2_sv2v_reg <= 1'b0;
      counter_o_1_sv2v_reg <= 1'b0;
      counter_o_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      counter_o_15_sv2v_reg <= N36;
      counter_o_14_sv2v_reg <= N35;
      counter_o_13_sv2v_reg <= N34;
      counter_o_12_sv2v_reg <= N33;
      counter_o_11_sv2v_reg <= N32;
      counter_o_10_sv2v_reg <= N31;
      counter_o_9_sv2v_reg <= N30;
      counter_o_8_sv2v_reg <= N29;
      counter_o_7_sv2v_reg <= N28;
      counter_o_6_sv2v_reg <= N27;
      counter_o_5_sv2v_reg <= N26;
      counter_o_4_sv2v_reg <= N25;
      counter_o_3_sv2v_reg <= N24;
      counter_o_2_sv2v_reg <= N23;
      counter_o_1_sv2v_reg <= N22;
      counter_o_0_sv2v_reg <= N21;
    end 
  end


endmodule

