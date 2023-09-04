

module top
(
  clk_i,
  reset_i,
  data_i,
  v_i,
  ready_o,
  data_o,
  v_o,
  ready_i
);

  input [31:0] data_i;
  input [1:0] v_i;
  output [1:0] ready_o;
  output [31:0] data_o;
  output [1:0] v_o;
  input [1:0] ready_i;
  input clk_i;
  input reset_i;

  bsg_round_robin_2_to_2
  wrapper
  (
    .data_i(data_i),
    .v_i(v_i),
    .ready_o(ready_o),
    .data_o(data_o),
    .v_o(v_o),
    .ready_i(ready_i),
    .clk_i(clk_i),
    .reset_i(reset_i)
  );


endmodule



module bsg_round_robin_2_to_2
(
  clk_i,
  reset_i,
  data_i,
  v_i,
  ready_o,
  data_o,
  v_o,
  ready_i
);

  input [31:0] data_i;
  input [1:0] v_i;
  output [1:0] ready_o;
  output [31:0] data_o;
  output [1:0] v_o;
  input [1:0] ready_i;
  input clk_i;
  input reset_i;
  wire [1:0] ready_o,v_o;
  wire [31:0] data_o;
  wire N0,N1,head_r,N2,N3,N4,N5,N6;
  reg head_r_sv2v_reg;
  assign head_r = head_r_sv2v_reg;
  assign data_o = (N0)? { data_i[15:0], data_i[31:16] } : 
                  (N1)? data_i : 1'b0;
  assign N0 = head_r;
  assign N1 = N3;
  assign v_o = (N0)? { v_i[0:0], v_i[1:1] } : 
               (N1)? v_i : 1'b0;
  assign ready_o = (N0)? { ready_i[0:0], ready_i[1:1] } : 
                   (N1)? ready_i : 1'b0;
  assign N2 = N5 ^ N6;
  assign N5 = head_r ^ N4;
  assign N4 = v_i[1] & ready_o[1];
  assign N6 = v_i[0] & ready_o[0];
  assign N3 = ~head_r;

  always @(posedge clk_i) begin
    if(reset_i) begin
      head_r_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      head_r_sv2v_reg <= N2;
    end 
  end


endmodule

