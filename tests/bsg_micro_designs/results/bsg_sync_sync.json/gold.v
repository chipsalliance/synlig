

module top
(
  oclk_i,
  iclk_data_i,
  oclk_data_o
);

  input [15:0] iclk_data_i;
  output [15:0] oclk_data_o;
  input oclk_i;

  bsg_sync_sync
  wrapper
  (
    .iclk_data_i(iclk_data_i),
    .oclk_data_o(oclk_data_o),
    .oclk_i(oclk_i)
  );


endmodule



module bsg_sync_sync_8_unit
(
  oclk_i,
  iclk_data_i,
  oclk_data_o
);

  input [7:0] iclk_data_i;
  output [7:0] oclk_data_o;
  input oclk_i;
  wire [7:0] oclk_data_o,bsg_SYNC_1_r;
  reg bsg_SYNC_1_r_7_sv2v_reg,bsg_SYNC_1_r_6_sv2v_reg,bsg_SYNC_1_r_5_sv2v_reg,
  bsg_SYNC_1_r_4_sv2v_reg,bsg_SYNC_1_r_3_sv2v_reg,bsg_SYNC_1_r_2_sv2v_reg,
  bsg_SYNC_1_r_1_sv2v_reg,bsg_SYNC_1_r_0_sv2v_reg,oclk_data_o_7_sv2v_reg,oclk_data_o_6_sv2v_reg,
  oclk_data_o_5_sv2v_reg,oclk_data_o_4_sv2v_reg,oclk_data_o_3_sv2v_reg,
  oclk_data_o_2_sv2v_reg,oclk_data_o_1_sv2v_reg,oclk_data_o_0_sv2v_reg;
  assign bsg_SYNC_1_r[7] = bsg_SYNC_1_r_7_sv2v_reg;
  assign bsg_SYNC_1_r[6] = bsg_SYNC_1_r_6_sv2v_reg;
  assign bsg_SYNC_1_r[5] = bsg_SYNC_1_r_5_sv2v_reg;
  assign bsg_SYNC_1_r[4] = bsg_SYNC_1_r_4_sv2v_reg;
  assign bsg_SYNC_1_r[3] = bsg_SYNC_1_r_3_sv2v_reg;
  assign bsg_SYNC_1_r[2] = bsg_SYNC_1_r_2_sv2v_reg;
  assign bsg_SYNC_1_r[1] = bsg_SYNC_1_r_1_sv2v_reg;
  assign bsg_SYNC_1_r[0] = bsg_SYNC_1_r_0_sv2v_reg;
  assign oclk_data_o[7] = oclk_data_o_7_sv2v_reg;
  assign oclk_data_o[6] = oclk_data_o_6_sv2v_reg;
  assign oclk_data_o[5] = oclk_data_o_5_sv2v_reg;
  assign oclk_data_o[4] = oclk_data_o_4_sv2v_reg;
  assign oclk_data_o[3] = oclk_data_o_3_sv2v_reg;
  assign oclk_data_o[2] = oclk_data_o_2_sv2v_reg;
  assign oclk_data_o[1] = oclk_data_o_1_sv2v_reg;
  assign oclk_data_o[0] = oclk_data_o_0_sv2v_reg;

  always @(posedge oclk_i) begin
    if(1'b1) begin
      bsg_SYNC_1_r_7_sv2v_reg <= iclk_data_i[7];
      bsg_SYNC_1_r_6_sv2v_reg <= iclk_data_i[6];
      bsg_SYNC_1_r_5_sv2v_reg <= iclk_data_i[5];
      bsg_SYNC_1_r_4_sv2v_reg <= iclk_data_i[4];
      bsg_SYNC_1_r_3_sv2v_reg <= iclk_data_i[3];
      bsg_SYNC_1_r_2_sv2v_reg <= iclk_data_i[2];
      bsg_SYNC_1_r_1_sv2v_reg <= iclk_data_i[1];
      bsg_SYNC_1_r_0_sv2v_reg <= iclk_data_i[0];
      oclk_data_o_7_sv2v_reg <= bsg_SYNC_1_r[7];
      oclk_data_o_6_sv2v_reg <= bsg_SYNC_1_r[6];
      oclk_data_o_5_sv2v_reg <= bsg_SYNC_1_r[5];
      oclk_data_o_4_sv2v_reg <= bsg_SYNC_1_r[4];
      oclk_data_o_3_sv2v_reg <= bsg_SYNC_1_r[3];
      oclk_data_o_2_sv2v_reg <= bsg_SYNC_1_r[2];
      oclk_data_o_1_sv2v_reg <= bsg_SYNC_1_r[1];
      oclk_data_o_0_sv2v_reg <= bsg_SYNC_1_r[0];
    end 
  end


endmodule



module bsg_sync_sync
(
  oclk_i,
  iclk_data_i,
  oclk_data_o
);

  input [15:0] iclk_data_i;
  output [15:0] oclk_data_o;
  input oclk_i;
  wire [15:0] oclk_data_o;

  bsg_sync_sync_8_unit
  \maxb_0_.bss8 
  (
    .oclk_i(oclk_i),
    .iclk_data_i(iclk_data_i[7:0]),
    .oclk_data_o(oclk_data_o[7:0])
  );


  bsg_sync_sync_8_unit
  \maxb_1_.bss8 
  (
    .oclk_i(oclk_i),
    .iclk_data_i(iclk_data_i[15:8]),
    .oclk_data_o(oclk_data_o[15:8])
  );


endmodule

