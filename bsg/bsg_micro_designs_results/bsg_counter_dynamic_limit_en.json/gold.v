

module top
(
  clk_i,
  reset_i,
  en_i,
  limit_i,
  counter_o,
  overflowed_o
);

  input [15:0] limit_i;
  output [15:0] counter_o;
  input clk_i;
  input reset_i;
  input en_i;
  output overflowed_o;

  bsg_counter_dynamic_limit_en
  wrapper
  (
    .limit_i(limit_i),
    .counter_o(counter_o),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .en_i(en_i),
    .overflowed_o(overflowed_o)
  );


endmodule



module bsg_counter_dynamic_limit_en
(
  clk_i,
  reset_i,
  en_i,
  limit_i,
  counter_o,
  overflowed_o
);

  input [15:0] limit_i;
  output [15:0] counter_o;
  input clk_i;
  input reset_i;
  input en_i;
  output overflowed_o;
  wire [15:0] counter_o,counter_plus_1;
  wire overflowed_o,N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,
  N19,N20,N21;
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
  assign overflowed_o = counter_plus_1 == limit_i;
  assign counter_plus_1 = counter_o + 1'b1;
  assign { N20, N19, N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5 } = (N0)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                                                         (N1)? counter_plus_1 : 1'b0;
  assign N0 = overflowed_o;
  assign N1 = N4;
  assign N21 = (N2)? 1'b1 : 
               (N3)? 1'b0 : 1'b0;
  assign N2 = en_i;
  assign N3 = ~en_i;
  assign N4 = ~overflowed_o;

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
    end else if(N21) begin
      counter_o_15_sv2v_reg <= N20;
      counter_o_14_sv2v_reg <= N19;
      counter_o_13_sv2v_reg <= N18;
      counter_o_12_sv2v_reg <= N17;
      counter_o_11_sv2v_reg <= N16;
      counter_o_10_sv2v_reg <= N15;
      counter_o_9_sv2v_reg <= N14;
      counter_o_8_sv2v_reg <= N13;
      counter_o_7_sv2v_reg <= N12;
      counter_o_6_sv2v_reg <= N11;
      counter_o_5_sv2v_reg <= N10;
      counter_o_4_sv2v_reg <= N9;
      counter_o_3_sv2v_reg <= N8;
      counter_o_2_sv2v_reg <= N7;
      counter_o_1_sv2v_reg <= N6;
      counter_o_0_sv2v_reg <= N5;
    end 
  end


endmodule

