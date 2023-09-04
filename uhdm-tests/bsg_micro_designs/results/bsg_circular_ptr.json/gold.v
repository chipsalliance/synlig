

module top
(
  clk,
  reset_i,
  add_i,
  o,
  n_o
);

  input [0:0] add_i;
  output [3:0] o;
  output [3:0] n_o;
  input clk;
  input reset_i;

  bsg_circular_ptr
  wrapper
  (
    .add_i(add_i),
    .o(o),
    .n_o(n_o),
    .clk(clk),
    .reset_i(reset_i)
  );


endmodule



module bsg_circular_ptr
(
  clk,
  reset_i,
  add_i,
  o,
  n_o
);

  input [0:0] add_i;
  output [3:0] o;
  output [3:0] n_o;
  input clk;
  input reset_i;
  wire [3:0] o,n_o,\genblk1.genblk1.ptr_r_p1 ;
  wire N0,N1,N2;
  reg o_3_sv2v_reg,o_2_sv2v_reg,o_1_sv2v_reg,o_0_sv2v_reg;
  assign o[3] = o_3_sv2v_reg;
  assign o[2] = o_2_sv2v_reg;
  assign o[1] = o_1_sv2v_reg;
  assign o[0] = o_0_sv2v_reg;
  assign \genblk1.genblk1.ptr_r_p1  = o + 1'b1;
  assign n_o = (N0)? \genblk1.genblk1.ptr_r_p1  : 
               (N1)? o : 1'b0;
  assign N0 = add_i[0];
  assign N1 = N2;
  assign N2 = ~add_i[0];

  always @(posedge clk) begin
    if(reset_i) begin
      o_3_sv2v_reg <= 1'b0;
      o_2_sv2v_reg <= 1'b0;
      o_1_sv2v_reg <= 1'b0;
      o_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      o_3_sv2v_reg <= n_o[3];
      o_2_sv2v_reg <= n_o[2];
      o_1_sv2v_reg <= n_o[1];
      o_0_sv2v_reg <= n_o[0];
    end 
  end


endmodule

