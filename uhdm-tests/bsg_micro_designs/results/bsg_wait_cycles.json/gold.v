

module top
(
  clk_i,
  reset_i,
  activate_i,
  ready_r_o
);

  input clk_i;
  input reset_i;
  input activate_i;
  output ready_r_o;

  bsg_wait_cycles
  wrapper
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .activate_i(activate_i),
    .ready_r_o(ready_r_o)
  );


endmodule



module bsg_wait_cycles
(
  clk_i,
  reset_i,
  activate_i,
  ready_r_o
);

  input clk_i;
  input reset_i;
  input activate_i;
  output ready_r_o;
  wire ready_r_o,N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N30,N16,N17,N18,
  N19,N20,N21,N22,N23,N24,N25,N26,N27,N28,N29,N31,N32,N33;
  wire [4:0] ctr_r,ctr_n;
  reg ctr_r_4_sv2v_reg,ctr_r_3_sv2v_reg,ctr_r_2_sv2v_reg,ctr_r_1_sv2v_reg,
  ctr_r_0_sv2v_reg,ready_r_o_sv2v_reg;
  assign ctr_r[4] = ctr_r_4_sv2v_reg;
  assign ctr_r[3] = ctr_r_3_sv2v_reg;
  assign ctr_r[2] = ctr_r_2_sv2v_reg;
  assign ctr_r[1] = ctr_r_1_sv2v_reg;
  assign ctr_r[0] = ctr_r_0_sv2v_reg;
  assign ready_r_o = ready_r_o_sv2v_reg;
  assign N21 = reset_i | activate_i;
  assign N22 = ~ctr_n[4];
  assign N23 = ctr_n[3] | N22;
  assign N24 = ctr_n[2] | N23;
  assign N25 = ctr_n[1] | N24;
  assign N26 = ctr_n[0] | N25;
  assign N27 = ~N26;
  assign N28 = ~ctr_r[4];
  assign N29 = ctr_r[3] | N28;
  assign N31 = ctr_r[2] | N29;
  assign N32 = ctr_r[1] | N31;
  assign N33 = ctr_r[0] | N32;
  assign { N10, N9, N8, N7, N6 } = ctr_r + 1'b1;
  assign ctr_n = (N0)? { 1'b1, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                 (N12)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                 (N15)? { N10, N9, N8, N7, N6 } : 
                 (N4)? ctr_r : 1'b0;
  assign N0 = reset_i;
  assign { N20, N19, N18, N17, N16 } = (N1)? { N9, N8, N7, N6, N10 } : 
                                       (N30)? { ctr_r[3:0], ctr_r[4:4] } : 1'b0;
  assign N1 = N33;
  assign N2 = activate_i | reset_i;
  assign N3 = N33 | N2;
  assign N4 = ~N3;
  assign N5 = N15;
  assign N11 = ~reset_i;
  assign N12 = activate_i & N11;
  assign N13 = ~activate_i;
  assign N14 = N11 & N13;
  assign N15 = N33 & N14;
  assign N30 = ~N33;

  always @(posedge clk_i) begin
    if(activate_i) begin
      ctr_r_4_sv2v_reg <= 1'b0;
    end else if(reset_i) begin
      ctr_r_4_sv2v_reg <= 1'b1;
    end else if(1'b1) begin
      ctr_r_4_sv2v_reg <= N16;
    end 
    if(N21) begin
      ctr_r_3_sv2v_reg <= 1'b0;
      ctr_r_2_sv2v_reg <= 1'b0;
      ctr_r_1_sv2v_reg <= 1'b0;
      ctr_r_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      ctr_r_3_sv2v_reg <= N20;
      ctr_r_2_sv2v_reg <= N19;
      ctr_r_1_sv2v_reg <= N18;
      ctr_r_0_sv2v_reg <= N17;
    end 
    if(1'b1) begin
      ready_r_o_sv2v_reg <= N27;
    end 
  end


endmodule

