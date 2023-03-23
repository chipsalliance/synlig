

module top
(
  clk_i,
  reset_i,
  ctr_r_o
);

  output [15:0] ctr_r_o;
  input clk_i;
  input reset_i;

  bsg_cycle_counter
  wrapper
  (
    .ctr_r_o(ctr_r_o),
    .clk_i(clk_i),
    .reset_i(reset_i)
  );


endmodule



module bsg_cycle_counter
(
  clk_i,
  reset_i,
  ctr_r_o
);

  output [15:0] ctr_r_o;
  input clk_i;
  input reset_i;
  wire [15:0] ctr_r_o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16;
  reg ctr_r_o_15_sv2v_reg,ctr_r_o_14_sv2v_reg,ctr_r_o_13_sv2v_reg,ctr_r_o_12_sv2v_reg,
  ctr_r_o_11_sv2v_reg,ctr_r_o_10_sv2v_reg,ctr_r_o_9_sv2v_reg,ctr_r_o_8_sv2v_reg,
  ctr_r_o_7_sv2v_reg,ctr_r_o_6_sv2v_reg,ctr_r_o_5_sv2v_reg,ctr_r_o_4_sv2v_reg,
  ctr_r_o_3_sv2v_reg,ctr_r_o_2_sv2v_reg,ctr_r_o_1_sv2v_reg,ctr_r_o_0_sv2v_reg;
  assign ctr_r_o[15] = ctr_r_o_15_sv2v_reg;
  assign ctr_r_o[14] = ctr_r_o_14_sv2v_reg;
  assign ctr_r_o[13] = ctr_r_o_13_sv2v_reg;
  assign ctr_r_o[12] = ctr_r_o_12_sv2v_reg;
  assign ctr_r_o[11] = ctr_r_o_11_sv2v_reg;
  assign ctr_r_o[10] = ctr_r_o_10_sv2v_reg;
  assign ctr_r_o[9] = ctr_r_o_9_sv2v_reg;
  assign ctr_r_o[8] = ctr_r_o_8_sv2v_reg;
  assign ctr_r_o[7] = ctr_r_o_7_sv2v_reg;
  assign ctr_r_o[6] = ctr_r_o_6_sv2v_reg;
  assign ctr_r_o[5] = ctr_r_o_5_sv2v_reg;
  assign ctr_r_o[4] = ctr_r_o_4_sv2v_reg;
  assign ctr_r_o[3] = ctr_r_o_3_sv2v_reg;
  assign ctr_r_o[2] = ctr_r_o_2_sv2v_reg;
  assign ctr_r_o[1] = ctr_r_o_1_sv2v_reg;
  assign ctr_r_o[0] = ctr_r_o_0_sv2v_reg;
  assign { N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1 } = ctr_r_o + 1'b1;
  assign N0 = ~reset_i;

  always @(posedge clk_i) begin
    if(reset_i) begin
      ctr_r_o_15_sv2v_reg <= 1'b0;
      ctr_r_o_14_sv2v_reg <= 1'b0;
      ctr_r_o_13_sv2v_reg <= 1'b0;
      ctr_r_o_12_sv2v_reg <= 1'b0;
      ctr_r_o_11_sv2v_reg <= 1'b0;
      ctr_r_o_10_sv2v_reg <= 1'b0;
      ctr_r_o_9_sv2v_reg <= 1'b0;
      ctr_r_o_8_sv2v_reg <= 1'b0;
      ctr_r_o_7_sv2v_reg <= 1'b0;
      ctr_r_o_6_sv2v_reg <= 1'b0;
      ctr_r_o_5_sv2v_reg <= 1'b0;
      ctr_r_o_4_sv2v_reg <= 1'b0;
      ctr_r_o_3_sv2v_reg <= 1'b0;
      ctr_r_o_2_sv2v_reg <= 1'b0;
      ctr_r_o_1_sv2v_reg <= 1'b0;
      ctr_r_o_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      ctr_r_o_15_sv2v_reg <= N16;
      ctr_r_o_14_sv2v_reg <= N15;
      ctr_r_o_13_sv2v_reg <= N14;
      ctr_r_o_12_sv2v_reg <= N13;
      ctr_r_o_11_sv2v_reg <= N12;
      ctr_r_o_10_sv2v_reg <= N11;
      ctr_r_o_9_sv2v_reg <= N10;
      ctr_r_o_8_sv2v_reg <= N9;
      ctr_r_o_7_sv2v_reg <= N8;
      ctr_r_o_6_sv2v_reg <= N7;
      ctr_r_o_5_sv2v_reg <= N6;
      ctr_r_o_4_sv2v_reg <= N5;
      ctr_r_o_3_sv2v_reg <= N4;
      ctr_r_o_2_sv2v_reg <= N3;
      ctr_r_o_1_sv2v_reg <= N2;
      ctr_r_o_0_sv2v_reg <= N1;
    end 
  end


endmodule

