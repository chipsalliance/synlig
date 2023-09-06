

module top
(
  clk_i,
  reset_i,
  set_i,
  val_i,
  down_i,
  count_r_o
);

  input [15:0] val_i;
  output [15:0] count_r_o;
  input clk_i;
  input reset_i;
  input set_i;
  input down_i;

  bsg_counter_set_down
  wrapper
  (
    .val_i(val_i),
    .count_r_o(count_r_o),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .set_i(set_i),
    .down_i(down_i)
  );


endmodule



module bsg_counter_set_down
(
  clk_i,
  reset_i,
  set_i,
  val_i,
  down_i,
  count_r_o
);

  input [15:0] val_i;
  output [15:0] count_r_o;
  input clk_i;
  input reset_i;
  input set_i;
  input down_i;
  wire [15:0] count_r_o,ctr_n;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20;
  reg count_r_o_15_sv2v_reg,count_r_o_14_sv2v_reg,count_r_o_13_sv2v_reg,
  count_r_o_12_sv2v_reg,count_r_o_11_sv2v_reg,count_r_o_10_sv2v_reg,count_r_o_9_sv2v_reg,
  count_r_o_8_sv2v_reg,count_r_o_7_sv2v_reg,count_r_o_6_sv2v_reg,count_r_o_5_sv2v_reg,
  count_r_o_4_sv2v_reg,count_r_o_3_sv2v_reg,count_r_o_2_sv2v_reg,
  count_r_o_1_sv2v_reg,count_r_o_0_sv2v_reg;
  assign count_r_o[15] = count_r_o_15_sv2v_reg;
  assign count_r_o[14] = count_r_o_14_sv2v_reg;
  assign count_r_o[13] = count_r_o_13_sv2v_reg;
  assign count_r_o[12] = count_r_o_12_sv2v_reg;
  assign count_r_o[11] = count_r_o_11_sv2v_reg;
  assign count_r_o[10] = count_r_o_10_sv2v_reg;
  assign count_r_o[9] = count_r_o_9_sv2v_reg;
  assign count_r_o[8] = count_r_o_8_sv2v_reg;
  assign count_r_o[7] = count_r_o_7_sv2v_reg;
  assign count_r_o[6] = count_r_o_6_sv2v_reg;
  assign count_r_o[5] = count_r_o_5_sv2v_reg;
  assign count_r_o[4] = count_r_o_4_sv2v_reg;
  assign count_r_o[3] = count_r_o_3_sv2v_reg;
  assign count_r_o[2] = count_r_o_2_sv2v_reg;
  assign count_r_o[1] = count_r_o_1_sv2v_reg;
  assign count_r_o[0] = count_r_o_0_sv2v_reg;
  assign ctr_n = { N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3 } - down_i;
  assign { N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3 } = (N0)? val_i : 
                                                                                       (N1)? count_r_o : 1'b0;
  assign N0 = set_i;
  assign N1 = N2;
  assign N2 = ~set_i;
  assign N19 = ~down_i;
  assign N20 = down_i;

  always @(posedge clk_i) begin
    if(reset_i) begin
      count_r_o_15_sv2v_reg <= 1'b0;
      count_r_o_14_sv2v_reg <= 1'b0;
      count_r_o_13_sv2v_reg <= 1'b0;
      count_r_o_12_sv2v_reg <= 1'b0;
      count_r_o_11_sv2v_reg <= 1'b0;
      count_r_o_10_sv2v_reg <= 1'b0;
      count_r_o_9_sv2v_reg <= 1'b0;
      count_r_o_8_sv2v_reg <= 1'b0;
      count_r_o_7_sv2v_reg <= 1'b0;
      count_r_o_6_sv2v_reg <= 1'b0;
      count_r_o_5_sv2v_reg <= 1'b0;
      count_r_o_4_sv2v_reg <= 1'b0;
      count_r_o_3_sv2v_reg <= 1'b0;
      count_r_o_2_sv2v_reg <= 1'b0;
      count_r_o_1_sv2v_reg <= 1'b0;
      count_r_o_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      count_r_o_15_sv2v_reg <= ctr_n[15];
      count_r_o_14_sv2v_reg <= ctr_n[14];
      count_r_o_13_sv2v_reg <= ctr_n[13];
      count_r_o_12_sv2v_reg <= ctr_n[12];
      count_r_o_11_sv2v_reg <= ctr_n[11];
      count_r_o_10_sv2v_reg <= ctr_n[10];
      count_r_o_9_sv2v_reg <= ctr_n[9];
      count_r_o_8_sv2v_reg <= ctr_n[8];
      count_r_o_7_sv2v_reg <= ctr_n[7];
      count_r_o_6_sv2v_reg <= ctr_n[6];
      count_r_o_5_sv2v_reg <= ctr_n[5];
      count_r_o_4_sv2v_reg <= ctr_n[4];
      count_r_o_3_sv2v_reg <= ctr_n[3];
      count_r_o_2_sv2v_reg <= ctr_n[2];
      count_r_o_1_sv2v_reg <= ctr_n[1];
      count_r_o_0_sv2v_reg <= ctr_n[0];
    end 
  end


endmodule

