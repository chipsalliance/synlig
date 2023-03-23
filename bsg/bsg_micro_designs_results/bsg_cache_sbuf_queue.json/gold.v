

module top
(
  clk_i,
  data_i,
  el0_en_i,
  el1_en_i,
  mux0_sel_i,
  mux1_sel_i,
  el0_snoop_o,
  el1_snoop_o,
  data_o
);

  input [15:0] data_i;
  output [15:0] el0_snoop_o;
  output [15:0] el1_snoop_o;
  output [15:0] data_o;
  input clk_i;
  input el0_en_i;
  input el1_en_i;
  input mux0_sel_i;
  input mux1_sel_i;

  bsg_cache_sbuf_queue
  wrapper
  (
    .data_i(data_i),
    .el0_snoop_o(el0_snoop_o),
    .el1_snoop_o(el1_snoop_o),
    .data_o(data_o),
    .clk_i(clk_i),
    .el0_en_i(el0_en_i),
    .el1_en_i(el1_en_i),
    .mux0_sel_i(mux0_sel_i),
    .mux1_sel_i(mux1_sel_i)
  );


endmodule



module bsg_cache_sbuf_queue
(
  clk_i,
  data_i,
  el0_en_i,
  el1_en_i,
  mux0_sel_i,
  mux1_sel_i,
  el0_snoop_o,
  el1_snoop_o,
  data_o
);

  input [15:0] data_i;
  output [15:0] el0_snoop_o;
  output [15:0] el1_snoop_o;
  output [15:0] data_o;
  input clk_i;
  input el0_en_i;
  input el1_en_i;
  input mux0_sel_i;
  input mux1_sel_i;
  wire [15:0] el0_snoop_o,el1_snoop_o,data_o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21;
  reg el0_snoop_o_15_sv2v_reg,el0_snoop_o_14_sv2v_reg,el0_snoop_o_13_sv2v_reg,
  el0_snoop_o_12_sv2v_reg,el0_snoop_o_11_sv2v_reg,el0_snoop_o_10_sv2v_reg,
  el0_snoop_o_9_sv2v_reg,el0_snoop_o_8_sv2v_reg,el0_snoop_o_7_sv2v_reg,el0_snoop_o_6_sv2v_reg,
  el0_snoop_o_5_sv2v_reg,el0_snoop_o_4_sv2v_reg,el0_snoop_o_3_sv2v_reg,
  el0_snoop_o_2_sv2v_reg,el0_snoop_o_1_sv2v_reg,el0_snoop_o_0_sv2v_reg,el1_snoop_o_15_sv2v_reg,
  el1_snoop_o_14_sv2v_reg,el1_snoop_o_13_sv2v_reg,el1_snoop_o_12_sv2v_reg,
  el1_snoop_o_11_sv2v_reg,el1_snoop_o_10_sv2v_reg,el1_snoop_o_9_sv2v_reg,
  el1_snoop_o_8_sv2v_reg,el1_snoop_o_7_sv2v_reg,el1_snoop_o_6_sv2v_reg,el1_snoop_o_5_sv2v_reg,
  el1_snoop_o_4_sv2v_reg,el1_snoop_o_3_sv2v_reg,el1_snoop_o_2_sv2v_reg,
  el1_snoop_o_1_sv2v_reg,el1_snoop_o_0_sv2v_reg;
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
  assign { N20, N19, N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5 } = (N0)? el0_snoop_o : 
                                                                                         (N1)? data_i : 1'b0;
  assign N0 = mux0_sel_i;
  assign N1 = N4;
  assign data_o = (N2)? el1_snoop_o : 
                  (N3)? data_i : 1'b0;
  assign N2 = mux1_sel_i;
  assign N3 = N21;
  assign N4 = ~mux0_sel_i;
  assign N21 = ~mux1_sel_i;

  always @(posedge clk_i) begin
    if(el0_en_i) begin
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
    if(el1_en_i) begin
      el1_snoop_o_15_sv2v_reg <= N20;
      el1_snoop_o_14_sv2v_reg <= N19;
      el1_snoop_o_13_sv2v_reg <= N18;
      el1_snoop_o_12_sv2v_reg <= N17;
      el1_snoop_o_11_sv2v_reg <= N16;
      el1_snoop_o_10_sv2v_reg <= N15;
      el1_snoop_o_9_sv2v_reg <= N14;
      el1_snoop_o_8_sv2v_reg <= N13;
      el1_snoop_o_7_sv2v_reg <= N12;
      el1_snoop_o_6_sv2v_reg <= N11;
      el1_snoop_o_5_sv2v_reg <= N10;
      el1_snoop_o_4_sv2v_reg <= N9;
      el1_snoop_o_3_sv2v_reg <= N8;
      el1_snoop_o_2_sv2v_reg <= N7;
      el1_snoop_o_1_sv2v_reg <= N6;
      el1_snoop_o_0_sv2v_reg <= N5;
    end 
  end


endmodule

