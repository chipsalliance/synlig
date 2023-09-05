

module top
(
  clk_i,
  reset_i,
  v_i,
  yumi_o,
  cache_id_i,
  addr_i,
  dma_data_o,
  dma_data_v_o,
  dma_data_ready_i,
  axi_arid_o,
  axi_araddr_addr_o,
  axi_araddr_cache_id_o,
  axi_arlen_o,
  axi_arsize_o,
  axi_arburst_o,
  axi_arcache_o,
  axi_arprot_o,
  axi_arlock_o,
  axi_arvalid_o,
  axi_arready_i,
  axi_rid_i,
  axi_rdata_i,
  axi_rresp_i,
  axi_rlast_i,
  axi_rvalid_i,
  axi_rready_o
);

  input [0:0] cache_id_i;
  input [27:0] addr_i;
  output [31:0] dma_data_o;
  output [0:0] dma_data_v_o;
  input [0:0] dma_data_ready_i;
  output [5:0] axi_arid_o;
  output [27:0] axi_araddr_addr_o;
  output [0:0] axi_araddr_cache_id_o;
  output [7:0] axi_arlen_o;
  output [2:0] axi_arsize_o;
  output [1:0] axi_arburst_o;
  output [3:0] axi_arcache_o;
  output [2:0] axi_arprot_o;
  input [5:0] axi_rid_i;
  input [31:0] axi_rdata_i;
  input [1:0] axi_rresp_i;
  input clk_i;
  input reset_i;
  input v_i;
  input axi_arready_i;
  input axi_rlast_i;
  input axi_rvalid_i;
  output yumi_o;
  output axi_arlock_o;
  output axi_arvalid_o;
  output axi_rready_o;

  bsg_cache_to_axi_rx
  wrapper
  (
    .cache_id_i(cache_id_i),
    .addr_i(addr_i),
    .dma_data_o(dma_data_o),
    .dma_data_v_o(dma_data_v_o),
    .dma_data_ready_i(dma_data_ready_i),
    .axi_arid_o(axi_arid_o),
    .axi_araddr_addr_o(axi_araddr_addr_o),
    .axi_araddr_cache_id_o(axi_araddr_cache_id_o),
    .axi_arlen_o(axi_arlen_o),
    .axi_arsize_o(axi_arsize_o),
    .axi_arburst_o(axi_arburst_o),
    .axi_arcache_o(axi_arcache_o),
    .axi_arprot_o(axi_arprot_o),
    .axi_rid_i(axi_rid_i),
    .axi_rdata_i(axi_rdata_i),
    .axi_rresp_i(axi_rresp_i),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(v_i),
    .axi_arready_i(axi_arready_i),
    .axi_rlast_i(axi_rlast_i),
    .axi_rvalid_i(axi_rvalid_i),
    .yumi_o(yumi_o),
    .axi_arlock_o(axi_arlock_o),
    .axi_arvalid_o(axi_arvalid_o),
    .axi_rready_o(axi_rready_o)
  );


endmodule



module bsg_circular_ptr_slots_p1_max_add_p1
(
  clk,
  reset_i,
  add_i,
  o,
  n_o
);

  input [0:0] add_i;
  output [0:0] o;
  output [0:0] n_o;
  input clk;
  input reset_i;
  wire [0:0] o,n_o;
  reg o_0_sv2v_reg;
  assign o[0] = o_0_sv2v_reg;
  assign n_o[0] = 1'b0;

  always @(posedge clk) begin
    if(reset_i) begin
      o_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      o_0_sv2v_reg <= 1'b0;
    end 
  end


endmodule



module bsg_fifo_tracker_els_p1
(
  clk_i,
  reset_i,
  enq_i,
  deq_i,
  wptr_r_o,
  rptr_r_o,
  rptr_n_o,
  full_o,
  empty_o
);

  output [0:0] wptr_r_o;
  output [0:0] rptr_r_o;
  output [0:0] rptr_n_o;
  input clk_i;
  input reset_i;
  input enq_i;
  input deq_i;
  output full_o;
  output empty_o;
  wire [0:0] wptr_r_o,rptr_r_o,rptr_n_o;
  wire full_o,empty_o,N0,enq_r,deq_r,N1,equal_ptrs,sv2v_dc_1;
  reg deq_r_sv2v_reg,enq_r_sv2v_reg;
  assign deq_r = deq_r_sv2v_reg;
  assign enq_r = enq_r_sv2v_reg;

  bsg_circular_ptr_slots_p1_max_add_p1
  rptr
  (
    .clk(clk_i),
    .reset_i(reset_i),
    .add_i(deq_i),
    .o(rptr_r_o[0]),
    .n_o(rptr_n_o[0])
  );


  bsg_circular_ptr_slots_p1_max_add_p1
  wptr
  (
    .clk(clk_i),
    .reset_i(reset_i),
    .add_i(enq_i),
    .o(wptr_r_o[0]),
    .n_o(sv2v_dc_1)
  );

  assign N0 = rptr_r_o[0] ^ wptr_r_o[0];
  assign equal_ptrs = ~N0;
  assign N1 = enq_i | deq_i;
  assign empty_o = equal_ptrs & deq_r;
  assign full_o = equal_ptrs & enq_r;

  always @(posedge clk_i) begin
    if(reset_i) begin
      deq_r_sv2v_reg <= 1'b1;
      enq_r_sv2v_reg <= 1'b0;
    end else if(N1) begin
      deq_r_sv2v_reg <= deq_i;
      enq_r_sv2v_reg <= enq_i;
    end 
  end


