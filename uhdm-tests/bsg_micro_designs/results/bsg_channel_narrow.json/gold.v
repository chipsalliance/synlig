

module top
(
  clk_i,
  reset_i,
  data_i,
  deque_o,
  data_o,
  deque_i
);

  input [15:0] data_i;
  output [7:0] data_o;
  input clk_i;
  input reset_i;
  input deque_i;
  output deque_o;

  bsg_channel_narrow
  wrapper
  (
    .data_i(data_i),
    .data_o(data_o),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .deque_i(deque_i),
    .deque_o(deque_o)
  );


endmodule



module bsg_channel_narrow
(
  clk_i,
  reset_i,
  data_i,
  deque_o,
  data_o,
  deque_i
);

  input [15:0] data_i;
  output [7:0] data_o;
  input clk_i;
  input reset_i;
  input deque_i;
  output deque_o;
  wire [7:0] data_o;
  wire deque_o,N0,N1;
  wire [0:0] count_r,count_n;
  reg count_r_0_sv2v_reg;
  assign count_r[0] = count_r_0_sv2v_reg;
  assign data_o[7] = (N1)? data_i[7] : 
                     (N0)? data_i[15] : 1'b0;
  assign N0 = count_r[0];
  assign data_o[6] = (N1)? data_i[6] : 
                     (N0)? data_i[14] : 1'b0;
  assign data_o[5] = (N1)? data_i[5] : 
                     (N0)? data_i[13] : 1'b0;
  assign data_o[4] = (N1)? data_i[4] : 
                     (N0)? data_i[12] : 1'b0;
  assign data_o[3] = (N1)? data_i[3] : 
                     (N0)? data_i[11] : 1'b0;
  assign data_o[2] = (N1)? data_i[2] : 
                     (N0)? data_i[10] : 1'b0;
  assign data_o[1] = (N1)? data_i[1] : 
                     (N0)? data_i[9] : 1'b0;
  assign data_o[0] = (N1)? data_i[0] : 
                     (N0)? data_i[8] : 1'b0;
  assign count_n[0] = count_r[0] ^ deque_i;
  assign N1 = ~count_r[0];
  assign deque_o = deque_i & count_r[0];

  always @(posedge clk_i) begin
    if(reset_i) begin
      count_r_0_sv2v_reg <= 1'b0;
    end else if(1'b1) begin
      count_r_0_sv2v_reg <= count_n[0];
    end 
  end


endmodule

