

module top
(
  clk_i,
  reset_i,
  valid_i,
  ready_o,
  valid_o,
  ready_i
);

  output [1:0] valid_o;
  input [1:0] ready_i;
  input clk_i;
  input reset_i;
  input valid_i;
  output ready_o;

  bsg_round_robin_1_to_n
  wrapper
  (
    .valid_o(valid_o),
    .ready_i(ready_i),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .valid_i(valid_i),
    .ready_o(ready_o)
  );


endmodule



module bsg_circular_ptr_slots_p2_max_add_p1
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
  wire [0:0] o,n_o,\genblk1.genblk1.ptr_r_p1 ;
  wire N0,N1,N2;
  reg o_0_sv2v_reg;
  assign o[0] = o_0_sv2v_reg;
  assign \genblk1.genblk1.ptr_r_p1 [0] = o[0] ^ 1'b1;
  assign n_o[0] = (N0)? \genblk1.genblk1.ptr_r_p1 [0] : 
                  (N1)? o[0] : 1'b0;
  assign N0 = add_i[0];
  assign N1 = N2;
  assign N2 = ~add_i[0];

  always @(posedge clk) begin
    if(reset_i) begin
      o_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      o_0_sv2v_reg <= n_o[0];
    end 
  end


endmodule



module bsg_round_robin_1_to_n
(
  clk_i,
  reset_i,
  valid_i,
  ready_o,
  valid_o,
  ready_i
);

  output [1:0] valid_o;
  input [1:0] ready_i;
  input clk_i;
  input reset_i;
  input valid_i;
  output ready_o;
  wire [1:0] valid_o;
  wire ready_o,N0,\one_to_n.yumi_i ,N1,sv2v_dc_1;
  wire [0:0] \one_to_n.ptr_r ;

  bsg_circular_ptr_slots_p2_max_add_p1
  \one_to_n.circular_ptr 
  (
    .clk(clk_i),
    .reset_i(reset_i),
    .add_i(\one_to_n.yumi_i ),
    .o(\one_to_n.ptr_r [0]),
    .n_o(sv2v_dc_1)
  );

  assign valid_o = { 1'b0, valid_i } << \one_to_n.ptr_r [0];
  assign ready_o = (N1)? ready_i[0] : 
                   (N0)? ready_i[1] : 1'b0;
  assign N0 = \one_to_n.ptr_r [0];
  assign \one_to_n.yumi_i  = valid_i & ready_o;
  assign N1 = ~\one_to_n.ptr_r [0];

endmodule

