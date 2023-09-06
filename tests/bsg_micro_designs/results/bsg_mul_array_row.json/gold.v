

module top
(
  clk_i,
  rst_i,
  v_i,
  a_i,
  b_i,
  s_i,
  c_i,
  prod_accum_i,
  a_o,
  b_o,
  s_o,
  c_o,
  prod_accum_o
);

  input [15:0] a_i;
  input [15:0] b_i;
  input [15:0] s_i;
  input [14:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [15:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;

  bsg_mul_array_row
  wrapper
  (
    .a_i(a_i),
    .b_i(b_i),
    .s_i(s_i),
    .prod_accum_i(prod_accum_i),
    .a_o(a_o),
    .b_o(b_o),
    .s_o(s_o),
    .prod_accum_o(prod_accum_o),
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .c_i(c_i),
    .c_o(c_o)
  );


endmodule



module bsg_and_width_p16
(
  a_i,
  b_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] o;
  wire [15:0] o;
  assign o[15] = a_i[15] & b_i[15];
  assign o[14] = a_i[14] & b_i[14];
  assign o[13] = a_i[13] & b_i[13];
  assign o[12] = a_i[12] & b_i[12];
  assign o[11] = a_i[11] & b_i[11];
  assign o[10] = a_i[10] & b_i[10];
  assign o[9] = a_i[9] & b_i[9];
  assign o[8] = a_i[8] & b_i[8];
  assign o[7] = a_i[7] & b_i[7];
  assign o[6] = a_i[6] & b_i[6];
  assign o[5] = a_i[5] & b_i[5];
  assign o[4] = a_i[4] & b_i[4];
  assign o[3] = a_i[3] & b_i[3];
  assign o[2] = a_i[2] & b_i[2];
  assign o[1] = a_i[1] & b_i[1];
  assign o[0] = a_i[0] & b_i[0];

endmodule



module bsg_adder_ripple_carry_width_p16
(
  a_i,
  b_i,
  s_o,
  c_o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] s_o;
  output c_o;
  wire [15:0] s_o;
  wire c_o;
  assign { c_o, s_o } = a_i + b_i;

endmodule



module bsg_mul_array_row
(
  clk_i,
  rst_i,
  v_i,
  a_i,
  b_i,
  s_i,
  c_i,
  prod_accum_i,
  a_o,
  b_o,
  s_o,
  c_o,
  prod_accum_o
);

  input [15:0] a_i;
  input [15:0] b_i;
  input [15:0] s_i;
  input [14:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [15:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,prod_accum_o,pp,ps;
  wire c_o,pc;
  reg prod_accum_o_15_sv2v_reg,prod_accum_o_14_sv2v_reg,prod_accum_o_13_sv2v_reg,
  prod_accum_o_12_sv2v_reg,prod_accum_o_11_sv2v_reg,prod_accum_o_10_sv2v_reg,
  prod_accum_o_9_sv2v_reg,prod_accum_o_8_sv2v_reg,prod_accum_o_7_sv2v_reg,
  prod_accum_o_6_sv2v_reg,prod_accum_o_5_sv2v_reg,prod_accum_o_4_sv2v_reg,prod_accum_o_3_sv2v_reg,
  prod_accum_o_2_sv2v_reg,prod_accum_o_1_sv2v_reg,prod_accum_o_0_sv2v_reg,
  a_o_15_sv2v_reg,a_o_14_sv2v_reg,a_o_13_sv2v_reg,a_o_12_sv2v_reg,a_o_11_sv2v_reg,
  a_o_10_sv2v_reg,a_o_9_sv2v_reg,a_o_8_sv2v_reg,a_o_7_sv2v_reg,a_o_6_sv2v_reg,
  a_o_5_sv2v_reg,a_o_4_sv2v_reg,a_o_3_sv2v_reg,a_o_2_sv2v_reg,a_o_1_sv2v_reg,a_o_0_sv2v_reg,
  b_o_15_sv2v_reg,b_o_14_sv2v_reg,b_o_13_sv2v_reg,b_o_12_sv2v_reg,b_o_11_sv2v_reg,
  b_o_10_sv2v_reg,b_o_9_sv2v_reg,b_o_8_sv2v_reg,b_o_7_sv2v_reg,b_o_6_sv2v_reg,
  b_o_5_sv2v_reg,b_o_4_sv2v_reg,b_o_3_sv2v_reg,b_o_2_sv2v_reg,b_o_1_sv2v_reg,
  b_o_0_sv2v_reg,s_o_15_sv2v_reg,s_o_14_sv2v_reg,s_o_13_sv2v_reg,s_o_12_sv2v_reg,
  s_o_11_sv2v_reg,s_o_10_sv2v_reg,s_o_9_sv2v_reg,s_o_8_sv2v_reg,s_o_7_sv2v_reg,s_o_6_sv2v_reg,
  s_o_5_sv2v_reg,s_o_4_sv2v_reg,s_o_3_sv2v_reg,s_o_2_sv2v_reg,s_o_1_sv2v_reg,
  s_o_0_sv2v_reg,c_o_sv2v_reg;
  assign prod_accum_o[15] = prod_accum_o_15_sv2v_reg;
  assign prod_accum_o[14] = prod_accum_o_14_sv2v_reg;
  assign prod_accum_o[13] = prod_accum_o_13_sv2v_reg;
  assign prod_accum_o[12] = prod_accum_o_12_sv2v_reg;
  assign prod_accum_o[11] = prod_accum_o_11_sv2v_reg;
  assign prod_accum_o[10] = prod_accum_o_10_sv2v_reg;
  assign prod_accum_o[9] = prod_accum_o_9_sv2v_reg;
  assign prod_accum_o[8] = prod_accum_o_8_sv2v_reg;
  assign prod_accum_o[7] = prod_accum_o_7_sv2v_reg;
  assign prod_accum_o[6] = prod_accum_o_6_sv2v_reg;
  assign prod_accum_o[5] = prod_accum_o_5_sv2v_reg;
  assign prod_accum_o[4] = prod_accum_o_4_sv2v_reg;
  assign prod_accum_o[3] = prod_accum_o_3_sv2v_reg;
  assign prod_accum_o[2] = prod_accum_o_2_sv2v_reg;
  assign prod_accum_o[1] = prod_accum_o_1_sv2v_reg;
  assign prod_accum_o[0] = prod_accum_o_0_sv2v_reg;
  assign a_o[15] = a_o_15_sv2v_reg;
  assign a_o[14] = a_o_14_sv2v_reg;
  assign a_o[13] = a_o_13_sv2v_reg;
  assign a_o[12] = a_o_12_sv2v_reg;
  assign a_o[11] = a_o_11_sv2v_reg;
  assign a_o[10] = a_o_10_sv2v_reg;
  assign a_o[9] = a_o_9_sv2v_reg;
  assign a_o[8] = a_o_8_sv2v_reg;
  assign a_o[7] = a_o_7_sv2v_reg;
  assign a_o[6] = a_o_6_sv2v_reg;
  assign a_o[5] = a_o_5_sv2v_reg;
  assign a_o[4] = a_o_4_sv2v_reg;
  assign a_o[3] = a_o_3_sv2v_reg;
  assign a_o[2] = a_o_2_sv2v_reg;
  assign a_o[1] = a_o_1_sv2v_reg;
  assign a_o[0] = a_o_0_sv2v_reg;
  assign b_o[15] = b_o_15_sv2v_reg;
  assign b_o[14] = b_o_14_sv2v_reg;
  assign b_o[13] = b_o_13_sv2v_reg;
  assign b_o[12] = b_o_12_sv2v_reg;
  assign b_o[11] = b_o_11_sv2v_reg;
  assign b_o[10] = b_o_10_sv2v_reg;
  assign b_o[9] = b_o_9_sv2v_reg;
  assign b_o[8] = b_o_8_sv2v_reg;
  assign b_o[7] = b_o_7_sv2v_reg;
  assign b_o[6] = b_o_6_sv2v_reg;
  assign b_o[5] = b_o_5_sv2v_reg;
  assign b_o[4] = b_o_4_sv2v_reg;
  assign b_o[3] = b_o_3_sv2v_reg;
  assign b_o[2] = b_o_2_sv2v_reg;
  assign b_o[1] = b_o_1_sv2v_reg;
  assign b_o[0] = b_o_0_sv2v_reg;
  assign s_o[15] = s_o_15_sv2v_reg;
  assign s_o[14] = s_o_14_sv2v_reg;
  assign s_o[13] = s_o_13_sv2v_reg;
  assign s_o[12] = s_o_12_sv2v_reg;
  assign s_o[11] = s_o_11_sv2v_reg;
  assign s_o[10] = s_o_10_sv2v_reg;
  assign s_o[9] = s_o_9_sv2v_reg;
  assign s_o[8] = s_o_8_sv2v_reg;
  assign s_o[7] = s_o_7_sv2v_reg;
  assign s_o[6] = s_o_6_sv2v_reg;
  assign s_o[5] = s_o_5_sv2v_reg;
  assign s_o[4] = s_o_4_sv2v_reg;
  assign s_o[3] = s_o_3_sv2v_reg;
  assign s_o[2] = s_o_2_sv2v_reg;
  assign s_o[1] = s_o_1_sv2v_reg;
  assign s_o[0] = s_o_0_sv2v_reg;
  assign c_o = c_o_sv2v_reg;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15], b_i[15:15] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o(ps),
    .c_o(pc)
  );


  always @(posedge clk_i) begin
    if(rst_i) begin
      prod_accum_o_15_sv2v_reg <= 1'b0;
      prod_accum_o_14_sv2v_reg <= 1'b0;
      prod_accum_o_13_sv2v_reg <= 1'b0;
      prod_accum_o_12_sv2v_reg <= 1'b0;
      prod_accum_o_11_sv2v_reg <= 1'b0;
      prod_accum_o_10_sv2v_reg <= 1'b0;
      prod_accum_o_9_sv2v_reg <= 1'b0;
      prod_accum_o_8_sv2v_reg <= 1'b0;
      prod_accum_o_7_sv2v_reg <= 1'b0;
      prod_accum_o_6_sv2v_reg <= 1'b0;
      prod_accum_o_5_sv2v_reg <= 1'b0;
      prod_accum_o_4_sv2v_reg <= 1'b0;
      prod_accum_o_3_sv2v_reg <= 1'b0;
      prod_accum_o_2_sv2v_reg <= 1'b0;
      prod_accum_o_1_sv2v_reg <= 1'b0;
      prod_accum_o_0_sv2v_reg <= 1'b0;
      a_o_15_sv2v_reg <= 1'b0;
      a_o_14_sv2v_reg <= 1'b0;
      a_o_13_sv2v_reg <= 1'b0;
      a_o_12_sv2v_reg <= 1'b0;
      a_o_11_sv2v_reg <= 1'b0;
      a_o_10_sv2v_reg <= 1'b0;
      a_o_9_sv2v_reg <= 1'b0;
      a_o_8_sv2v_reg <= 1'b0;
      a_o_7_sv2v_reg <= 1'b0;
      a_o_6_sv2v_reg <= 1'b0;
      a_o_5_sv2v_reg <= 1'b0;
      a_o_4_sv2v_reg <= 1'b0;
      a_o_3_sv2v_reg <= 1'b0;
      a_o_2_sv2v_reg <= 1'b0;
      a_o_1_sv2v_reg <= 1'b0;
      a_o_0_sv2v_reg <= 1'b0;
      b_o_15_sv2v_reg <= 1'b0;
      b_o_14_sv2v_reg <= 1'b0;
      b_o_13_sv2v_reg <= 1'b0;
      b_o_12_sv2v_reg <= 1'b0;
      b_o_11_sv2v_reg <= 1'b0;
      b_o_10_sv2v_reg <= 1'b0;
      b_o_9_sv2v_reg <= 1'b0;
      b_o_8_sv2v_reg <= 1'b0;
      b_o_7_sv2v_reg <= 1'b0;
      b_o_6_sv2v_reg <= 1'b0;
      b_o_5_sv2v_reg <= 1'b0;
      b_o_4_sv2v_reg <= 1'b0;
      b_o_3_sv2v_reg <= 1'b0;
      b_o_2_sv2v_reg <= 1'b0;
      b_o_1_sv2v_reg <= 1'b0;
      b_o_0_sv2v_reg <= 1'b0;
      s_o_15_sv2v_reg <= 1'b0;
      s_o_14_sv2v_reg <= 1'b0;
      s_o_13_sv2v_reg <= 1'b0;
      s_o_12_sv2v_reg <= 1'b0;
      s_o_11_sv2v_reg <= 1'b0;
      s_o_10_sv2v_reg <= 1'b0;
      s_o_9_sv2v_reg <= 1'b0;
      s_o_8_sv2v_reg <= 1'b0;
      s_o_7_sv2v_reg <= 1'b0;
      s_o_6_sv2v_reg <= 1'b0;
      s_o_5_sv2v_reg <= 1'b0;
      s_o_4_sv2v_reg <= 1'b0;
      s_o_3_sv2v_reg <= 1'b0;
      s_o_2_sv2v_reg <= 1'b0;
      s_o_1_sv2v_reg <= 1'b0;
      s_o_0_sv2v_reg <= 1'b0;
      c_o_sv2v_reg <= 1'b0;
    end else if(v_i) begin
      prod_accum_o_15_sv2v_reg <= ps[0];
      prod_accum_o_14_sv2v_reg <= prod_accum_i[14];
      prod_accum_o_13_sv2v_reg <= prod_accum_i[13];
      prod_accum_o_12_sv2v_reg <= prod_accum_i[12];
      prod_accum_o_11_sv2v_reg <= prod_accum_i[11];
      prod_accum_o_10_sv2v_reg <= prod_accum_i[10];
      prod_accum_o_9_sv2v_reg <= prod_accum_i[9];
      prod_accum_o_8_sv2v_reg <= prod_accum_i[8];
      prod_accum_o_7_sv2v_reg <= prod_accum_i[7];
      prod_accum_o_6_sv2v_reg <= prod_accum_i[6];
      prod_accum_o_5_sv2v_reg <= prod_accum_i[5];
      prod_accum_o_4_sv2v_reg <= prod_accum_i[4];
      prod_accum_o_3_sv2v_reg <= prod_accum_i[3];
      prod_accum_o_2_sv2v_reg <= prod_accum_i[2];
      prod_accum_o_1_sv2v_reg <= prod_accum_i[1];
      prod_accum_o_0_sv2v_reg <= prod_accum_i[0];
      a_o_15_sv2v_reg <= a_i[15];
      a_o_14_sv2v_reg <= a_i[14];
      a_o_13_sv2v_reg <= a_i[13];
      a_o_12_sv2v_reg <= a_i[12];
      a_o_11_sv2v_reg <= a_i[11];
      a_o_10_sv2v_reg <= a_i[10];
      a_o_9_sv2v_reg <= a_i[9];
      a_o_8_sv2v_reg <= a_i[8];
      a_o_7_sv2v_reg <= a_i[7];
      a_o_6_sv2v_reg <= a_i[6];
      a_o_5_sv2v_reg <= a_i[5];
      a_o_4_sv2v_reg <= a_i[4];
      a_o_3_sv2v_reg <= a_i[3];
      a_o_2_sv2v_reg <= a_i[2];
      a_o_1_sv2v_reg <= a_i[1];
      a_o_0_sv2v_reg <= a_i[0];
      b_o_15_sv2v_reg <= b_i[15];
      b_o_14_sv2v_reg <= b_i[14];
      b_o_13_sv2v_reg <= b_i[13];
      b_o_12_sv2v_reg <= b_i[12];
      b_o_11_sv2v_reg <= b_i[11];
      b_o_10_sv2v_reg <= b_i[10];
      b_o_9_sv2v_reg <= b_i[9];
      b_o_8_sv2v_reg <= b_i[8];
      b_o_7_sv2v_reg <= b_i[7];
      b_o_6_sv2v_reg <= b_i[6];
      b_o_5_sv2v_reg <= b_i[5];
      b_o_4_sv2v_reg <= b_i[4];
      b_o_3_sv2v_reg <= b_i[3];
      b_o_2_sv2v_reg <= b_i[2];
      b_o_1_sv2v_reg <= b_i[1];
      b_o_0_sv2v_reg <= b_i[0];
      s_o_15_sv2v_reg <= ps[15];
      s_o_14_sv2v_reg <= ps[14];
      s_o_13_sv2v_reg <= ps[13];
      s_o_12_sv2v_reg <= ps[12];
      s_o_11_sv2v_reg <= ps[11];
      s_o_10_sv2v_reg <= ps[10];
      s_o_9_sv2v_reg <= ps[9];
      s_o_8_sv2v_reg <= ps[8];
      s_o_7_sv2v_reg <= ps[7];
      s_o_6_sv2v_reg <= ps[6];
      s_o_5_sv2v_reg <= ps[5];
      s_o_4_sv2v_reg <= ps[4];
      s_o_3_sv2v_reg <= ps[3];
      s_o_2_sv2v_reg <= ps[2];
      s_o_1_sv2v_reg <= ps[1];
      s_o_0_sv2v_reg <= ps[0];
      c_o_sv2v_reg <= pc;
    end 
  end


endmodule

