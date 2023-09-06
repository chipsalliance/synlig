

module top
(
  clk_i,
  reset_i,
  v_i,
  data_i,
  v_o,
  data_o,
  yumi_i,
  el0_valid_o,
  el1_valid_o,
  el0_snoop_o,
  el1_snoop_o,
  empty_o,
  full_o
);

  input [15:0] data_i;
  output [15:0] data_o;
  output [15:0] el0_snoop_o;
  output [15:0] el1_snoop_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output v_o;
  output el0_valid_o;
  output el1_valid_o;
  output empty_o;
  output full_o;

  bsg_cache_buffer_queue
  wrapper
  (
    .data_i(data_i),
    .data_o(data_o),
    .el0_snoop_o(el0_snoop_o),
    .el1_snoop_o(el1_snoop_o),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(v_i),
    .yumi_i(yumi_i),
    .v_o(v_o),
    .el0_valid_o(el0_valid_o),
    .el1_valid_o(el1_valid_o),
    .empty_o(empty_o),
    .full_o(full_o)
  );


endmodule



module bsg_cache_buffer_queue
(
  clk_i,
  reset_i,
  v_i,
  data_i,
  v_o,
  data_o,
  yumi_i,
  el0_valid_o,
  el1_valid_o,
  el0_snoop_o,
  el1_snoop_o,
  empty_o,
  full_o
);

  input [15:0] data_i;
  output [15:0] data_o;
  output [15:0] el0_snoop_o;
  output [15:0] el1_snoop_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output v_o;
  output el0_valid_o;
  output el1_valid_o;
  output empty_o;
  output full_o;
  wire [15:0] data_o,el0_snoop_o,el1_snoop_o;
  wire v_o,el0_valid_o,el1_valid_o,empty_o,full_o,N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,
  N11,N12,N13,N14,N15,el0_enable,el1_enable,mux0_sel,mux1_sel,N16,N17,N18,N19,N20,
  N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,
  N41,N42;
  wire [1:0] num_els_r;
  reg num_els_r_1_sv2v_reg,num_els_r_0_sv2v_reg,el0_snoop_o_15_sv2v_reg,
  el0_snoop_o_14_sv2v_reg,el0_snoop_o_13_sv2v_reg,el0_snoop_o_12_sv2v_reg,
  el0_snoop_o_11_sv2v_reg,el0_snoop_o_10_sv2v_reg,el0_snoop_o_9_sv2v_reg,el0_snoop_o_8_sv2v_reg,
  el0_snoop_o_7_sv2v_reg,el0_snoop_o_6_sv2v_reg,el0_snoop_o_5_sv2v_reg,
  el0_snoop_o_4_sv2v_reg,el0_snoop_o_3_sv2v_reg,el0_snoop_o_2_sv2v_reg,el0_snoop_o_1_sv2v_reg,
  el0_snoop_o_0_sv2v_reg,el1_snoop_o_15_sv2v_reg,el1_snoop_o_14_sv2v_reg,
  el1_snoop_o_13_sv2v_reg,el1_snoop_o_12_sv2v_reg,el1_snoop_o_11_sv2v_reg,el1_snoop_o_10_sv2v_reg,
  el1_snoop_o_9_sv2v_reg,el1_snoop_o_8_sv2v_reg,el1_snoop_o_7_sv2v_reg,
  el1_snoop_o_6_sv2v_reg,el1_snoop_o_5_sv2v_reg,el1_snoop_o_4_sv2v_reg,
  el1_snoop_o_3_sv2v_reg,el1_snoop_o_2_sv2v_reg,el1_snoop_o_1_sv2v_reg,el1_snoop_o_0_sv2v_reg;
  assign num_els_r[1] = num_els_r_1_sv2v_reg;
  assign num_els_r[0] = num_els_r_0_sv2v_reg;
  assign el0_snoop_o[15] = el0_snoop_o_15_sv2v_reg;
  assign el0_snoop_o[14] = el0_snoop_o_14_sv2v_reg;
  assign el0_snoop_o[13] = el0_snoop_o_13_sv2v_reg;
  assign el0_snoop_o[12] = el0_snoop_o_12_sv2v_reg;
  assign el0_snoop_o[11] = el0_snoop_o_11_sv2v_reg;
  assign el0_snoop_o[10] = el0_snoop_o_10_sv2v_reg;
  assign el0_snoop_o[9] = el0_snoop_o_9_sv2v_reg;
  assign el0_snoop_o[8] = el0_snoop_o_8_sv2v_reg;
  assign el0_snoop_o[7] = el0_snoop_o_7_sv2v_reg;
  assign el0_snoop_o[6] = el0_snoop_o_6_sv2v_reg;
  assign el0_snoop_o[5] = el0_snoop_o_5_sv2v_reg;
  assign el0_snoop_o[4] = el0_snoop_o_4_sv2v_reg;
  assign el0_snoop_o[3] = el0_snoop_o_3_sv2v_reg;
  assign el0_snoop_o[2] = el0_snoop_o_2_sv2v_reg;
  assign el0_snoop_o[1] = el0_snoop_o_1_sv2v_reg;
  assign el0_snoop_o[0] = el0_snoop_o_0_sv2v_reg;
  assign el1_snoop_o[15] = el1_snoop_o_15_sv2v_reg;
  assign el1_snoop_o[14] = el1_snoop_o_14_sv2v_reg;
  assign el1_snoop_o[13] = el1_snoop_o_13_sv2v_reg;
  assign el1_snoop_o[12] = el1_snoop_o_12_sv2v_reg;
  assign el1_snoop_o[11] = el1_snoop_o_11_sv2v_reg;
  assign el1_snoop_o[10] = el1_snoop_o_10_sv2v_reg;
  assign el1_snoop_o[9] = el1_snoop_o_9_sv2v_reg;
  assign el1_snoop_o[8] = el1_snoop_o_8_sv2v_reg;
  assign el1_snoop_o[7] = el1_snoop_o_7_sv2v_reg;
  assign el1_snoop_o[6] = el1_snoop_o_6_sv2v_reg;
  assign el1_snoop_o[5] = el1_snoop_o_5_sv2v_reg;
  assign el1_snoop_o[4] = el1_snoop_o_4_sv2v_reg;
  assign el1_snoop_o[3] = el1_snoop_o_3_sv2v_reg;
  assign el1_snoop_o[2] = el1_snoop_o_2_sv2v_reg;
  assign el1_snoop_o[1] = el1_snoop_o_1_sv2v_reg;
  assign el1_snoop_o[0] = el1_snoop_o_0_sv2v_reg;
  assign N10 = N8 & N9;
  assign N11 = num_els_r[1] | N9;
  assign N13 = N8 | num_els_r[0];
  assign N15 = num_els_r[1] & num_els_r[0];
  assign { N20, N19 } = num_els_r + v_i;
  assign { N23, N22 } = { N20, N19 } - N21;
  assign v_o = (N0)? v_i : 
               (N1)? 1'b1 : 
               (N2)? 1'b1 : 
               (N3)? 1'b0 : 1'b0;
  assign N0 = N10;
  assign N1 = N12;
  assign N2 = N14;
  assign N3 = N15;
  assign empty_o = (N0)? 1'b1 : 
                   (N1)? 1'b0 : 
                   (N2)? 1'b0 : 
                   (N3)? 1'b0 : 1'b0;
  assign full_o = (N0)? 1'b0 : 
                  (N1)? 1'b0 : 
                  (N2)? 1'b1 : 
                  (N3)? 1'b0 : 1'b0;
  assign el0_valid_o = (N0)? 1'b0 : 
                       (N1)? 1'b0 : 
                       (N2)? 1'b1 : 
                       (N3)? 1'b0 : 1'b0;
  assign el1_valid_o = (N0)? 1'b0 : 
                       (N1)? 1'b1 : 
                       (N2)? 1'b1 : 
                       (N3)? 1'b0 : 1'b0;
  assign el0_enable = (N0)? 1'b0 : 
                      (N1)? N16 : 
                      (N2)? N17 : 
                      (N3)? 1'b0 : 1'b0;
  assign el1_enable = (N0)? N16 : 
                      (N1)? N17 : 
                      (N2)? yumi_i : 
                      (N3)? 1'b0 : 1'b0;
  assign mux0_sel = (N0)? 1'b0 : 
                    (N1)? 1'b0 : 
                    (N2)? 1'b1 : 
                    (N3)? 1'b0 : 1'b0;
  assign mux1_sel = (N0)? 1'b0 : 
                    (N1)? 1'b1 : 
                    (N2)? 1'b1 : 
                    (N3)? 1'b0 : 1'b0;
  assign { N40, N39, N38, N37, N36, N35, N34, N33, N32, N31, N30, N29, N28, N27, N26, N25 } = (N4)? el0_snoop_o : 
                                                                                              (N5)? data_i : 1'b0;
  assign N4 = mux0_sel;
  assign N5 = N24;
  assign data_o = (N6)? el1_snoop_o : 
                  (N7)? data_i : 1'b0;
  assign N6 = mux1_sel;
  assign N7 = N41;
  assign N8 = ~num_els_r[1];
  assign N9 = ~num_els_r[0];
  assign N12 = ~N11;
  assign N14 = ~N13;
  assign N16 = v_i & N42;
  assign N42 = ~yumi_i;
  assign N17 = v_i & yumi_i;
  assign N18 = ~reset_i;
  assign N21 = v_o & yumi_i;
  assign N24 = ~mux0_sel;
  assign N41 = ~mux1_sel;

  always @(posedge clk_i) begin
    if(reset_i) begin
      num_els_r_1_sv2v_reg <= 1'b0;
      num_els_r_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      num_els_r_1_sv2v_reg <= N23;
      num_els_r_0_sv2v_reg <= N22;
    end 
    if(el0_enable) begin
      el0_snoop_o_15_sv2v_reg <= data_i[15];
      el0_snoop_o_14_sv2v_reg <= data_i[14];
      el0_snoop_o_13_sv2v_reg <= data_i[13];
      el0_snoop_o_12_sv2v_reg <= data_i[12];
      el0_snoop_o_11_sv2v_reg <= data_i[11];
      el0_snoop_o_10_sv2v_reg <= data_i[10];
      el0_snoop_o_9_sv2v_reg <= data_i[9];
      el0_snoop_o_8_sv2v_reg <= data_i[8];
      el0_snoop_o_7_sv2v_reg <= data_i[7];
      el0_snoop_o_6_sv2v_reg <= data_i[6];
      el0_snoop_o_5_sv2v_reg <= data_i[5];
      el0_snoop_o_4_sv2v_reg <= data_i[4];
      el0_snoop_o_3_sv2v_reg <= data_i[3];
      el0_snoop_o_2_sv2v_reg <= data_i[2];
      el0_snoop_o_1_sv2v_reg <= data_i[1];
      el0_snoop_o_0_sv2v_reg <= data_i[0];
    end 
    if(el1_enable) begin
      el1_snoop_o_15_sv2v_reg <= N40;
      el1_snoop_o_14_sv2v_reg <= N39;
      el1_snoop_o_13_sv2v_reg <= N38;
      el1_snoop_o_12_sv2v_reg <= N37;
      el1_snoop_o_11_sv2v_reg <= N36;
      el1_snoop_o_10_sv2v_reg <= N35;
      el1_snoop_o_9_sv2v_reg <= N34;
      el1_snoop_o_8_sv2v_reg <= N33;
      el1_snoop_o_7_sv2v_reg <= N32;
      el1_snoop_o_6_sv2v_reg <= N31;
      el1_snoop_o_5_sv2v_reg <= N30;
      el1_snoop_o_4_sv2v_reg <= N29;
      el1_snoop_o_3_sv2v_reg <= N28;
      el1_snoop_o_2_sv2v_reg <= N27;
      el1_snoop_o_1_sv2v_reg <= N26;
      el1_snoop_o_0_sv2v_reg <= N25;
    end 
  end


endmodule