endmodule



module bsg_mem_1r1w_synth_width_p1_els_p1_read_write_same_addr_p0
(
  w_clk_i,
  w_reset_i,
  w_v_i,
  w_addr_i,
  w_data_i,
  r_v_i,
  r_addr_i,
  r_data_o
);

  input [0:0] w_addr_i;
  input [0:0] w_data_i;
  input [0:0] r_addr_i;
  output [0:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [0:0] r_data_o;
  wire N0,N1,N2,N3,N4,N5;
  reg r_data_o_0_sv2v_reg;
  assign r_data_o[0] = r_data_o_0_sv2v_reg;
  assign N5 = ~w_addr_i[0];
  assign N3 = 1'b1 & N5;
  assign N4 = (N0)? N3 : 
              (N1)? 1'b0 : 1'b0;
  assign N0 = w_v_i;
  assign N1 = N2;
  assign N2 = ~w_v_i;

  always @(posedge w_clk_i) begin
    if(N4) begin
      r_data_o_0_sv2v_reg <= w_data_i[0];
    end 
  end


endmodule



module bsg_mem_1r1w_width_p1_els_p1_read_write_same_addr_p0
(
  w_clk_i,
  w_reset_i,
  w_v_i,
  w_addr_i,
  w_data_i,
  r_v_i,
  r_addr_i,
  r_data_o
);

  input [0:0] w_addr_i;
  input [0:0] w_data_i;
  input [0:0] r_addr_i;
  output [0:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [0:0] r_data_o;

  bsg_mem_1r1w_synth_width_p1_els_p1_read_write_same_addr_p0
  synth
  (
    .w_clk_i(w_clk_i),
    .w_reset_i(w_reset_i),
    .w_v_i(w_v_i),
    .w_addr_i(w_addr_i[0]),
    .w_data_i(w_data_i[0]),
    .r_v_i(r_v_i),
    .r_addr_i(r_addr_i[0]),
    .r_data_o(r_data_o[0])
  );


endmodule



module bsg_fifo_1r1w_small_unhardened_width_p1_els_p1_ready_THEN_valid_p0
(
  clk_i,
  reset_i,
  v_i,
  ready_o,
  data_i,
  v_o,
  data_o,
  yumi_i
);

  input [0:0] data_i;
  output [0:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output ready_o;
  output v_o;
  wire [0:0] data_o,wptr_r,rptr_r;
  wire ready_o,v_o,enque,full,empty,sv2v_dc_1;

  bsg_fifo_tracker_els_p1
  ft
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .enq_i(enque),
    .deq_i(yumi_i),
    .wptr_r_o(wptr_r[0]),
    .rptr_r_o(rptr_r[0]),
    .rptr_n_o(sv2v_dc_1),
    .full_o(full),
    .empty_o(empty)
  );


  bsg_mem_1r1w_width_p1_els_p1_read_write_same_addr_p0
  mem_1r1w
  (
    .w_clk_i(clk_i),
    .w_reset_i(reset_i),
    .w_v_i(enque),
    .w_addr_i(wptr_r[0]),
    .w_data_i(data_i[0]),
    .r_v_i(v_o),
    .r_addr_i(rptr_r[0]),
    .r_data_o(data_o[0])
  );

  assign enque = v_i & ready_o;
  assign ready_o = ~full;
  assign v_o = ~empty;

endmodule



module bsg_fifo_1r1w_small_width_p1_els_p1
(
  clk_i,
  reset_i,
  v_i,
  ready_o,
  data_i,
  v_o,
  data_o,
  yumi_i
);

  input [0:0] data_i;
  output [0:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output ready_o;
  output v_o;
  wire [0:0] data_o;
  wire ready_o,v_o;

  bsg_fifo_1r1w_small_unhardened_width_p1_els_p1_ready_THEN_valid_p0
  \unhardened.un.fifo 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(v_i),
    .ready_o(ready_o),
    .data_i(data_i[0]),
    .v_o(v_o),
    .data_o(data_o[0]),
    .yumi_i(yumi_i)
  );


endmodule



module bsg_mem_1r1w_synth_width_p32_els_p2_read_write_same_addr_p0
(
  w_clk_i,
  w_reset_i,
  w_v_i,
  w_addr_i,
  w_data_i,
  r_v_i,
  r_addr_i,
  r_data_o
);

  input [0:0] w_addr_i;
  input [31:0] w_data_i;
  input [0:0] r_addr_i;
  output [31:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [31:0] r_data_o;
  wire N0,N1,N2,N3,N4,N5,N7,N8;
  wire [63:0] \nz.mem ;
  reg \nz.mem_63_sv2v_reg ,\nz.mem_62_sv2v_reg ,\nz.mem_61_sv2v_reg ,
  \nz.mem_60_sv2v_reg ,\nz.mem_59_sv2v_reg ,\nz.mem_58_sv2v_reg ,\nz.mem_57_sv2v_reg ,
  \nz.mem_56_sv2v_reg ,\nz.mem_55_sv2v_reg ,\nz.mem_54_sv2v_reg ,\nz.mem_53_sv2v_reg ,
  \nz.mem_52_sv2v_reg ,\nz.mem_51_sv2v_reg ,\nz.mem_50_sv2v_reg ,\nz.mem_49_sv2v_reg ,
  \nz.mem_48_sv2v_reg ,\nz.mem_47_sv2v_reg ,\nz.mem_46_sv2v_reg ,\nz.mem_45_sv2v_reg ,
  \nz.mem_44_sv2v_reg ,\nz.mem_43_sv2v_reg ,\nz.mem_42_sv2v_reg ,
  \nz.mem_41_sv2v_reg ,\nz.mem_40_sv2v_reg ,\nz.mem_39_sv2v_reg ,\nz.mem_38_sv2v_reg ,
  \nz.mem_37_sv2v_reg ,\nz.mem_36_sv2v_reg ,\nz.mem_35_sv2v_reg ,\nz.mem_34_sv2v_reg ,
  \nz.mem_33_sv2v_reg ,\nz.mem_32_sv2v_reg ,\nz.mem_31_sv2v_reg ,\nz.mem_30_sv2v_reg ,
  \nz.mem_29_sv2v_reg ,\nz.mem_28_sv2v_reg ,\nz.mem_27_sv2v_reg ,\nz.mem_26_sv2v_reg ,
  \nz.mem_25_sv2v_reg ,\nz.mem_24_sv2v_reg ,\nz.mem_23_sv2v_reg ,
  \nz.mem_22_sv2v_reg ,\nz.mem_21_sv2v_reg ,\nz.mem_20_sv2v_reg ,\nz.mem_19_sv2v_reg ,
  \nz.mem_18_sv2v_reg ,\nz.mem_17_sv2v_reg ,\nz.mem_16_sv2v_reg ,\nz.mem_15_sv2v_reg ,
  \nz.mem_14_sv2v_reg ,\nz.mem_13_sv2v_reg ,\nz.mem_12_sv2v_reg ,\nz.mem_11_sv2v_reg ,
  \nz.mem_10_sv2v_reg ,\nz.mem_9_sv2v_reg ,\nz.mem_8_sv2v_reg ,\nz.mem_7_sv2v_reg ,
  \nz.mem_6_sv2v_reg ,\nz.mem_5_sv2v_reg ,\nz.mem_4_sv2v_reg ,\nz.mem_3_sv2v_reg ,
  \nz.mem_2_sv2v_reg ,\nz.mem_1_sv2v_reg ,\nz.mem_0_sv2v_reg ;
  assign \nz.mem [63] = \nz.mem_63_sv2v_reg ;
  assign \nz.mem [62] = \nz.mem_62_sv2v_reg ;
  assign \nz.mem [61] = \nz.mem_61_sv2v_reg ;
  assign \nz.mem [60] = \nz.mem_60_sv2v_reg ;
  assign \nz.mem [59] = \nz.mem_59_sv2v_reg ;
  assign \nz.mem [58] = \nz.mem_58_sv2v_reg ;
  assign \nz.mem [57] = \nz.mem_57_sv2v_reg ;
  assign \nz.mem [56] = \nz.mem_56_sv2v_reg ;
  assign \nz.mem [55] = \nz.mem_55_sv2v_reg ;
  assign \nz.mem [54] = \nz.mem_54_sv2v_reg ;
  assign \nz.mem [53] = \nz.mem_53_sv2v_reg ;
  assign \nz.mem [52] = \nz.mem_52_sv2v_reg ;
  assign \nz.mem [51] = \nz.mem_51_sv2v_reg ;
  assign \nz.mem [50] = \nz.mem_50_sv2v_reg ;
  assign \nz.mem [49] = \nz.mem_49_sv2v_reg ;
  assign \nz.mem [48] = \nz.mem_48_sv2v_reg ;
  assign \nz.mem [47] = \nz.mem_47_sv2v_reg ;
  assign \nz.mem [46] = \nz.mem_46_sv2v_reg ;
  assign \nz.mem [45] = \nz.mem_45_sv2v_reg ;
  assign \nz.mem [44] = \nz.mem_44_sv2v_reg ;
  assign \nz.mem [43] = \nz.mem_43_sv2v_reg ;
  assign \nz.mem [42] = \nz.mem_42_sv2v_reg ;
  assign \nz.mem [41] = \nz.mem_41_sv2v_reg ;
  assign \nz.mem [40] = \nz.mem_40_sv2v_reg ;
  assign \nz.mem [39] = \nz.mem_39_sv2v_reg ;
  assign \nz.mem [38] = \nz.mem_38_sv2v_reg ;
  assign \nz.mem [37] = \nz.mem_37_sv2v_reg ;
  assign \nz.mem [36] = \nz.mem_36_sv2v_reg ;
  assign \nz.mem [35] = \nz.mem_35_sv2v_reg ;
  assign \nz.mem [34] = \nz.mem_34_sv2v_reg ;
  assign \nz.mem [33] = \nz.mem_33_sv2v_reg ;
  assign \nz.mem [32] = \nz.mem_32_sv2v_reg ;
  assign \nz.mem [31] = \nz.mem_31_sv2v_reg ;
  assign \nz.mem [30] = \nz.mem_30_sv2v_reg ;
  assign \nz.mem [29] = \nz.mem_29_sv2v_reg ;
  assign \nz.mem [28] = \nz.mem_28_sv2v_reg ;
  assign \nz.mem [27] = \nz.mem_27_sv2v_reg ;
  assign \nz.mem [26] = \nz.mem_26_sv2v_reg ;
  assign \nz.mem [25] = \nz.mem_25_sv2v_reg ;
  assign \nz.mem [24] = \nz.mem_24_sv2v_reg ;
  assign \nz.mem [23] = \nz.mem_23_sv2v_reg ;
  assign \nz.mem [22] = \nz.mem_22_sv2v_reg ;
  assign \nz.mem [21] = \nz.mem_21_sv2v_reg ;
  assign \nz.mem [20] = \nz.mem_20_sv2v_reg ;
  assign \nz.mem [19] = \nz.mem_19_sv2v_reg ;
  assign \nz.mem [18] = \nz.mem_18_sv2v_reg ;
  assign \nz.mem [17] = \nz.mem_17_sv2v_reg ;
  assign \nz.mem [16] = \nz.mem_16_sv2v_reg ;
  assign \nz.mem [15] = \nz.mem_15_sv2v_reg ;
  assign \nz.mem [14] = \nz.mem_14_sv2v_reg ;
  assign \nz.mem [13] = \nz.mem_13_sv2v_reg ;
  assign \nz.mem [12] = \nz.mem_12_sv2v_reg ;
  assign \nz.mem [11] = \nz.mem_11_sv2v_reg ;
  assign \nz.mem [10] = \nz.mem_10_sv2v_reg ;
  assign \nz.mem [9] = \nz.mem_9_sv2v_reg ;
  assign \nz.mem [8] = \nz.mem_8_sv2v_reg ;
  assign \nz.mem [7] = \nz.mem_7_sv2v_reg ;
  assign \nz.mem [6] = \nz.mem_6_sv2v_reg ;
  assign \nz.mem [5] = \nz.mem_5_sv2v_reg ;
  assign \nz.mem [4] = \nz.mem_4_sv2v_reg ;
  assign \nz.mem [3] = \nz.mem_3_sv2v_reg ;
  assign \nz.mem [2] = \nz.mem_2_sv2v_reg ;
  assign \nz.mem [1] = \nz.mem_1_sv2v_reg ;
  assign \nz.mem [0] = \nz.mem_0_sv2v_reg ;
  assign r_data_o[31] = (N3)? \nz.mem [31] : 
                        (N0)? \nz.mem [63] : 1'b0;
  assign N0 = r_addr_i[0];
  assign r_data_o[30] = (N3)? \nz.mem [30] : 
                        (N0)? \nz.mem [62] : 1'b0;
  assign r_data_o[29] = (N3)? \nz.mem [29] : 
                        (N0)? \nz.mem [61] : 1'b0;
  assign r_data_o[28] = (N3)? \nz.mem [28] : 
                        (N0)? \nz.mem [60] : 1'b0;
  assign r_data_o[27] = (N3)? \nz.mem [27] : 
                        (N0)? \nz.mem [59] : 1'b0;
  assign r_data_o[26] = (N3)? \nz.mem [26] : 
                        (N0)? \nz.mem [58] : 1'b0;
  assign r_data_o[25] = (N3)? \nz.mem [25] : 
                        (N0)? \nz.mem [57] : 1'b0;
  assign r_data_o[24] = (N3)? \nz.mem [24] : 
                        (N0)? \nz.mem [56] : 1'b0;
  assign r_data_o[23] = (N3)? \nz.mem [23] : 
                        (N0)? \nz.mem [55] : 1'b0;
  assign r_data_o[22] = (N3)? \nz.mem [22] : 
                        (N0)? \nz.mem [54] : 1'b0;
  assign r_data_o[21] = (N3)? \nz.mem [21] : 
                        (N0)? \nz.mem [53] : 1'b0;
  assign r_data_o[20] = (N3)? \nz.mem [20] : 
                        (N0)? \nz.mem [52] : 1'b0;
  assign r_data_o[19] = (N3)? \nz.mem [19] : 
                        (N0)? \nz.mem [51] : 1'b0;
  assign r_data_o[18] = (N3)? \nz.mem [18] : 
                        (N0)? \nz.mem [50] : 1'b0;
  assign r_data_o[17] = (N3)? \nz.mem [17] : 
                        (N0)? \nz.mem [49] : 1'b0;
  assign r_data_o[16] = (N3)? \nz.mem [16] : 
                        (N0)? \nz.mem [48] : 1'b0;
  assign r_data_o[15] = (N3)? \nz.mem [15] : 
                        (N0)? \nz.mem [47] : 1'b0;
  assign r_data_o[14] = (N3)? \nz.mem [14] : 
                        (N0)? \nz.mem [46] : 1'b0;
  assign r_data_o[13] = (N3)? \nz.mem [13] : 
                        (N0)? \nz.mem [45] : 1'b0;
  assign r_data_o[12] = (N3)? \nz.mem [12] : 
                        (N0)? \nz.mem [44] : 1'b0;
  assign r_data_o[11] = (N3)? \nz.mem [11] : 
                        (N0)? \nz.mem [43] : 1'b0;
  assign r_data_o[10] = (N3)? \nz.mem [10] : 
                        (N0)? \nz.mem [42] : 1'b0;
  assign r_data_o[9] = (N3)? \nz.mem [9] : 
                       (N0)? \nz.mem [41] : 1'b0;
  assign r_data_o[8] = (N3)? \nz.mem [8] : 
                       (N0)? \nz.mem [40] : 1'b0;
  assign r_data_o[7] = (N3)? \nz.mem [7] : 
                       (N0)? \nz.mem [39] : 1'b0;
  assign r_data_o[6] = (N3)? \nz.mem [6] : 
                       (N0)? \nz.mem [38] : 1'b0;
  assign r_data_o[5] = (N3)? \nz.mem [5] : 
                       (N0)? \nz.mem [37] : 1'b0;
  assign r_data_o[4] = (N3)? \nz.mem [4] : 
                       (N0)? \nz.mem [36] : 1'b0;
  assign r_data_o[3] = (N3)? \nz.mem [3] : 
                       (N0)? \nz.mem [35] : 1'b0;
  assign r_data_o[2] = (N3)? \nz.mem [2] : 
                       (N0)? \nz.mem [34] : 1'b0;
  assign r_data_o[1] = (N3)? \nz.mem [1] : 
                       (N0)? \nz.mem [33] : 1'b0;
  assign r_data_o[0] = (N3)? \nz.mem [0] : 
                       (N0)? \nz.mem [32] : 1'b0;
  assign N5 = ~w_addr_i[0];
  assign { N8, N7 } = (N1)? { w_addr_i[0:0], N5 } : 
                      (N2)? { 1'b0, 1'b0 } : 1'b0;
  assign N1 = w_v_i;
  assign N2 = N4;
  assign N3 = ~r_addr_i[0];
  assign N4 = ~w_v_i;

  always @(posedge w_clk_i) begin
    if(N8) begin
      \nz.mem_63_sv2v_reg  <= w_data_i[31];
      \nz.mem_62_sv2v_reg  <= w_data_i[30];
      \nz.mem_61_sv2v_reg  <= w_data_i[29];
      \nz.mem_60_sv2v_reg  <= w_data_i[28];
      \nz.mem_59_sv2v_reg  <= w_data_i[27];
      \nz.mem_58_sv2v_reg  <= w_data_i[26];
      \nz.mem_57_sv2v_reg  <= w_data_i[25];
      \nz.mem_56_sv2v_reg  <= w_data_i[24];
      \nz.mem_55_sv2v_reg  <= w_data_i[23];
      \nz.mem_54_sv2v_reg  <= w_data_i[22];
      \nz.mem_53_sv2v_reg  <= w_data_i[21];
      \nz.mem_52_sv2v_reg  <= w_data_i[20];
      \nz.mem_51_sv2v_reg  <= w_data_i[19];
      \nz.mem_50_sv2v_reg  <= w_data_i[18];
      \nz.mem_49_sv2v_reg  <= w_data_i[17];
      \nz.mem_48_sv2v_reg  <= w_data_i[16];
      \nz.mem_47_sv2v_reg  <= w_data_i[15];
      \nz.mem_46_sv2v_reg  <= w_data_i[14];
      \nz.mem_45_sv2v_reg  <= w_data_i[13];
      \nz.mem_44_sv2v_reg  <= w_data_i[12];
      \nz.mem_43_sv2v_reg  <= w_data_i[11];
      \nz.mem_42_sv2v_reg  <= w_data_i[10];
      \nz.mem_41_sv2v_reg  <= w_data_i[9];
      \nz.mem_40_sv2v_reg  <= w_data_i[8];
      \nz.mem_39_sv2v_reg  <= w_data_i[7];
      \nz.mem_38_sv2v_reg  <= w_data_i[6];
      \nz.mem_37_sv2v_reg  <= w_data_i[5];
      \nz.mem_36_sv2v_reg  <= w_data_i[4];
      \nz.mem_35_sv2v_reg  <= w_data_i[3];
      \nz.mem_34_sv2v_reg  <= w_data_i[2];
      \nz.mem_33_sv2v_reg  <= w_data_i[1];
      \nz.mem_32_sv2v_reg  <= w_data_i[0];
    end 
    if(N7) begin
      \nz.mem_31_sv2v_reg  <= w_data_i[31];
      \nz.mem_30_sv2v_reg  <= w_data_i[30];
      \nz.mem_29_sv2v_reg  <= w_data_i[29];
      \nz.mem_28_sv2v_reg  <= w_data_i[28];
      \nz.mem_27_sv2v_reg  <= w_data_i[27];
      \nz.mem_26_sv2v_reg  <= w_data_i[26];
      \nz.mem_25_sv2v_reg  <= w_data_i[25];
      \nz.mem_24_sv2v_reg  <= w_data_i[24];
      \nz.mem_23_sv2v_reg  <= w_data_i[23];
      \nz.mem_22_sv2v_reg  <= w_data_i[22];
      \nz.mem_21_sv2v_reg  <= w_data_i[21];
      \nz.mem_20_sv2v_reg  <= w_data_i[20];
      \nz.mem_19_sv2v_reg  <= w_data_i[19];
      \nz.mem_18_sv2v_reg  <= w_data_i[18];
      \nz.mem_17_sv2v_reg  <= w_data_i[17];
      \nz.mem_16_sv2v_reg  <= w_data_i[16];
      \nz.mem_15_sv2v_reg  <= w_data_i[15];
      \nz.mem_14_sv2v_reg  <= w_data_i[14];
      \nz.mem_13_sv2v_reg  <= w_data_i[13];
      \nz.mem_12_sv2v_reg  <= w_data_i[12];
      \nz.mem_11_sv2v_reg  <= w_data_i[11];
      \nz.mem_10_sv2v_reg  <= w_data_i[10];
      \nz.mem_9_sv2v_reg  <= w_data_i[9];
      \nz.mem_8_sv2v_reg  <= w_data_i[8];
      \nz.mem_7_sv2v_reg  <= w_data_i[7];
      \nz.mem_6_sv2v_reg  <= w_data_i[6];
      \nz.mem_5_sv2v_reg  <= w_data_i[5];
      \nz.mem_4_sv2v_reg  <= w_data_i[4];
      \nz.mem_3_sv2v_reg  <= w_data_i[3];
      \nz.mem_2_sv2v_reg  <= w_data_i[2];
      \nz.mem_1_sv2v_reg  <= w_data_i[1];
      \nz.mem_0_sv2v_reg  <= w_data_i[0];
    end 
  end


endmodule



module bsg_mem_1r1w_width_p32_els_p2_read_write_same_addr_p0
(
  w_clk_i,
  w_reset_i,
  w_v_i,
  w_addr_i,
  w_data_i,
  r_v_i,
  r_addr_i,
  r_data_o
);

  input [0:0] w_addr_i;
  input [31:0] w_data_i;
  input [0:0] r_addr_i;
  output [31:0] r_data_o;
  input w_clk_i;
  input w_reset_i;
  input w_v_i;
  input r_v_i;
  wire [31:0] r_data_o;

  bsg_mem_1r1w_synth_width_p32_els_p2_read_write_same_addr_p0
  synth
  (
    .w_clk_i(w_clk_i),
    .w_reset_i(w_reset_i),
    .w_v_i(w_v_i),
    .w_addr_i(w_addr_i[0]),
    .w_data_i(w_data_i),
    .r_v_i(r_v_i),
    .r_addr_i(r_addr_i[0]),
    .r_data_o(r_data_o)
  );


endmodule



module bsg_two_fifo_width_p32
(
  clk_i,
  reset_i,
  ready_o,
  data_i,
  v_i,
  v_o,
  data_o,
  yumi_i
);

  input [31:0] data_i;
  output [31:0] data_o;
  input clk_i;
  input reset_i;
  input v_i;
  input yumi_i;
  output ready_o;
  output v_o;
  wire [31:0] data_o;
  wire ready_o,v_o,enq_i,tail_r,_0_net_,head_r,empty_r,full_r,N0,N1,N2,N3,N4,N5,N6,N7,
  N8,N9,N10,N11,N12,N13,N14;
  reg full_r_sv2v_reg,tail_r_sv2v_reg,head_r_sv2v_reg,empty_r_sv2v_reg;
  assign full_r = full_r_sv2v_reg;
  assign tail_r = tail_r_sv2v_reg;
  assign head_r = head_r_sv2v_reg;
  assign empty_r = empty_r_sv2v_reg;

  bsg_mem_1r1w_width_p32_els_p2_read_write_same_addr_p0
  mem_1r1w
  (
    .w_clk_i(clk_i),
    .w_reset_i(reset_i),
    .w_v_i(enq_i),
    .w_addr_i(tail_r),
    .w_data_i(data_i),
    .r_v_i(_0_net_),
    .r_addr_i(head_r),
    .r_data_o(data_o)
  );

  assign _0_net_ = ~empty_r;
  assign v_o = ~empty_r;
  assign ready_o = ~full_r;
  assign enq_i = v_i & N5;
  assign N5 = ~full_r;
  assign N1 = enq_i;
  assign N0 = ~tail_r;
  assign N2 = ~head_r;
  assign N3 = N7 | N9;
  assign N7 = empty_r & N6;
  assign N6 = ~enq_i;
  assign N9 = N8 & N6;
  assign N8 = N5 & yumi_i;
  assign N4 = N13 | N14;
  assign N13 = N11 & N12;
  assign N11 = N10 & enq_i;
  assign N10 = ~empty_r;
  assign N12 = ~yumi_i;
  assign N14 = full_r & N12;

  always @(posedge clk_i) begin
    if(reset_i) begin
      full_r_sv2v_reg <= 1'b0;
      empty_r_sv2v_reg <= 1'b1;
    end else if(1'b1) begin
      full_r_sv2v_reg <= N4;
      empty_r_sv2v_reg <= N3;
    end 
    if(reset_i) begin
      tail_r_sv2v_reg <= 1'b0;
    end else if(N1) begin
      tail_r_sv2v_reg <= N0;
    end 
    if(reset_i) begin
      head_r_sv2v_reg <= 1'b0;
    end else if(yumi_i) begin
      head_r_sv2v_reg <= N2;
    end 
  end


endmodule



module bsg_parallel_in_serial_out_width_p32_els_p1
(
  clk_i,
  reset_i,
  valid_i,
  data_i,
  ready_and_o,
  valid_o,
  data_o,
  yumi_i
);

  input [31:0] data_i;
  output [31:0] data_o;
  input clk_i;
  input reset_i;
  input valid_i;
  input yumi_i;
  output ready_and_o;
  output valid_o;
  wire [31:0] data_o;
  wire ready_and_o,valid_o;

  bsg_two_fifo_width_p32
  \two_fifo.fifo0 
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .ready_o(ready_and_o),
    .data_i(data_i),
    .v_i(valid_i),
    .v_o(valid_o),
    .data_o(data_o),
    .yumi_i(yumi_i)
  );


endmodule



module bsg_decode_num_out_p1
(
  i,
  o
);

  input [0:0] i;
  output [0:0] o;
  wire [0:0] o;
  assign o[0] = 1'b1;

endmodule



module bsg_decode_with_v_num_out_p1
(
  i,
  v_i,
  o
);

  input [0:0] i;
  output [0:0] o;
  input v_i;
  wire [0:0] o,lo;

  bsg_decode_num_out_p1
  bd
  (
    .i(i[0]),
    .o(lo[0])
  );

  assign o[0] = v_i & lo[0];

endmodule



module bsg_counter_clear_up_max_val_p3_init_val_p0
(
  clk_i,
  reset_i,
  clear_i,
  up_i,
  count_o
);

  output [1:0] count_o;
  input clk_i;
  input reset_i;
  input clear_i;
  input up_i;
  wire [1:0] count_o;
  wire N0,N1,N4,N5,N6,N8,N9,N10,N11,N12,N13,N14,N2,N3,N7,N30,N15;
  reg count_o_1_sv2v_reg,count_o_0_sv2v_reg;
  assign count_o[1] = count_o_1_sv2v_reg;
  assign count_o[0] = count_o_0_sv2v_reg;
  assign N15 = reset_i | clear_i;
  assign { N6, N5 } = count_o + 1'b1;
  assign N8 = (N0)? 1'b1 : 
              (N7)? 1'b1 : 
              (N3)? 1'b0 : 1'b0;
  assign N0 = clear_i;
  assign N10 = (N1)? 1'b1 : 
               (N30)? 1'b0 : 1'b0;
  assign N1 = up_i;
  assign N9 = (N0)? up_i : 
              (N7)? N5 : 1'b0;
  assign N4 = N14;
  assign N11 = ~reset_i;
  assign N12 = ~clear_i;
  assign N13 = N11 & N12;
  assign N14 = up_i & N13;
  assign N2 = up_i | clear_i;
  assign N3 = ~N2;
  assign N7 = up_i & N12;
  assign N30 = ~up_i;

  always @(posedge clk_i) begin
    if(N15) begin
      count_o_1_sv2v_reg <= 1'b0;
    end else if(N10) begin
      count_o_1_sv2v_reg <= N6;
    end 
    if(reset_i) begin
      count_o_0_sv2v_reg <= 1'b0;
    end else if(N8) begin
      count_o_0_sv2v_reg <= N9;
    end 
  end


endmodule



module bsg_cache_to_axi_rx
(
  clk_i,
  reset_i,
  v_i,
  yumi_o,
  cache_id_i,
  addr_i,
  dma_data_o,
  dma_data_v_o,
  dma_data_ready_i,
  axi_arid_o,
  axi_araddr_addr_o,
  axi_araddr_cache_id_o,
  axi_arlen_o,
  axi_arsize_o,
  axi_arburst_o,
  axi_arcache_o,
  axi_arprot_o,
  axi_arlock_o,
  axi_arvalid_o,
  axi_arready_i,
  axi_rid_i,
  axi_rdata_i,
  axi_rresp_i,
  axi_rlast_i,
  axi_rvalid_i,
  axi_rready_o
);

  input [0:0] cache_id_i;
  input [27:0] addr_i;
  output [31:0] dma_data_o;
  output [0:0] dma_data_v_o;
  input [0:0] dma_data_ready_i;
  output [5:0] axi_arid_o;
  output [27:0] axi_araddr_addr_o;
  output [0:0] axi_araddr_cache_id_o;
  output [7:0] axi_arlen_o;
  output [2:0] axi_arsize_o;
  output [1:0] axi_arburst_o;
  output [3:0] axi_arcache_o;
  output [2:0] axi_arprot_o;
  input [5:0] axi_rid_i;
  input [31:0] axi_rdata_i;
  input [1:0] axi_rresp_i;
  input clk_i;
  input reset_i;
  input v_i;
  input axi_arready_i;
  input axi_rlast_i;
  input axi_rvalid_i;
  output yumi_o;
  output axi_arlock_o;
  output axi_arvalid_o;
  output axi_rready_o;
  wire [31:0] dma_data_o;
  wire [0:0] dma_data_v_o,axi_araddr_cache_id_o,tag_lo,cache_sel;
  wire [5:0] axi_arid_o;
  wire [27:0] axi_araddr_addr_o;
  wire [7:0] axi_arlen_o;
  wire [2:0] axi_arsize_o,axi_arprot_o;
  wire [1:0] axi_arburst_o,count_lo;
  wire [3:0] axi_arcache_o;
  wire yumi_o,axi_arlock_o,axi_arvalid_o,axi_rready_o,N0,tag_fifo_v_li,
  tag_fifo_ready_lo,tag_fifo_v_lo,tag_fifo_yumi_li,piso_v_lo,piso_yumi_li,counter_clear_li,
  counter_up_li,N1,N2,N3,N4;
  assign axi_arsize_o[1] = 1'b1;
  assign axi_arlock_o = 1'b0;
  assign axi_arprot_o[0] = 1'b0;
  assign axi_arprot_o[1] = 1'b0;
  assign axi_arprot_o[2] = 1'b0;
  assign axi_arcache_o[0] = 1'b0;
  assign axi_arcache_o[1] = 1'b0;
  assign axi_arcache_o[2] = 1'b0;
  assign axi_arcache_o[3] = 1'b0;
  assign axi_arburst_o[0] = 1'b0;
  assign axi_arburst_o[1] = 1'b0;
  assign axi_arsize_o[0] = 1'b0;
  assign axi_arsize_o[2] = 1'b0;
  assign axi_arlen_o[0] = 1'b0;
  assign axi_arlen_o[1] = 1'b0;
  assign axi_arlen_o[2] = 1'b0;
  assign axi_arlen_o[3] = 1'b0;
  assign axi_arlen_o[4] = 1'b0;
  assign axi_arlen_o[5] = 1'b0;
  assign axi_arlen_o[6] = 1'b0;
  assign axi_arlen_o[7] = 1'b0;
  assign axi_arid_o[0] = 1'b0;
  assign axi_arid_o[1] = 1'b0;
  assign axi_arid_o[2] = 1'b0;
  assign axi_arid_o[3] = 1'b0;
  assign axi_arid_o[4] = 1'b0;
  assign axi_arid_o[5] = 1'b0;
  assign axi_araddr_cache_id_o[0] = cache_id_i[0];
  assign axi_araddr_addr_o[27] = addr_i[27];
  assign axi_araddr_addr_o[26] = addr_i[26];
  assign axi_araddr_addr_o[25] = addr_i[25];
  assign axi_araddr_addr_o[24] = addr_i[24];
  assign axi_araddr_addr_o[23] = addr_i[23];
  assign axi_araddr_addr_o[22] = addr_i[22];
  assign axi_araddr_addr_o[21] = addr_i[21];
  assign axi_araddr_addr_o[20] = addr_i[20];
  assign axi_araddr_addr_o[19] = addr_i[19];
  assign axi_araddr_addr_o[18] = addr_i[18];
  assign axi_araddr_addr_o[17] = addr_i[17];
  assign axi_araddr_addr_o[16] = addr_i[16];
  assign axi_araddr_addr_o[15] = addr_i[15];
  assign axi_araddr_addr_o[14] = addr_i[14];
  assign axi_araddr_addr_o[13] = addr_i[13];
  assign axi_araddr_addr_o[12] = addr_i[12];
  assign axi_araddr_addr_o[11] = addr_i[11];
  assign axi_araddr_addr_o[10] = addr_i[10];
  assign axi_araddr_addr_o[9] = addr_i[9];
  assign axi_araddr_addr_o[8] = addr_i[8];
  assign axi_araddr_addr_o[7] = addr_i[7];
  assign axi_araddr_addr_o[6] = addr_i[6];
  assign axi_araddr_addr_o[5] = addr_i[5];
  assign axi_araddr_addr_o[4] = addr_i[4];
  assign axi_araddr_addr_o[3] = addr_i[3];
  assign axi_araddr_addr_o[2] = addr_i[2];
  assign axi_araddr_addr_o[1] = addr_i[1];
  assign axi_araddr_addr_o[0] = addr_i[0];

  bsg_fifo_1r1w_small_width_p1_els_p1
  tag_fifo
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(tag_fifo_v_li),
    .ready_o(tag_fifo_ready_lo),
    .data_i(cache_id_i[0]),
    .v_o(tag_fifo_v_lo),
    .data_o(tag_lo[0]),
    .yumi_i(tag_fifo_yumi_li)
  );


  bsg_parallel_in_serial_out_width_p32_els_p1
  piso
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .valid_i(axi_rvalid_i),
    .data_i(axi_rdata_i),
    .ready_and_o(axi_rready_o),
    .valid_o(piso_v_lo),
    .data_o(dma_data_o),
    .yumi_i(piso_yumi_li)
  );


  bsg_decode_with_v_num_out_p1
  demux
  (
    .i(tag_lo[0]),
    .v_i(tag_fifo_v_lo),
    .o(cache_sel[0])
  );


  bsg_counter_clear_up_max_val_p3_init_val_p0
  counter
  (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .clear_i(counter_clear_li),
    .up_i(counter_up_li),
    .count_o(count_lo)
  );

  assign N2 = count_lo[0] & count_lo[1];
  assign counter_clear_li = (N0)? piso_yumi_li : 
                            (N1)? 1'b0 : 1'b0;
  assign N0 = N2;
  assign counter_up_li = (N0)? 1'b0 : 
                         (N1)? piso_yumi_li : 1'b0;
  assign tag_fifo_yumi_li = (N0)? piso_yumi_li : 
                            (N1)? 1'b0 : 1'b0;
  assign yumi_o = N3 & tag_fifo_ready_lo;
  assign N3 = v_i & axi_arready_i;
  assign tag_fifo_v_li = v_i & axi_arready_i;
  assign axi_arvalid_o = v_i & tag_fifo_ready_lo;
  assign dma_data_v_o[0] = cache_sel[0] & piso_v_lo;
  assign piso_yumi_li = N4 & tag_fifo_v_lo;
  assign N4 = dma_data_ready_i[0] & piso_v_lo;
  assign N1 = ~N2;

endmodule

