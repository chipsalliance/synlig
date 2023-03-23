

module top
(
  w_clk_i,
  w_reset_i,
  w_inc_i,
  r_clk_i,
  w_ptr_binary_r_o,
  w_ptr_gray_r_o,
  w_ptr_gray_r_rsync_o
);

  output [4:0] w_ptr_binary_r_o;
  output [4:0] w_ptr_gray_r_o;
  output [4:0] w_ptr_gray_r_rsync_o;
  input w_clk_i;
  input w_reset_i;
  input w_inc_i;
  input r_clk_i;

  bsg_async_ptr_gray
  wrapper
  (
    .w_ptr_binary_r_o(w_ptr_binary_r_o),
    .w_ptr_gray_r_o(w_ptr_gray_r_o),
    .w_ptr_gray_r_rsync_o(w_ptr_gray_r_rsync_o),
    .w_clk_i(w_clk_i),
    .w_reset_i(w_reset_i),
    .w_inc_i(w_inc_i),
    .r_clk_i(r_clk_i)
  );


endmodule



module bsg_launch_sync_sync_posedge_5_unit
(
  iclk_i,
  iclk_reset_i,
  oclk_i,
  iclk_data_i,
  iclk_data_o,
  oclk_data_o
);

  input [4:0] iclk_data_i;
  output [4:0] iclk_data_o;
  output [4:0] oclk_data_o;
  input iclk_i;
  input iclk_reset_i;
  input oclk_i;
  wire [4:0] iclk_data_o,oclk_data_o,bsg_SYNC_1_r;
  reg iclk_data_o_4_sv2v_reg,iclk_data_o_3_sv2v_reg,iclk_data_o_2_sv2v_reg,
  iclk_data_o_1_sv2v_reg,iclk_data_o_0_sv2v_reg,bsg_SYNC_1_r_4_sv2v_reg,
  bsg_SYNC_1_r_3_sv2v_reg,bsg_SYNC_1_r_2_sv2v_reg,bsg_SYNC_1_r_1_sv2v_reg,bsg_SYNC_1_r_0_sv2v_reg,
  oclk_data_o_4_sv2v_reg,oclk_data_o_3_sv2v_reg,oclk_data_o_2_sv2v_reg,
  oclk_data_o_1_sv2v_reg,oclk_data_o_0_sv2v_reg;
  assign iclk_data_o[4] = iclk_data_o_4_sv2v_reg;
  assign iclk_data_o[3] = iclk_data_o_3_sv2v_reg;
  assign iclk_data_o[2] = iclk_data_o_2_sv2v_reg;
  assign iclk_data_o[1] = iclk_data_o_1_sv2v_reg;
  assign iclk_data_o[0] = iclk_data_o_0_sv2v_reg;
  assign bsg_SYNC_1_r[4] = bsg_SYNC_1_r_4_sv2v_reg;
  assign bsg_SYNC_1_r[3] = bsg_SYNC_1_r_3_sv2v_reg;
  assign bsg_SYNC_1_r[2] = bsg_SYNC_1_r_2_sv2v_reg;
  assign bsg_SYNC_1_r[1] = bsg_SYNC_1_r_1_sv2v_reg;
  assign bsg_SYNC_1_r[0] = bsg_SYNC_1_r_0_sv2v_reg;
  assign oclk_data_o[4] = oclk_data_o_4_sv2v_reg;
  assign oclk_data_o[3] = oclk_data_o_3_sv2v_reg;
  assign oclk_data_o[2] = oclk_data_o_2_sv2v_reg;
  assign oclk_data_o[1] = oclk_data_o_1_sv2v_reg;
  assign oclk_data_o[0] = oclk_data_o_0_sv2v_reg;

  always @(posedge iclk_i) begin
    if(iclk_reset_i) begin
      iclk_data_o_4_sv2v_reg <= 1'b0;
      iclk_data_o_3_sv2v_reg <= 1'b0;
      iclk_data_o_2_sv2v_reg <= 1'b0;
      iclk_data_o_1_sv2v_reg <= 1'b0;
      iclk_data_o_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      iclk_data_o_4_sv2v_reg <= iclk_data_i[4];
      iclk_data_o_3_sv2v_reg <= iclk_data_i[3];
      iclk_data_o_2_sv2v_reg <= iclk_data_i[2];
      iclk_data_o_1_sv2v_reg <= iclk_data_i[1];
      iclk_data_o_0_sv2v_reg <= iclk_data_i[0];
    end 
  end


  always @(posedge oclk_i) begin
    if(1'b1) begin
      bsg_SYNC_1_r_4_sv2v_reg <= iclk_data_o[4];
      bsg_SYNC_1_r_3_sv2v_reg <= iclk_data_o[3];
      bsg_SYNC_1_r_2_sv2v_reg <= iclk_data_o[2];
      bsg_SYNC_1_r_1_sv2v_reg <= iclk_data_o[1];
      bsg_SYNC_1_r_0_sv2v_reg <= iclk_data_o[0];
      oclk_data_o_4_sv2v_reg <= bsg_SYNC_1_r[4];
      oclk_data_o_3_sv2v_reg <= bsg_SYNC_1_r[3];
      oclk_data_o_2_sv2v_reg <= bsg_SYNC_1_r[2];
      oclk_data_o_1_sv2v_reg <= bsg_SYNC_1_r[1];
      oclk_data_o_0_sv2v_reg <= bsg_SYNC_1_r[0];
    end 
  end


endmodule



module bsg_launch_sync_sync_width_p5_use_negedge_for_launch_p0_use_async_reset_p0
(
  iclk_i,
  iclk_reset_i,
  oclk_i,
  iclk_data_i,
  iclk_data_o,
  oclk_data_o
);

  input [4:0] iclk_data_i;
  output [4:0] iclk_data_o;
  output [4:0] oclk_data_o;
  input iclk_i;
  input iclk_reset_i;
  input oclk_i;
  wire [4:0] iclk_data_o,oclk_data_o;

  bsg_launch_sync_sync_posedge_5_unit
  \sync.p.z.blss 
  (
    .iclk_i(iclk_i),
    .iclk_reset_i(iclk_reset_i),
    .oclk_i(oclk_i),
    .iclk_data_i(iclk_data_i),
    .iclk_data_o(iclk_data_o),
    .oclk_data_o(oclk_data_o)
  );


endmodule



module bsg_async_ptr_gray
(
  w_clk_i,
  w_reset_i,
  w_inc_i,
  r_clk_i,
  w_ptr_binary_r_o,
  w_ptr_gray_r_o,
  w_ptr_gray_r_rsync_o
);

  output [4:0] w_ptr_binary_r_o;
  output [4:0] w_ptr_gray_r_o;
  output [4:0] w_ptr_gray_r_rsync_o;
  input w_clk_i;
  input w_reset_i;
  input w_inc_i;
  input r_clk_i;
  wire [4:0] w_ptr_binary_r_o,w_ptr_gray_r_o,w_ptr_gray_r_rsync_o,w_ptr_p1_r,w_ptr_p2,
  w_ptr_gray_n;
  wire N0,N1,N2,N3,N4,N5,N6;
  reg w_ptr_p1_r_4_sv2v_reg,w_ptr_p1_r_3_sv2v_reg,w_ptr_p1_r_2_sv2v_reg,
  w_ptr_p1_r_1_sv2v_reg,w_ptr_p1_r_0_sv2v_reg,w_ptr_binary_r_o_4_sv2v_reg,
  w_ptr_binary_r_o_3_sv2v_reg,w_ptr_binary_r_o_2_sv2v_reg,w_ptr_binary_r_o_1_sv2v_reg,
  w_ptr_binary_r_o_0_sv2v_reg;
  assign w_ptr_p1_r[4] = w_ptr_p1_r_4_sv2v_reg;
  assign w_ptr_p1_r[3] = w_ptr_p1_r_3_sv2v_reg;
  assign w_ptr_p1_r[2] = w_ptr_p1_r_2_sv2v_reg;
  assign w_ptr_p1_r[1] = w_ptr_p1_r_1_sv2v_reg;
  assign w_ptr_p1_r[0] = w_ptr_p1_r_0_sv2v_reg;
  assign w_ptr_binary_r_o[4] = w_ptr_binary_r_o_4_sv2v_reg;
  assign w_ptr_binary_r_o[3] = w_ptr_binary_r_o_3_sv2v_reg;
  assign w_ptr_binary_r_o[2] = w_ptr_binary_r_o_2_sv2v_reg;
  assign w_ptr_binary_r_o[1] = w_ptr_binary_r_o_1_sv2v_reg;
  assign w_ptr_binary_r_o[0] = w_ptr_binary_r_o_0_sv2v_reg;

  bsg_launch_sync_sync_width_p5_use_negedge_for_launch_p0_use_async_reset_p0
  ptr_sync
  (
    .iclk_i(w_clk_i),
    .iclk_reset_i(w_reset_i),
    .oclk_i(r_clk_i),
    .iclk_data_i(w_ptr_gray_n),
    .iclk_data_o(w_ptr_gray_r_o),
    .oclk_data_o(w_ptr_gray_r_rsync_o)
  );

  assign w_ptr_p2 = w_ptr_p1_r + 1'b1;
  assign w_ptr_gray_n = (N0)? { w_ptr_p1_r[4:4], N3, N4, N5, N6 } : 
                        (N1)? w_ptr_gray_r_o : 1'b0;
  assign N0 = w_inc_i;
  assign N1 = N2;
  assign N2 = ~w_inc_i;
  assign N3 = w_ptr_p1_r[4] ^ w_ptr_p1_r[3];
  assign N4 = w_ptr_p1_r[3] ^ w_ptr_p1_r[2];
  assign N5 = w_ptr_p1_r[2] ^ w_ptr_p1_r[1];
  assign N6 = w_ptr_p1_r[1] ^ w_ptr_p1_r[0];

  always @(posedge w_clk_i) begin
    if(w_reset_i) begin
      w_ptr_p1_r_4_sv2v_reg <= 1'b0;
      w_ptr_p1_r_3_sv2v_reg <= 1'b0;
      w_ptr_p1_r_2_sv2v_reg <= 1'b0;
      w_ptr_p1_r_1_sv2v_reg <= 1'b0;
      w_ptr_p1_r_0_sv2v_reg <= 1'b1;
      w_ptr_binary_r_o_4_sv2v_reg <= 1'b0;
      w_ptr_binary_r_o_3_sv2v_reg <= 1'b0;
      w_ptr_binary_r_o_2_sv2v_reg <= 1'b0;
      w_ptr_binary_r_o_1_sv2v_reg <= 1'b0;
      w_ptr_binary_r_o_0_sv2v_reg <= 1'b0;
    end else if(w_inc_i) begin
      w_ptr_p1_r_4_sv2v_reg <= w_ptr_p2[4];
      w_ptr_p1_r_3_sv2v_reg <= w_ptr_p2[3];
      w_ptr_p1_r_2_sv2v_reg <= w_ptr_p2[2];
      w_ptr_p1_r_1_sv2v_reg <= w_ptr_p2[1];
      w_ptr_p1_r_0_sv2v_reg <= w_ptr_p2[0];
      w_ptr_binary_r_o_4_sv2v_reg <= w_ptr_p1_r[4];
      w_ptr_binary_r_o_3_sv2v_reg <= w_ptr_p1_r[3];
      w_ptr_binary_r_o_2_sv2v_reg <= w_ptr_p1_r[2];
      w_ptr_binary_r_o_1_sv2v_reg <= w_ptr_p1_r[1];
      w_ptr_binary_r_o_0_sv2v_reg <= w_ptr_p1_r[0];
    end 
  end


endmodule

