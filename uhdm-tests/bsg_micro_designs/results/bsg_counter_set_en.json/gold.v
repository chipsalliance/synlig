

module top
(
  clk_i,
  reset_i,
  set_i,
  en_i,
  val_i,
  count_o
);

  input [2:0] val_i;
  output [2:0] count_o;
  input clk_i;
  input reset_i;
  input set_i;
  input en_i;

  bsg_counter_set_en
  wrapper
  (
    .val_i(val_i),
    .count_o(count_o),
    .clk_i(clk_i),
    .reset_i(reset_i),
    .set_i(set_i),
    .en_i(en_i)
  );


endmodule



module bsg_counter_set_en
(
  clk_i,
  reset_i,
  set_i,
  en_i,
  val_i,
  count_o
);

  input [2:0] val_i;
  output [2:0] count_o;
  input clk_i;
  input reset_i;
  input set_i;
  input en_i;
  wire [2:0] count_o;
  wire N0,N1,N4,N5,N6,N8,N9,N10,N11,N12,N13,N14,N15,N2,N3,N7;
  reg count_o_2_sv2v_reg,count_o_1_sv2v_reg,count_o_0_sv2v_reg;
  assign count_o[2] = count_o_2_sv2v_reg;
  assign count_o[1] = count_o_1_sv2v_reg;
  assign count_o[0] = count_o_0_sv2v_reg;
  assign { N6, N5, N4 } = count_o + 1'b1;
  assign N10 = (N0)? 1'b1 : 
               (N7)? 1'b1 : 
               (N3)? 1'b0 : 1'b0;
  assign N0 = set_i;
  assign { N11, N9, N8 } = (N0)? val_i : 
                           (N7)? { N6, N5, N4 } : 1'b0;
  assign N1 = N15;
  assign N12 = ~reset_i;
  assign N13 = ~set_i;
  assign N14 = N12 & N13;
  assign N15 = en_i & N14;
  assign N2 = en_i | set_i;
  assign N3 = ~N2;
  assign N7 = en_i & N13;

  always @(posedge clk_i) begin
    if(reset_i) begin
      count_o_2_sv2v_reg <= 1'b0;
      count_o_1_sv2v_reg <= 1'b0;
      count_o_0_sv2v_reg <= 1'b0;
    end else if(N10) begin
      count_o_2_sv2v_reg <= N11;
      count_o_1_sv2v_reg <= N9;
      count_o_0_sv2v_reg <= N8;
    end 
  end


endmodule

