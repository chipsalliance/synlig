

module top
(
  reset_i,
  clk_i,
  ready_r_o
);

  input reset_i;
  input clk_i;
  output ready_r_o;

  bsg_wait_after_reset
  wrapper
  (
    .reset_i(reset_i),
    .clk_i(clk_i),
    .ready_r_o(ready_r_o)
  );


endmodule



module bsg_wait_after_reset
(
  reset_i,
  clk_i,
  ready_r_o
);

  input reset_i;
  input clk_i;
  output ready_r_o;
  wire ready_r_o,N0,N1,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16;
  wire [4:0] counter_r;
  reg ready_r_o_sv2v_reg,counter_r_4_sv2v_reg,counter_r_3_sv2v_reg,
  counter_r_2_sv2v_reg,counter_r_1_sv2v_reg,counter_r_0_sv2v_reg;
  assign ready_r_o = ready_r_o_sv2v_reg;
  assign counter_r[4] = counter_r_4_sv2v_reg;
  assign counter_r[3] = counter_r_3_sv2v_reg;
  assign counter_r[2] = counter_r_2_sv2v_reg;
  assign counter_r[1] = counter_r_1_sv2v_reg;
  assign counter_r[0] = counter_r_0_sv2v_reg;
  assign N12 = counter_r[3] | counter_r[4];
  assign N13 = counter_r[2] | N12;
  assign N14 = counter_r[1] | N13;
  assign N15 = counter_r[0] | N14;
  assign N16 = ~N15;
  assign { N9, N8, N7, N6, N5 } = counter_r + 1'b1;
  assign N10 = (N0)? 1'b0 : 
               (N1)? 1'b1 : 1'b0;
  assign N0 = N16;
  assign N1 = N15;
  assign N11 = (N0)? 1'b1 : 
               (N1)? 1'b0 : 1'b0;
  assign N3 = N16 | reset_i;
  assign N4 = ~N3;

  always @(posedge clk_i) begin
    if(reset_i) begin
      ready_r_o_sv2v_reg <= 1'b0;
    end else if(N11) begin
      ready_r_o_sv2v_reg <= 1'b1;
    end 
    if(reset_i) begin
      counter_r_4_sv2v_reg <= 1'b0;
      counter_r_3_sv2v_reg <= 1'b0;
      counter_r_2_sv2v_reg <= 1'b0;
      counter_r_1_sv2v_reg <= 1'b0;
      counter_r_0_sv2v_reg <= 1'b1;
    end else if(N10) begin
      counter_r_4_sv2v_reg <= N9;
      counter_r_3_sv2v_reg <= N8;
      counter_r_2_sv2v_reg <= N7;
      counter_r_1_sv2v_reg <= N6;
      counter_r_0_sv2v_reg <= N5;
    end 
  end


endmodule

