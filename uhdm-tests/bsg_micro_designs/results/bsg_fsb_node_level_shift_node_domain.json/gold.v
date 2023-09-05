

module top
(
  en_ls_i,
  clk_i,
  reset_i,
  clk_o,
  reset_o,
  fsb_v_i_o,
  fsb_data_i_o,
  fsb_yumi_o_i,
  fsb_v_o_i,
  fsb_data_o_i,
  fsb_ready_i_o,
  node_v_i_o,
  node_data_i_o,
  node_ready_o_i,
  node_v_o_i,
  node_data_o_i,
  node_yumi_i_o
);

  output [4:0] fsb_data_i_o;
  input [4:0] fsb_data_o_i;
  output [4:0] node_data_i_o;
  input [4:0] node_data_o_i;
  input en_ls_i;
  input clk_i;
  input reset_i;
  input fsb_yumi_o_i;
  input fsb_v_o_i;
  input node_ready_o_i;
  input node_v_o_i;
  output clk_o;
  output reset_o;
  output fsb_v_i_o;
  output fsb_ready_i_o;
  output node_v_i_o;
  output node_yumi_i_o;

  bsg_fsb_node_level_shift_node_domain
  wrapper
  (
    .fsb_data_i_o(fsb_data_i_o),
    .fsb_data_o_i(fsb_data_o_i),
    .node_data_i_o(node_data_i_o),
    .node_data_o_i(node_data_o_i),
    .en_ls_i(en_ls_i),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .fsb_yumi_o_i(fsb_yumi_o_i),
    .fsb_v_o_i(fsb_v_o_i),
    .node_ready_o_i(node_ready_o_i),
    .node_v_o_i(node_v_o_i),
    .clk_o(clk_o),
    .reset_o(reset_o),
    .fsb_v_i_o(fsb_v_i_o),
    .fsb_ready_i_o(fsb_ready_i_o),
    .node_v_i_o(node_v_i_o),
    .node_yumi_i_o(node_yumi_i_o)
  );


endmodule



module bsg_level_shift_up_down_sink_width_p1
(
  v0_data_i,
  v1_en_i,
  v1_data_o
);

  input [0:0] v0_data_i;
  output [0:0] v1_data_o;
  input v1_en_i;
  wire [0:0] v1_data_o;
  assign v1_data_o[0] = v0_data_i[0] & v1_en_i;

endmodule



module bsg_level_shift_up_down_source_width_p1
(
  v0_en_i,
  v0_data_i,
  v1_data_o
);

  input [0:0] v0_data_i;
  output [0:0] v1_data_o;
  input v0_en_i;
  wire [0:0] v1_data_o;
  assign v1_data_o[0] = v0_data_i[0] & v0_en_i;

endmodule



module bsg_level_shift_up_down_source_width_p5
(
  v0_en_i,
  v0_data_i,
  v1_data_o
);

  input [4:0] v0_data_i;
  output [4:0] v1_data_o;
  input v0_en_i;
  wire [4:0] v1_data_o;
  assign v1_data_o[4] = v0_data_i[4] & v0_en_i;
  assign v1_data_o[3] = v0_data_i[3] & v0_en_i;
  assign v1_data_o[2] = v0_data_i[2] & v0_en_i;
  assign v1_data_o[1] = v0_data_i[1] & v0_en_i;
  assign v1_data_o[0] = v0_data_i[0] & v0_en_i;

endmodule



module bsg_level_shift_up_down_sink_width_p5
(
  v0_data_i,
  v1_en_i,
  v1_data_o
);

  input [4:0] v0_data_i;
  output [4:0] v1_data_o;
  input v1_en_i;
  wire [4:0] v1_data_o;
  assign v1_data_o[4] = v0_data_i[4] & v1_en_i;
  assign v1_data_o[3] = v0_data_i[3] & v1_en_i;
  assign v1_data_o[2] = v0_data_i[2] & v1_en_i;
  assign v1_data_o[1] = v0_data_i[1] & v1_en_i;
  assign v1_data_o[0] = v0_data_i[0] & v1_en_i;

endmodule



module bsg_fsb_node_level_shift_node_domain
(
  en_ls_i,
  clk_i,
  reset_i,
  clk_o,
  reset_o,
  fsb_v_i_o,
  fsb_data_i_o,
  fsb_yumi_o_i,
  fsb_v_o_i,
  fsb_data_o_i,
  fsb_ready_i_o,
  node_v_i_o,
  node_data_i_o,
  node_ready_o_i,
  node_v_o_i,
  node_data_o_i,
  node_yumi_i_o
);

  output [4:0] fsb_data_i_o;
  input [4:0] fsb_data_o_i;
  output [4:0] node_data_i_o;
  input [4:0] node_data_o_i;
  input en_ls_i;
  input clk_i;
  input reset_i;
  input fsb_yumi_o_i;
  input fsb_v_o_i;
  input node_ready_o_i;
  input node_v_o_i;
  output clk_o;
  output reset_o;
  output fsb_v_i_o;
  output fsb_ready_i_o;
  output node_v_i_o;
  output node_yumi_i_o;
  wire [4:0] fsb_data_i_o,node_data_i_o;
  wire clk_o,reset_o,fsb_v_i_o,fsb_ready_i_o,node_v_i_o,node_yumi_i_o;

  bsg_level_shift_up_down_sink_width_p1
  clk_ls_inst
  (
    .v0_data_i(clk_i),
    .v1_en_i(1'b1),
    .v1_data_o(clk_o)
  );


  bsg_level_shift_up_down_sink_width_p1
  reset_ls_inst
  (
    .v0_data_i(reset_i),
    .v1_en_i(1'b1),
    .v1_data_o(reset_o)
  );


  bsg_level_shift_up_down_source_width_p1
  n2f_v_ls_inst
  (
    .v0_en_i(en_ls_i),
    .v0_data_i(node_v_o_i),
    .v1_data_o(fsb_v_i_o)
  );


  bsg_level_shift_up_down_source_width_p5
  n2f_data_ls_inst
  (
    .v0_en_i(en_ls_i),
    .v0_data_i(node_data_o_i),
    .v1_data_o(fsb_data_i_o)
  );


  bsg_level_shift_up_down_sink_width_p1
  f2n_yumi_ls_inst
  (
    .v0_data_i(fsb_yumi_o_i),
    .v1_en_i(en_ls_i),
    .v1_data_o(node_yumi_i_o)
  );


  bsg_level_shift_up_down_sink_width_p1
  f2n_v_ls_inst
  (
    .v0_data_i(fsb_v_o_i),
    .v1_en_i(en_ls_i),
    .v1_data_o(node_v_i_o)
  );


  bsg_level_shift_up_down_sink_width_p5
  f2n_data_ls_inst
  (
    .v0_data_i(fsb_data_o_i),
    .v1_en_i(en_ls_i),
    .v1_data_o(node_data_i_o)
  );


  bsg_level_shift_up_down_source_width_p1
  n2f_ready_ls_inst
  (
    .v0_en_i(en_ls_i),
    .v0_data_i(node_ready_o_i),
    .v1_data_o(fsb_ready_i_o)
  );


endmodule

