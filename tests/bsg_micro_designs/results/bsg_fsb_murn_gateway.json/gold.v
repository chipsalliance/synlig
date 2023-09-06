

module top
(
  clk_i,
  reset_i,
  v_i,
  data_i,
  ready_o,
  v_o,
  ready_i,
  node_en_r_o,
  node_reset_r_o
);

  input [15:0] data_i;
  input clk_i;
  input reset_i;
  input v_i;
  input ready_i;
  output ready_o;
  output v_o;
  output node_en_r_o;
  output node_reset_r_o;

  bsg_fsb_murn_gateway
  wrapper
  (
    .data_i(data_i),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .v_i(v_i),
    .ready_i(ready_i),
    .ready_o(ready_o),
    .v_o(v_o),
    .node_en_r_o(node_en_r_o),
    .node_reset_r_o(node_reset_r_o)
  );


endmodule



module bsg_fsb_murn_gateway
(
  clk_i,
  reset_i,
  v_i,
  data_i,
  ready_o,
  v_o,
  ready_i,
  node_en_r_o,
  node_reset_r_o
);

  input [15:0] data_i;
  input clk_i;
  input reset_i;
  input v_i;
  input ready_i;
  output ready_o;
  output v_o;
  output node_en_r_o;
  output node_reset_r_o;
  wire ready_o,v_o,node_en_r_o,node_reset_r_o,N0,N1,N2,N3,\genblk1.for_this_node ,
  \genblk1.for_switch ,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,
  N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,
  N41,N42,N43,N44,N45,N46,N47,N48,N49;
  reg node_en_r_o_sv2v_reg,node_reset_r_o_sv2v_reg;
  assign node_en_r_o = node_en_r_o_sv2v_reg;
  assign node_reset_r_o = node_reset_r_o_sv2v_reg;
  assign N4 = data_i[11] | N18;
  assign N5 = N4 | data_i[9];
  assign N6 = N22 | N5;
  assign N8 = data_i[11] | data_i[10];
  assign N9 = N8 | N12;
  assign N10 = N22 | N9;
  assign N13 = N17 | data_i[10];
  assign N14 = N13 | N12;
  assign N15 = N22 | N14;
  assign N19 = data_i[15] | data_i[14];
  assign N20 = data_i[13] | data_i[12];
  assign N21 = N17 | N18;
  assign N22 = N19 | N20;
  assign N23 = N21 | data_i[9];
  assign N24 = N22 | N23;
  assign N30 = (N0)? 1'b1 : 
               (N1)? 1'b0 : 
               (N29)? node_en_r_o : 1'b0;
  assign N0 = N7;
  assign N1 = N11;
  assign N31 = (N2)? 1'b1 : 
               (N3)? 1'b0 : 
               (N29)? node_reset_r_o : 1'b0;
  assign N2 = N16;
  assign N3 = N25;
  assign \genblk1.for_this_node  = v_i & 1'b0;
  assign \genblk1.for_switch  = N42 & 1'b0;
  assign N42 = v_i & 1'b0;
  assign v_o = N43 & N44;
  assign N43 = node_en_r_o & \genblk1.for_this_node ;
  assign N44 = ~\genblk1.for_switch ;
  assign ready_o = v_i & N49;
  assign N49 = N47 | N48;
  assign N47 = N46 | \genblk1.for_switch ;
  assign N46 = N45 | ready_i;
  assign N45 = ~node_en_r_o;
  assign N48 = ~\genblk1.for_this_node ;
  assign N7 = ~N6;
  assign N11 = ~N10;
  assign N12 = ~data_i[9];
  assign N16 = ~N15;
  assign N17 = ~data_i[11];
  assign N18 = ~data_i[10];
  assign N25 = ~N24;
  assign N26 = N11 | N7;
  assign N27 = N16 | N26;
  assign N28 = N25 | N27;
  assign N29 = ~N28;
  assign N32 = N16 & \genblk1.for_switch ;
  assign N33 = N25 & \genblk1.for_switch ;
  assign N34 = N32 | N33;
  assign N35 = N34 | N44;
  assign N36 = ~N35;
  assign N37 = N7 & \genblk1.for_switch ;
  assign N38 = N11 & \genblk1.for_switch ;
  assign N39 = N37 | N38;
  assign N40 = N39 | N44;
  assign N41 = ~N40;

  always @(posedge clk_i) begin
    if(reset_i) begin
      node_en_r_o_sv2v_reg <= 1'b0;
    end else if(N36) begin
      node_en_r_o_sv2v_reg <= N30;
    end 
    if(reset_i) begin
      node_reset_r_o_sv2v_reg <= 1'b1;
    end else if(N41) begin
      node_reset_r_o_sv2v_reg <= N31;
    end 
  end


endmodule

