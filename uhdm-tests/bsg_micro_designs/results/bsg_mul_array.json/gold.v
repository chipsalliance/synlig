

module top
(
  clk_i,
  rst_i,
  v_i,
  a_i,
  b_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [31:0] o;
  input clk_i;
  input rst_i;
  input v_i;

  bsg_mul_array
  wrapper
  (
    .a_i(a_i),
    .b_i(b_i),
    .o(o),
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i)
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



module bsg_mul_array_row_16_0_0
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
  input [0:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [1:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [1:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[1] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1], b_o[1:1] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_1_0
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
  input [1:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [2:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [2:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_1_,prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[2] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2], b_o[2:2] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_2_0
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
  input [2:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [3:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [3:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_2_,prod_accum_o_1_,prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[3] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_2_ = prod_accum_i[2];
  assign prod_accum_o[2] = prod_accum_o_2_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3], b_o[3:3] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_3_1
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
  input [3:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [4:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp,ps;
  wire [4:0] prod_accum_o;
  wire c_o,pc;
  reg prod_accum_o_4_sv2v_reg,prod_accum_o_3_sv2v_reg,prod_accum_o_2_sv2v_reg,
  prod_accum_o_1_sv2v_reg,prod_accum_o_0_sv2v_reg,a_o_15_sv2v_reg,a_o_14_sv2v_reg,
  a_o_13_sv2v_reg,a_o_12_sv2v_reg,a_o_11_sv2v_reg,a_o_10_sv2v_reg,a_o_9_sv2v_reg,
  a_o_8_sv2v_reg,a_o_7_sv2v_reg,a_o_6_sv2v_reg,a_o_5_sv2v_reg,a_o_4_sv2v_reg,
  a_o_3_sv2v_reg,a_o_2_sv2v_reg,a_o_1_sv2v_reg,a_o_0_sv2v_reg,b_o_15_sv2v_reg,b_o_14_sv2v_reg,
  b_o_13_sv2v_reg,b_o_12_sv2v_reg,b_o_11_sv2v_reg,b_o_10_sv2v_reg,b_o_9_sv2v_reg,
  b_o_8_sv2v_reg,b_o_7_sv2v_reg,b_o_6_sv2v_reg,b_o_5_sv2v_reg,b_o_4_sv2v_reg,
  b_o_3_sv2v_reg,b_o_2_sv2v_reg,b_o_1_sv2v_reg,b_o_0_sv2v_reg,s_o_15_sv2v_reg,
  s_o_14_sv2v_reg,s_o_13_sv2v_reg,s_o_12_sv2v_reg,s_o_11_sv2v_reg,s_o_10_sv2v_reg,
  s_o_9_sv2v_reg,s_o_8_sv2v_reg,s_o_7_sv2v_reg,s_o_6_sv2v_reg,s_o_5_sv2v_reg,s_o_4_sv2v_reg,
  s_o_3_sv2v_reg,s_o_2_sv2v_reg,s_o_1_sv2v_reg,s_o_0_sv2v_reg,c_o_sv2v_reg;
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
    .b_i({ b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4], b_i[4:4] }),
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
      prod_accum_o_4_sv2v_reg <= ps[0];
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



module bsg_mul_array_row_16_4_0
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
  input [4:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [5:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [5:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_4_,prod_accum_o_3_,prod_accum_o_2_,prod_accum_o_1_,
  prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[5] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_4_ = prod_accum_i[4];
  assign prod_accum_o[4] = prod_accum_o_4_;
  assign prod_accum_o_3_ = prod_accum_i[3];
  assign prod_accum_o[3] = prod_accum_o_3_;
  assign prod_accum_o_2_ = prod_accum_i[2];
  assign prod_accum_o[2] = prod_accum_o_2_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5], b_o[5:5] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_5_0
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
  input [5:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [6:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [6:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_5_,prod_accum_o_4_,prod_accum_o_3_,prod_accum_o_2_,
  prod_accum_o_1_,prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[6] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_5_ = prod_accum_i[5];
  assign prod_accum_o[5] = prod_accum_o_5_;
  assign prod_accum_o_4_ = prod_accum_i[4];
  assign prod_accum_o[4] = prod_accum_o_4_;
  assign prod_accum_o_3_ = prod_accum_i[3];
  assign prod_accum_o[3] = prod_accum_o_3_;
  assign prod_accum_o_2_ = prod_accum_i[2];
  assign prod_accum_o[2] = prod_accum_o_2_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6], b_o[6:6] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_6_0
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
  input [6:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [7:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [7:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_6_,prod_accum_o_5_,prod_accum_o_4_,prod_accum_o_3_,
  prod_accum_o_2_,prod_accum_o_1_,prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[7] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_6_ = prod_accum_i[6];
  assign prod_accum_o[6] = prod_accum_o_6_;
  assign prod_accum_o_5_ = prod_accum_i[5];
  assign prod_accum_o[5] = prod_accum_o_5_;
  assign prod_accum_o_4_ = prod_accum_i[4];
  assign prod_accum_o[4] = prod_accum_o_4_;
  assign prod_accum_o_3_ = prod_accum_i[3];
  assign prod_accum_o[3] = prod_accum_o_3_;
  assign prod_accum_o_2_ = prod_accum_i[2];
  assign prod_accum_o[2] = prod_accum_o_2_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7], b_o[7:7] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_7_1
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
  input [7:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [8:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp,ps;
  wire [8:0] prod_accum_o;
  wire c_o,pc;
  reg prod_accum_o_8_sv2v_reg,prod_accum_o_7_sv2v_reg,prod_accum_o_6_sv2v_reg,
  prod_accum_o_5_sv2v_reg,prod_accum_o_4_sv2v_reg,prod_accum_o_3_sv2v_reg,
  prod_accum_o_2_sv2v_reg,prod_accum_o_1_sv2v_reg,prod_accum_o_0_sv2v_reg,a_o_15_sv2v_reg,
  a_o_14_sv2v_reg,a_o_13_sv2v_reg,a_o_12_sv2v_reg,a_o_11_sv2v_reg,a_o_10_sv2v_reg,
  a_o_9_sv2v_reg,a_o_8_sv2v_reg,a_o_7_sv2v_reg,a_o_6_sv2v_reg,a_o_5_sv2v_reg,
  a_o_4_sv2v_reg,a_o_3_sv2v_reg,a_o_2_sv2v_reg,a_o_1_sv2v_reg,a_o_0_sv2v_reg,b_o_15_sv2v_reg,
  b_o_14_sv2v_reg,b_o_13_sv2v_reg,b_o_12_sv2v_reg,b_o_11_sv2v_reg,b_o_10_sv2v_reg,
  b_o_9_sv2v_reg,b_o_8_sv2v_reg,b_o_7_sv2v_reg,b_o_6_sv2v_reg,b_o_5_sv2v_reg,
  b_o_4_sv2v_reg,b_o_3_sv2v_reg,b_o_2_sv2v_reg,b_o_1_sv2v_reg,b_o_0_sv2v_reg,
  s_o_15_sv2v_reg,s_o_14_sv2v_reg,s_o_13_sv2v_reg,s_o_12_sv2v_reg,s_o_11_sv2v_reg,
  s_o_10_sv2v_reg,s_o_9_sv2v_reg,s_o_8_sv2v_reg,s_o_7_sv2v_reg,s_o_6_sv2v_reg,s_o_5_sv2v_reg,
  s_o_4_sv2v_reg,s_o_3_sv2v_reg,s_o_2_sv2v_reg,s_o_1_sv2v_reg,s_o_0_sv2v_reg,
  c_o_sv2v_reg;
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
    .b_i({ b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8], b_i[8:8] }),
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
      prod_accum_o_8_sv2v_reg <= ps[0];
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



module bsg_mul_array_row_16_8_0
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
  input [8:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [9:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [9:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_8_,prod_accum_o_7_,prod_accum_o_6_,prod_accum_o_5_,
  prod_accum_o_4_,prod_accum_o_3_,prod_accum_o_2_,prod_accum_o_1_,prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[9] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_8_ = prod_accum_i[8];
  assign prod_accum_o[8] = prod_accum_o_8_;
  assign prod_accum_o_7_ = prod_accum_i[7];
  assign prod_accum_o[7] = prod_accum_o_7_;
  assign prod_accum_o_6_ = prod_accum_i[6];
  assign prod_accum_o[6] = prod_accum_o_6_;
  assign prod_accum_o_5_ = prod_accum_i[5];
  assign prod_accum_o[5] = prod_accum_o_5_;
  assign prod_accum_o_4_ = prod_accum_i[4];
  assign prod_accum_o[4] = prod_accum_o_4_;
  assign prod_accum_o_3_ = prod_accum_i[3];
  assign prod_accum_o[3] = prod_accum_o_3_;
  assign prod_accum_o_2_ = prod_accum_i[2];
  assign prod_accum_o[2] = prod_accum_o_2_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9], b_o[9:9] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_9_0
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
  input [9:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [10:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [10:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_9_,prod_accum_o_8_,prod_accum_o_7_,prod_accum_o_6_,
  prod_accum_o_5_,prod_accum_o_4_,prod_accum_o_3_,prod_accum_o_2_,prod_accum_o_1_,
  prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[10] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_9_ = prod_accum_i[9];
  assign prod_accum_o[9] = prod_accum_o_9_;
  assign prod_accum_o_8_ = prod_accum_i[8];
  assign prod_accum_o[8] = prod_accum_o_8_;
  assign prod_accum_o_7_ = prod_accum_i[7];
  assign prod_accum_o[7] = prod_accum_o_7_;
  assign prod_accum_o_6_ = prod_accum_i[6];
  assign prod_accum_o[6] = prod_accum_o_6_;
  assign prod_accum_o_5_ = prod_accum_i[5];
  assign prod_accum_o[5] = prod_accum_o_5_;
  assign prod_accum_o_4_ = prod_accum_i[4];
  assign prod_accum_o[4] = prod_accum_o_4_;
  assign prod_accum_o_3_ = prod_accum_i[3];
  assign prod_accum_o[3] = prod_accum_o_3_;
  assign prod_accum_o_2_ = prod_accum_i[2];
  assign prod_accum_o[2] = prod_accum_o_2_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10], b_o[10:10] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_10_0
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
  input [10:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [11:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [11:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_10_,prod_accum_o_9_,prod_accum_o_8_,prod_accum_o_7_,
  prod_accum_o_6_,prod_accum_o_5_,prod_accum_o_4_,prod_accum_o_3_,prod_accum_o_2_,
  prod_accum_o_1_,prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[11] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_10_ = prod_accum_i[10];
  assign prod_accum_o[10] = prod_accum_o_10_;
  assign prod_accum_o_9_ = prod_accum_i[9];
  assign prod_accum_o[9] = prod_accum_o_9_;
  assign prod_accum_o_8_ = prod_accum_i[8];
  assign prod_accum_o[8] = prod_accum_o_8_;
  assign prod_accum_o_7_ = prod_accum_i[7];
  assign prod_accum_o[7] = prod_accum_o_7_;
  assign prod_accum_o_6_ = prod_accum_i[6];
  assign prod_accum_o[6] = prod_accum_o_6_;
  assign prod_accum_o_5_ = prod_accum_i[5];
  assign prod_accum_o[5] = prod_accum_o_5_;
  assign prod_accum_o_4_ = prod_accum_i[4];
  assign prod_accum_o[4] = prod_accum_o_4_;
  assign prod_accum_o_3_ = prod_accum_i[3];
  assign prod_accum_o[3] = prod_accum_o_3_;
  assign prod_accum_o_2_ = prod_accum_i[2];
  assign prod_accum_o[2] = prod_accum_o_2_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11], b_o[11:11] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_11_1
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
  input [11:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [12:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp,ps;
  wire [12:0] prod_accum_o;
  wire c_o,pc;
  reg prod_accum_o_12_sv2v_reg,prod_accum_o_11_sv2v_reg,prod_accum_o_10_sv2v_reg,
  prod_accum_o_9_sv2v_reg,prod_accum_o_8_sv2v_reg,prod_accum_o_7_sv2v_reg,
  prod_accum_o_6_sv2v_reg,prod_accum_o_5_sv2v_reg,prod_accum_o_4_sv2v_reg,
  prod_accum_o_3_sv2v_reg,prod_accum_o_2_sv2v_reg,prod_accum_o_1_sv2v_reg,prod_accum_o_0_sv2v_reg,
  a_o_15_sv2v_reg,a_o_14_sv2v_reg,a_o_13_sv2v_reg,a_o_12_sv2v_reg,a_o_11_sv2v_reg,
  a_o_10_sv2v_reg,a_o_9_sv2v_reg,a_o_8_sv2v_reg,a_o_7_sv2v_reg,a_o_6_sv2v_reg,
  a_o_5_sv2v_reg,a_o_4_sv2v_reg,a_o_3_sv2v_reg,a_o_2_sv2v_reg,a_o_1_sv2v_reg,
  a_o_0_sv2v_reg,b_o_15_sv2v_reg,b_o_14_sv2v_reg,b_o_13_sv2v_reg,b_o_12_sv2v_reg,
  b_o_11_sv2v_reg,b_o_10_sv2v_reg,b_o_9_sv2v_reg,b_o_8_sv2v_reg,b_o_7_sv2v_reg,b_o_6_sv2v_reg,
  b_o_5_sv2v_reg,b_o_4_sv2v_reg,b_o_3_sv2v_reg,b_o_2_sv2v_reg,b_o_1_sv2v_reg,
  b_o_0_sv2v_reg,s_o_15_sv2v_reg,s_o_14_sv2v_reg,s_o_13_sv2v_reg,s_o_12_sv2v_reg,
  s_o_11_sv2v_reg,s_o_10_sv2v_reg,s_o_9_sv2v_reg,s_o_8_sv2v_reg,s_o_7_sv2v_reg,
  s_o_6_sv2v_reg,s_o_5_sv2v_reg,s_o_4_sv2v_reg,s_o_3_sv2v_reg,s_o_2_sv2v_reg,s_o_1_sv2v_reg,
  s_o_0_sv2v_reg,c_o_sv2v_reg;
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
    .b_i({ b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12], b_i[12:12] }),
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
      prod_accum_o_12_sv2v_reg <= ps[0];
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



module bsg_mul_array_row_16_12_0
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
  input [12:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [13:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [13:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_12_,prod_accum_o_11_,prod_accum_o_10_,prod_accum_o_9_,
  prod_accum_o_8_,prod_accum_o_7_,prod_accum_o_6_,prod_accum_o_5_,prod_accum_o_4_,
  prod_accum_o_3_,prod_accum_o_2_,prod_accum_o_1_,prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[13] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_12_ = prod_accum_i[12];
  assign prod_accum_o[12] = prod_accum_o_12_;
  assign prod_accum_o_11_ = prod_accum_i[11];
  assign prod_accum_o[11] = prod_accum_o_11_;
  assign prod_accum_o_10_ = prod_accum_i[10];
  assign prod_accum_o[10] = prod_accum_o_10_;
  assign prod_accum_o_9_ = prod_accum_i[9];
  assign prod_accum_o[9] = prod_accum_o_9_;
  assign prod_accum_o_8_ = prod_accum_i[8];
  assign prod_accum_o[8] = prod_accum_o_8_;
  assign prod_accum_o_7_ = prod_accum_i[7];
  assign prod_accum_o[7] = prod_accum_o_7_;
  assign prod_accum_o_6_ = prod_accum_i[6];
  assign prod_accum_o[6] = prod_accum_o_6_;
  assign prod_accum_o_5_ = prod_accum_i[5];
  assign prod_accum_o[5] = prod_accum_o_5_;
  assign prod_accum_o_4_ = prod_accum_i[4];
  assign prod_accum_o[4] = prod_accum_o_4_;
  assign prod_accum_o_3_ = prod_accum_i[3];
  assign prod_accum_o[3] = prod_accum_o_3_;
  assign prod_accum_o_2_ = prod_accum_i[2];
  assign prod_accum_o[2] = prod_accum_o_2_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13], b_o[13:13] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_13_0
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
  input [13:0] prod_accum_i;
  output [15:0] a_o;
  output [15:0] b_o;
  output [15:0] s_o;
  output [14:0] prod_accum_o;
  input clk_i;
  input rst_i;
  input v_i;
  input c_i;
  output c_o;
  wire [15:0] a_o,b_o,s_o,pp;
  wire [14:0] prod_accum_o;
  wire c_o,s_o_0_,prod_accum_o_13_,prod_accum_o_12_,prod_accum_o_11_,prod_accum_o_10_,
  prod_accum_o_9_,prod_accum_o_8_,prod_accum_o_7_,prod_accum_o_6_,prod_accum_o_5_,
  prod_accum_o_4_,prod_accum_o_3_,prod_accum_o_2_,prod_accum_o_1_,prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[14] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_13_ = prod_accum_i[13];
  assign prod_accum_o[13] = prod_accum_o_13_;
  assign prod_accum_o_12_ = prod_accum_i[12];
  assign prod_accum_o[12] = prod_accum_o_12_;
  assign prod_accum_o_11_ = prod_accum_i[11];
  assign prod_accum_o[11] = prod_accum_o_11_;
  assign prod_accum_o_10_ = prod_accum_i[10];
  assign prod_accum_o[10] = prod_accum_o_10_;
  assign prod_accum_o_9_ = prod_accum_i[9];
  assign prod_accum_o[9] = prod_accum_o_9_;
  assign prod_accum_o_8_ = prod_accum_i[8];
  assign prod_accum_o[8] = prod_accum_o_8_;
  assign prod_accum_o_7_ = prod_accum_i[7];
  assign prod_accum_o[7] = prod_accum_o_7_;
  assign prod_accum_o_6_ = prod_accum_i[6];
  assign prod_accum_o[6] = prod_accum_o_6_;
  assign prod_accum_o_5_ = prod_accum_i[5];
  assign prod_accum_o[5] = prod_accum_o_5_;
  assign prod_accum_o_4_ = prod_accum_i[4];
  assign prod_accum_o[4] = prod_accum_o_4_;
  assign prod_accum_o_3_ = prod_accum_i[3];
  assign prod_accum_o[3] = prod_accum_o_3_;
  assign prod_accum_o_2_ = prod_accum_i[2];
  assign prod_accum_o[2] = prod_accum_o_2_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14], b_o[14:14] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array_row_16_14_0
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
  wire [15:0] a_o,b_o,s_o,prod_accum_o,pp;
  wire c_o,s_o_0_,prod_accum_o_14_,prod_accum_o_13_,prod_accum_o_12_,prod_accum_o_11_,
  prod_accum_o_10_,prod_accum_o_9_,prod_accum_o_8_,prod_accum_o_7_,prod_accum_o_6_,
  prod_accum_o_5_,prod_accum_o_4_,prod_accum_o_3_,prod_accum_o_2_,prod_accum_o_1_,
  prod_accum_o_0_;
  assign a_o[15] = a_i[15];
  assign a_o[14] = a_i[14];
  assign a_o[13] = a_i[13];
  assign a_o[12] = a_i[12];
  assign a_o[11] = a_i[11];
  assign a_o[10] = a_i[10];
  assign a_o[9] = a_i[9];
  assign a_o[8] = a_i[8];
  assign a_o[7] = a_i[7];
  assign a_o[6] = a_i[6];
  assign a_o[5] = a_i[5];
  assign a_o[4] = a_i[4];
  assign a_o[3] = a_i[3];
  assign a_o[2] = a_i[2];
  assign a_o[1] = a_i[1];
  assign a_o[0] = a_i[0];
  assign b_o[15] = b_i[15];
  assign b_o[14] = b_i[14];
  assign b_o[13] = b_i[13];
  assign b_o[12] = b_i[12];
  assign b_o[11] = b_i[11];
  assign b_o[10] = b_i[10];
  assign b_o[9] = b_i[9];
  assign b_o[8] = b_i[8];
  assign b_o[7] = b_i[7];
  assign b_o[6] = b_i[6];
  assign b_o[5] = b_i[5];
  assign b_o[4] = b_i[4];
  assign b_o[3] = b_i[3];
  assign b_o[2] = b_i[2];
  assign b_o[1] = b_i[1];
  assign b_o[0] = b_i[0];
  assign prod_accum_o[15] = s_o_0_;
  assign s_o[0] = s_o_0_;
  assign prod_accum_o_14_ = prod_accum_i[14];
  assign prod_accum_o[14] = prod_accum_o_14_;
  assign prod_accum_o_13_ = prod_accum_i[13];
  assign prod_accum_o[13] = prod_accum_o_13_;
  assign prod_accum_o_12_ = prod_accum_i[12];
  assign prod_accum_o[12] = prod_accum_o_12_;
  assign prod_accum_o_11_ = prod_accum_i[11];
  assign prod_accum_o[11] = prod_accum_o_11_;
  assign prod_accum_o_10_ = prod_accum_i[10];
  assign prod_accum_o[10] = prod_accum_o_10_;
  assign prod_accum_o_9_ = prod_accum_i[9];
  assign prod_accum_o[9] = prod_accum_o_9_;
  assign prod_accum_o_8_ = prod_accum_i[8];
  assign prod_accum_o[8] = prod_accum_o_8_;
  assign prod_accum_o_7_ = prod_accum_i[7];
  assign prod_accum_o[7] = prod_accum_o_7_;
  assign prod_accum_o_6_ = prod_accum_i[6];
  assign prod_accum_o[6] = prod_accum_o_6_;
  assign prod_accum_o_5_ = prod_accum_i[5];
  assign prod_accum_o[5] = prod_accum_o_5_;
  assign prod_accum_o_4_ = prod_accum_i[4];
  assign prod_accum_o[4] = prod_accum_o_4_;
  assign prod_accum_o_3_ = prod_accum_i[3];
  assign prod_accum_o[3] = prod_accum_o_3_;
  assign prod_accum_o_2_ = prod_accum_i[2];
  assign prod_accum_o[2] = prod_accum_o_2_;
  assign prod_accum_o_1_ = prod_accum_i[1];
  assign prod_accum_o[1] = prod_accum_o_1_;
  assign prod_accum_o_0_ = prod_accum_i[0];
  assign prod_accum_o[0] = prod_accum_o_0_;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15], b_o[15:15] }),
    .o(pp)
  );


  bsg_adder_ripple_carry_width_p16
  adder0
  (
    .a_i(pp),
    .b_i({ c_i, s_i[15:1] }),
    .s_o({ s_o[15:1], s_o_0_ }),
    .c_o(c_o)
  );


endmodule



module bsg_mul_array
(
  clk_i,
  rst_i,
  v_i,
  a_i,
  b_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [31:0] o;
  input clk_i;
  input rst_i;
  input v_i;
  wire [31:0] o;
  wire s_r_13__15_,s_r_13__14_,s_r_13__13_,s_r_13__12_,s_r_13__11_,s_r_13__10_,
  s_r_13__9_,s_r_13__8_,s_r_13__7_,s_r_13__6_,s_r_13__5_,s_r_13__4_,s_r_13__3_,s_r_13__2_,
  s_r_13__1_,s_r_13__0_,s_r_12__15_,s_r_12__14_,s_r_12__13_,s_r_12__12_,
  s_r_12__11_,s_r_12__10_,s_r_12__9_,s_r_12__8_,s_r_12__7_,s_r_12__6_,s_r_12__5_,s_r_12__4_,
  s_r_12__3_,s_r_12__2_,s_r_12__1_,s_r_12__0_,s_r_11__15_,s_r_11__14_,s_r_11__13_,
  s_r_11__12_,s_r_11__11_,s_r_11__10_,s_r_11__9_,s_r_11__8_,s_r_11__7_,s_r_11__6_,
  s_r_11__5_,s_r_11__4_,s_r_11__3_,s_r_11__2_,s_r_11__1_,s_r_11__0_,s_r_10__15_,
  s_r_10__14_,s_r_10__13_,s_r_10__12_,s_r_10__11_,s_r_10__10_,s_r_10__9_,s_r_10__8_,
  s_r_10__7_,s_r_10__6_,s_r_10__5_,s_r_10__4_,s_r_10__3_,s_r_10__2_,s_r_10__1_,
  s_r_10__0_,s_r_9__15_,s_r_9__14_,s_r_9__13_,s_r_9__12_,s_r_9__11_,s_r_9__10_,
  s_r_9__9_,s_r_9__8_,s_r_9__7_,s_r_9__6_,s_r_9__5_,s_r_9__4_,s_r_9__3_,s_r_9__2_,
  s_r_9__1_,s_r_9__0_,s_r_8__15_,s_r_8__14_,s_r_8__13_,s_r_8__12_,s_r_8__11_,s_r_8__10_,
  s_r_8__9_,s_r_8__8_,s_r_8__7_,s_r_8__6_,s_r_8__5_,s_r_8__4_,s_r_8__3_,s_r_8__2_,
  s_r_8__1_,s_r_8__0_,s_r_7__15_,s_r_7__14_,s_r_7__13_,s_r_7__12_,s_r_7__11_,
  s_r_7__10_,s_r_7__9_,s_r_7__8_,s_r_7__7_,s_r_7__6_,s_r_7__5_,s_r_7__4_,s_r_7__3_,
  s_r_7__2_,s_r_7__1_,s_r_7__0_,s_r_6__15_,s_r_6__14_,s_r_6__13_,s_r_6__12_,
  s_r_6__11_,s_r_6__10_,s_r_6__9_,s_r_6__8_,s_r_6__7_,s_r_6__6_,s_r_6__5_,s_r_6__4_,
  s_r_6__3_,s_r_6__2_,s_r_6__1_,s_r_6__0_,s_r_5__15_,s_r_5__14_,s_r_5__13_,s_r_5__12_,
  s_r_5__11_,s_r_5__10_,s_r_5__9_,s_r_5__8_,s_r_5__7_,s_r_5__6_,s_r_5__5_,s_r_5__4_,
  s_r_5__3_,s_r_5__2_,s_r_5__1_,s_r_5__0_,s_r_4__15_,s_r_4__14_,s_r_4__13_,
  s_r_4__12_,s_r_4__11_,s_r_4__10_,s_r_4__9_,s_r_4__8_,s_r_4__7_,s_r_4__6_,s_r_4__5_,
  s_r_4__4_,s_r_4__3_,s_r_4__2_,s_r_4__1_,s_r_4__0_,s_r_3__15_,s_r_3__14_,s_r_3__13_,
  s_r_3__12_,s_r_3__11_,s_r_3__10_,s_r_3__9_,s_r_3__8_,s_r_3__7_,s_r_3__6_,s_r_3__5_,
  s_r_3__4_,s_r_3__3_,s_r_3__2_,s_r_3__1_,s_r_3__0_,s_r_2__15_,s_r_2__14_,
  s_r_2__13_,s_r_2__12_,s_r_2__11_,s_r_2__10_,s_r_2__9_,s_r_2__8_,s_r_2__7_,s_r_2__6_,
  s_r_2__5_,s_r_2__4_,s_r_2__3_,s_r_2__2_,s_r_2__1_,s_r_2__0_,s_r_1__15_,s_r_1__14_,
  s_r_1__13_,s_r_1__12_,s_r_1__11_,s_r_1__10_,s_r_1__9_,s_r_1__8_,s_r_1__7_,
  s_r_1__6_,s_r_1__5_,s_r_1__4_,s_r_1__3_,s_r_1__2_,s_r_1__1_,s_r_1__0_,s_r_0__15_,
  s_r_0__14_,s_r_0__13_,s_r_0__12_,s_r_0__11_,s_r_0__10_,s_r_0__9_,s_r_0__8_,s_r_0__7_,
  s_r_0__6_,s_r_0__5_,s_r_0__4_,s_r_0__3_,s_r_0__2_,s_r_0__1_,s_r_0__0_,
  prod_accum_14__15_,prod_accum_13__14_,prod_accum_13__13_,prod_accum_13__12_,
  prod_accum_13__11_,prod_accum_13__10_,prod_accum_13__9_,prod_accum_13__8_,prod_accum_13__7_,
  prod_accum_13__6_,prod_accum_13__5_,prod_accum_13__4_,prod_accum_13__3_,
  prod_accum_13__2_,prod_accum_13__1_,prod_accum_13__0_,prod_accum_12__13_,prod_accum_12__12_,
  prod_accum_12__11_,prod_accum_12__10_,prod_accum_12__9_,prod_accum_12__8_,
  prod_accum_12__7_,prod_accum_12__6_,prod_accum_12__5_,prod_accum_12__4_,
  prod_accum_12__3_,prod_accum_12__2_,prod_accum_12__1_,prod_accum_12__0_,prod_accum_11__12_,
  prod_accum_11__11_,prod_accum_11__10_,prod_accum_11__9_,prod_accum_11__8_,
  prod_accum_11__7_,prod_accum_11__6_,prod_accum_11__5_,prod_accum_11__4_,
  prod_accum_11__3_,prod_accum_11__2_,prod_accum_11__1_,prod_accum_11__0_,prod_accum_10__11_,
  prod_accum_10__10_,prod_accum_10__9_,prod_accum_10__8_,prod_accum_10__7_,
  prod_accum_10__6_,prod_accum_10__5_,prod_accum_10__4_,prod_accum_10__3_,prod_accum_10__2_,
  prod_accum_10__1_,prod_accum_10__0_,prod_accum_9__10_,prod_accum_9__9_,
  prod_accum_9__8_,prod_accum_9__7_,prod_accum_9__6_,prod_accum_9__5_,prod_accum_9__4_,
  prod_accum_9__3_,prod_accum_9__2_,prod_accum_9__1_,prod_accum_9__0_,prod_accum_8__9_,
  prod_accum_8__8_,prod_accum_8__7_,prod_accum_8__6_,prod_accum_8__5_,
  prod_accum_8__4_,prod_accum_8__3_,prod_accum_8__2_,prod_accum_8__1_,prod_accum_8__0_,
  prod_accum_7__8_,prod_accum_7__7_,prod_accum_7__6_,prod_accum_7__5_,prod_accum_7__4_,
  prod_accum_7__3_,prod_accum_7__2_,prod_accum_7__1_,prod_accum_7__0_,
  prod_accum_6__7_,prod_accum_6__6_,prod_accum_6__5_,prod_accum_6__4_,prod_accum_6__3_,
  prod_accum_6__2_,prod_accum_6__1_,prod_accum_6__0_,prod_accum_5__6_,prod_accum_5__5_,
  prod_accum_5__4_,prod_accum_5__3_,prod_accum_5__2_,prod_accum_5__1_,prod_accum_5__0_,
  prod_accum_4__5_,prod_accum_4__4_,prod_accum_4__3_,prod_accum_4__2_,
  prod_accum_4__1_,prod_accum_4__0_,prod_accum_3__4_,prod_accum_3__3_,prod_accum_3__2_,
  prod_accum_3__1_,prod_accum_3__0_,prod_accum_2__3_,prod_accum_2__2_,prod_accum_2__1_,
  prod_accum_2__0_,prod_accum_1__2_,prod_accum_1__1_,prod_accum_1__0_,
  prod_accum_0__1_,prod_accum_0__0_,sv2v_dc_1,sv2v_dc_2,sv2v_dc_3,sv2v_dc_4,sv2v_dc_5,sv2v_dc_6,
  sv2v_dc_7,sv2v_dc_8,sv2v_dc_9,sv2v_dc_10,sv2v_dc_11,sv2v_dc_12,sv2v_dc_13,
  sv2v_dc_14,sv2v_dc_15,sv2v_dc_16,sv2v_dc_17,sv2v_dc_18,sv2v_dc_19,sv2v_dc_20,
  sv2v_dc_21,sv2v_dc_22,sv2v_dc_23,sv2v_dc_24,sv2v_dc_25,sv2v_dc_26,sv2v_dc_27,sv2v_dc_28,
  sv2v_dc_29,sv2v_dc_30,sv2v_dc_31,sv2v_dc_32;
  wire [15:0] pp0;
  wire [223:0] a_r,b_r;
  wire [13:0] c_r;

  bsg_and_width_p16
  and0
  (
    .a_i(a_i),
    .b_i({ b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0], b_i[0:0] }),
    .o(pp0)
  );


  bsg_mul_array_row_16_0_0
  \genblk1_0_.genblk1.first_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_i),
    .b_i(b_i),
    .s_i(pp0),
    .c_i(1'b0),
    .prod_accum_i(pp0[0]),
    .a_o(a_r[15:0]),
    .b_o(b_r[15:0]),
    .s_o({ s_r_0__15_, s_r_0__14_, s_r_0__13_, s_r_0__12_, s_r_0__11_, s_r_0__10_, s_r_0__9_, s_r_0__8_, s_r_0__7_, s_r_0__6_, s_r_0__5_, s_r_0__4_, s_r_0__3_, s_r_0__2_, s_r_0__1_, s_r_0__0_ }),
    .c_o(c_r[0]),
    .prod_accum_o({ prod_accum_0__1_, prod_accum_0__0_ })
  );


  bsg_mul_array_row_16_1_0
  \genblk1_1_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[15:0]),
    .b_i(b_r[15:0]),
    .s_i({ s_r_0__15_, s_r_0__14_, s_r_0__13_, s_r_0__12_, s_r_0__11_, s_r_0__10_, s_r_0__9_, s_r_0__8_, s_r_0__7_, s_r_0__6_, s_r_0__5_, s_r_0__4_, s_r_0__3_, s_r_0__2_, s_r_0__1_, s_r_0__0_ }),
    .c_i(c_r[0]),
    .prod_accum_i({ prod_accum_0__1_, prod_accum_0__0_ }),
    .a_o(a_r[31:16]),
    .b_o(b_r[31:16]),
    .s_o({ s_r_1__15_, s_r_1__14_, s_r_1__13_, s_r_1__12_, s_r_1__11_, s_r_1__10_, s_r_1__9_, s_r_1__8_, s_r_1__7_, s_r_1__6_, s_r_1__5_, s_r_1__4_, s_r_1__3_, s_r_1__2_, s_r_1__1_, s_r_1__0_ }),
    .c_o(c_r[1]),
    .prod_accum_o({ prod_accum_1__2_, prod_accum_1__1_, prod_accum_1__0_ })
  );


  bsg_mul_array_row_16_2_0
  \genblk1_2_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[31:16]),
    .b_i(b_r[31:16]),
    .s_i({ s_r_1__15_, s_r_1__14_, s_r_1__13_, s_r_1__12_, s_r_1__11_, s_r_1__10_, s_r_1__9_, s_r_1__8_, s_r_1__7_, s_r_1__6_, s_r_1__5_, s_r_1__4_, s_r_1__3_, s_r_1__2_, s_r_1__1_, s_r_1__0_ }),
    .c_i(c_r[1]),
    .prod_accum_i({ prod_accum_1__2_, prod_accum_1__1_, prod_accum_1__0_ }),
    .a_o(a_r[47:32]),
    .b_o(b_r[47:32]),
    .s_o({ s_r_2__15_, s_r_2__14_, s_r_2__13_, s_r_2__12_, s_r_2__11_, s_r_2__10_, s_r_2__9_, s_r_2__8_, s_r_2__7_, s_r_2__6_, s_r_2__5_, s_r_2__4_, s_r_2__3_, s_r_2__2_, s_r_2__1_, s_r_2__0_ }),
    .c_o(c_r[2]),
    .prod_accum_o({ prod_accum_2__3_, prod_accum_2__2_, prod_accum_2__1_, prod_accum_2__0_ })
  );


  bsg_mul_array_row_16_3_1
  \genblk1_3_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[47:32]),
    .b_i(b_r[47:32]),
    .s_i({ s_r_2__15_, s_r_2__14_, s_r_2__13_, s_r_2__12_, s_r_2__11_, s_r_2__10_, s_r_2__9_, s_r_2__8_, s_r_2__7_, s_r_2__6_, s_r_2__5_, s_r_2__4_, s_r_2__3_, s_r_2__2_, s_r_2__1_, s_r_2__0_ }),
    .c_i(c_r[2]),
    .prod_accum_i({ prod_accum_2__3_, prod_accum_2__2_, prod_accum_2__1_, prod_accum_2__0_ }),
    .a_o(a_r[63:48]),
    .b_o(b_r[63:48]),
    .s_o({ s_r_3__15_, s_r_3__14_, s_r_3__13_, s_r_3__12_, s_r_3__11_, s_r_3__10_, s_r_3__9_, s_r_3__8_, s_r_3__7_, s_r_3__6_, s_r_3__5_, s_r_3__4_, s_r_3__3_, s_r_3__2_, s_r_3__1_, s_r_3__0_ }),
    .c_o(c_r[3]),
    .prod_accum_o({ prod_accum_3__4_, prod_accum_3__3_, prod_accum_3__2_, prod_accum_3__1_, prod_accum_3__0_ })
  );


  bsg_mul_array_row_16_4_0
  \genblk1_4_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[63:48]),
    .b_i(b_r[63:48]),
    .s_i({ s_r_3__15_, s_r_3__14_, s_r_3__13_, s_r_3__12_, s_r_3__11_, s_r_3__10_, s_r_3__9_, s_r_3__8_, s_r_3__7_, s_r_3__6_, s_r_3__5_, s_r_3__4_, s_r_3__3_, s_r_3__2_, s_r_3__1_, s_r_3__0_ }),
    .c_i(c_r[3]),
    .prod_accum_i({ prod_accum_3__4_, prod_accum_3__3_, prod_accum_3__2_, prod_accum_3__1_, prod_accum_3__0_ }),
    .a_o(a_r[79:64]),
    .b_o(b_r[79:64]),
    .s_o({ s_r_4__15_, s_r_4__14_, s_r_4__13_, s_r_4__12_, s_r_4__11_, s_r_4__10_, s_r_4__9_, s_r_4__8_, s_r_4__7_, s_r_4__6_, s_r_4__5_, s_r_4__4_, s_r_4__3_, s_r_4__2_, s_r_4__1_, s_r_4__0_ }),
    .c_o(c_r[4]),
    .prod_accum_o({ prod_accum_4__5_, prod_accum_4__4_, prod_accum_4__3_, prod_accum_4__2_, prod_accum_4__1_, prod_accum_4__0_ })
  );


  bsg_mul_array_row_16_5_0
  \genblk1_5_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[79:64]),
    .b_i(b_r[79:64]),
    .s_i({ s_r_4__15_, s_r_4__14_, s_r_4__13_, s_r_4__12_, s_r_4__11_, s_r_4__10_, s_r_4__9_, s_r_4__8_, s_r_4__7_, s_r_4__6_, s_r_4__5_, s_r_4__4_, s_r_4__3_, s_r_4__2_, s_r_4__1_, s_r_4__0_ }),
    .c_i(c_r[4]),
    .prod_accum_i({ prod_accum_4__5_, prod_accum_4__4_, prod_accum_4__3_, prod_accum_4__2_, prod_accum_4__1_, prod_accum_4__0_ }),
    .a_o(a_r[95:80]),
    .b_o(b_r[95:80]),
    .s_o({ s_r_5__15_, s_r_5__14_, s_r_5__13_, s_r_5__12_, s_r_5__11_, s_r_5__10_, s_r_5__9_, s_r_5__8_, s_r_5__7_, s_r_5__6_, s_r_5__5_, s_r_5__4_, s_r_5__3_, s_r_5__2_, s_r_5__1_, s_r_5__0_ }),
    .c_o(c_r[5]),
    .prod_accum_o({ prod_accum_5__6_, prod_accum_5__5_, prod_accum_5__4_, prod_accum_5__3_, prod_accum_5__2_, prod_accum_5__1_, prod_accum_5__0_ })
  );


  bsg_mul_array_row_16_6_0
  \genblk1_6_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[95:80]),
    .b_i(b_r[95:80]),
    .s_i({ s_r_5__15_, s_r_5__14_, s_r_5__13_, s_r_5__12_, s_r_5__11_, s_r_5__10_, s_r_5__9_, s_r_5__8_, s_r_5__7_, s_r_5__6_, s_r_5__5_, s_r_5__4_, s_r_5__3_, s_r_5__2_, s_r_5__1_, s_r_5__0_ }),
    .c_i(c_r[5]),
    .prod_accum_i({ prod_accum_5__6_, prod_accum_5__5_, prod_accum_5__4_, prod_accum_5__3_, prod_accum_5__2_, prod_accum_5__1_, prod_accum_5__0_ }),
    .a_o(a_r[111:96]),
    .b_o(b_r[111:96]),
    .s_o({ s_r_6__15_, s_r_6__14_, s_r_6__13_, s_r_6__12_, s_r_6__11_, s_r_6__10_, s_r_6__9_, s_r_6__8_, s_r_6__7_, s_r_6__6_, s_r_6__5_, s_r_6__4_, s_r_6__3_, s_r_6__2_, s_r_6__1_, s_r_6__0_ }),
    .c_o(c_r[6]),
    .prod_accum_o({ prod_accum_6__7_, prod_accum_6__6_, prod_accum_6__5_, prod_accum_6__4_, prod_accum_6__3_, prod_accum_6__2_, prod_accum_6__1_, prod_accum_6__0_ })
  );


  bsg_mul_array_row_16_7_1
  \genblk1_7_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[111:96]),
    .b_i(b_r[111:96]),
    .s_i({ s_r_6__15_, s_r_6__14_, s_r_6__13_, s_r_6__12_, s_r_6__11_, s_r_6__10_, s_r_6__9_, s_r_6__8_, s_r_6__7_, s_r_6__6_, s_r_6__5_, s_r_6__4_, s_r_6__3_, s_r_6__2_, s_r_6__1_, s_r_6__0_ }),
    .c_i(c_r[6]),
    .prod_accum_i({ prod_accum_6__7_, prod_accum_6__6_, prod_accum_6__5_, prod_accum_6__4_, prod_accum_6__3_, prod_accum_6__2_, prod_accum_6__1_, prod_accum_6__0_ }),
    .a_o(a_r[127:112]),
    .b_o(b_r[127:112]),
    .s_o({ s_r_7__15_, s_r_7__14_, s_r_7__13_, s_r_7__12_, s_r_7__11_, s_r_7__10_, s_r_7__9_, s_r_7__8_, s_r_7__7_, s_r_7__6_, s_r_7__5_, s_r_7__4_, s_r_7__3_, s_r_7__2_, s_r_7__1_, s_r_7__0_ }),
    .c_o(c_r[7]),
    .prod_accum_o({ prod_accum_7__8_, prod_accum_7__7_, prod_accum_7__6_, prod_accum_7__5_, prod_accum_7__4_, prod_accum_7__3_, prod_accum_7__2_, prod_accum_7__1_, prod_accum_7__0_ })
  );


  bsg_mul_array_row_16_8_0
  \genblk1_8_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[127:112]),
    .b_i(b_r[127:112]),
    .s_i({ s_r_7__15_, s_r_7__14_, s_r_7__13_, s_r_7__12_, s_r_7__11_, s_r_7__10_, s_r_7__9_, s_r_7__8_, s_r_7__7_, s_r_7__6_, s_r_7__5_, s_r_7__4_, s_r_7__3_, s_r_7__2_, s_r_7__1_, s_r_7__0_ }),
    .c_i(c_r[7]),
    .prod_accum_i({ prod_accum_7__8_, prod_accum_7__7_, prod_accum_7__6_, prod_accum_7__5_, prod_accum_7__4_, prod_accum_7__3_, prod_accum_7__2_, prod_accum_7__1_, prod_accum_7__0_ }),
    .a_o(a_r[143:128]),
    .b_o(b_r[143:128]),
    .s_o({ s_r_8__15_, s_r_8__14_, s_r_8__13_, s_r_8__12_, s_r_8__11_, s_r_8__10_, s_r_8__9_, s_r_8__8_, s_r_8__7_, s_r_8__6_, s_r_8__5_, s_r_8__4_, s_r_8__3_, s_r_8__2_, s_r_8__1_, s_r_8__0_ }),
    .c_o(c_r[8]),
    .prod_accum_o({ prod_accum_8__9_, prod_accum_8__8_, prod_accum_8__7_, prod_accum_8__6_, prod_accum_8__5_, prod_accum_8__4_, prod_accum_8__3_, prod_accum_8__2_, prod_accum_8__1_, prod_accum_8__0_ })
  );


  bsg_mul_array_row_16_9_0
  \genblk1_9_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[143:128]),
    .b_i(b_r[143:128]),
    .s_i({ s_r_8__15_, s_r_8__14_, s_r_8__13_, s_r_8__12_, s_r_8__11_, s_r_8__10_, s_r_8__9_, s_r_8__8_, s_r_8__7_, s_r_8__6_, s_r_8__5_, s_r_8__4_, s_r_8__3_, s_r_8__2_, s_r_8__1_, s_r_8__0_ }),
    .c_i(c_r[8]),
    .prod_accum_i({ prod_accum_8__9_, prod_accum_8__8_, prod_accum_8__7_, prod_accum_8__6_, prod_accum_8__5_, prod_accum_8__4_, prod_accum_8__3_, prod_accum_8__2_, prod_accum_8__1_, prod_accum_8__0_ }),
    .a_o(a_r[159:144]),
    .b_o(b_r[159:144]),
    .s_o({ s_r_9__15_, s_r_9__14_, s_r_9__13_, s_r_9__12_, s_r_9__11_, s_r_9__10_, s_r_9__9_, s_r_9__8_, s_r_9__7_, s_r_9__6_, s_r_9__5_, s_r_9__4_, s_r_9__3_, s_r_9__2_, s_r_9__1_, s_r_9__0_ }),
    .c_o(c_r[9]),
    .prod_accum_o({ prod_accum_9__10_, prod_accum_9__9_, prod_accum_9__8_, prod_accum_9__7_, prod_accum_9__6_, prod_accum_9__5_, prod_accum_9__4_, prod_accum_9__3_, prod_accum_9__2_, prod_accum_9__1_, prod_accum_9__0_ })
  );


  bsg_mul_array_row_16_10_0
  \genblk1_10_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[159:144]),
    .b_i(b_r[159:144]),
    .s_i({ s_r_9__15_, s_r_9__14_, s_r_9__13_, s_r_9__12_, s_r_9__11_, s_r_9__10_, s_r_9__9_, s_r_9__8_, s_r_9__7_, s_r_9__6_, s_r_9__5_, s_r_9__4_, s_r_9__3_, s_r_9__2_, s_r_9__1_, s_r_9__0_ }),
    .c_i(c_r[9]),
    .prod_accum_i({ prod_accum_9__10_, prod_accum_9__9_, prod_accum_9__8_, prod_accum_9__7_, prod_accum_9__6_, prod_accum_9__5_, prod_accum_9__4_, prod_accum_9__3_, prod_accum_9__2_, prod_accum_9__1_, prod_accum_9__0_ }),
    .a_o(a_r[175:160]),
    .b_o(b_r[175:160]),
    .s_o({ s_r_10__15_, s_r_10__14_, s_r_10__13_, s_r_10__12_, s_r_10__11_, s_r_10__10_, s_r_10__9_, s_r_10__8_, s_r_10__7_, s_r_10__6_, s_r_10__5_, s_r_10__4_, s_r_10__3_, s_r_10__2_, s_r_10__1_, s_r_10__0_ }),
    .c_o(c_r[10]),
    .prod_accum_o({ prod_accum_10__11_, prod_accum_10__10_, prod_accum_10__9_, prod_accum_10__8_, prod_accum_10__7_, prod_accum_10__6_, prod_accum_10__5_, prod_accum_10__4_, prod_accum_10__3_, prod_accum_10__2_, prod_accum_10__1_, prod_accum_10__0_ })
  );


  bsg_mul_array_row_16_11_1
  \genblk1_11_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[175:160]),
    .b_i(b_r[175:160]),
    .s_i({ s_r_10__15_, s_r_10__14_, s_r_10__13_, s_r_10__12_, s_r_10__11_, s_r_10__10_, s_r_10__9_, s_r_10__8_, s_r_10__7_, s_r_10__6_, s_r_10__5_, s_r_10__4_, s_r_10__3_, s_r_10__2_, s_r_10__1_, s_r_10__0_ }),
    .c_i(c_r[10]),
    .prod_accum_i({ prod_accum_10__11_, prod_accum_10__10_, prod_accum_10__9_, prod_accum_10__8_, prod_accum_10__7_, prod_accum_10__6_, prod_accum_10__5_, prod_accum_10__4_, prod_accum_10__3_, prod_accum_10__2_, prod_accum_10__1_, prod_accum_10__0_ }),
    .a_o(a_r[191:176]),
    .b_o(b_r[191:176]),
    .s_o({ s_r_11__15_, s_r_11__14_, s_r_11__13_, s_r_11__12_, s_r_11__11_, s_r_11__10_, s_r_11__9_, s_r_11__8_, s_r_11__7_, s_r_11__6_, s_r_11__5_, s_r_11__4_, s_r_11__3_, s_r_11__2_, s_r_11__1_, s_r_11__0_ }),
    .c_o(c_r[11]),
    .prod_accum_o({ prod_accum_11__12_, prod_accum_11__11_, prod_accum_11__10_, prod_accum_11__9_, prod_accum_11__8_, prod_accum_11__7_, prod_accum_11__6_, prod_accum_11__5_, prod_accum_11__4_, prod_accum_11__3_, prod_accum_11__2_, prod_accum_11__1_, prod_accum_11__0_ })
  );


  bsg_mul_array_row_16_12_0
  \genblk1_12_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[191:176]),
    .b_i(b_r[191:176]),
    .s_i({ s_r_11__15_, s_r_11__14_, s_r_11__13_, s_r_11__12_, s_r_11__11_, s_r_11__10_, s_r_11__9_, s_r_11__8_, s_r_11__7_, s_r_11__6_, s_r_11__5_, s_r_11__4_, s_r_11__3_, s_r_11__2_, s_r_11__1_, s_r_11__0_ }),
    .c_i(c_r[11]),
    .prod_accum_i({ prod_accum_11__12_, prod_accum_11__11_, prod_accum_11__10_, prod_accum_11__9_, prod_accum_11__8_, prod_accum_11__7_, prod_accum_11__6_, prod_accum_11__5_, prod_accum_11__4_, prod_accum_11__3_, prod_accum_11__2_, prod_accum_11__1_, prod_accum_11__0_ }),
    .a_o(a_r[207:192]),
    .b_o(b_r[207:192]),
    .s_o({ s_r_12__15_, s_r_12__14_, s_r_12__13_, s_r_12__12_, s_r_12__11_, s_r_12__10_, s_r_12__9_, s_r_12__8_, s_r_12__7_, s_r_12__6_, s_r_12__5_, s_r_12__4_, s_r_12__3_, s_r_12__2_, s_r_12__1_, s_r_12__0_ }),
    .c_o(c_r[12]),
    .prod_accum_o({ prod_accum_12__13_, prod_accum_12__12_, prod_accum_12__11_, prod_accum_12__10_, prod_accum_12__9_, prod_accum_12__8_, prod_accum_12__7_, prod_accum_12__6_, prod_accum_12__5_, prod_accum_12__4_, prod_accum_12__3_, prod_accum_12__2_, prod_accum_12__1_, prod_accum_12__0_ })
  );


  bsg_mul_array_row_16_13_0
  \genblk1_13_.genblk1.mid_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[207:192]),
    .b_i(b_r[207:192]),
    .s_i({ s_r_12__15_, s_r_12__14_, s_r_12__13_, s_r_12__12_, s_r_12__11_, s_r_12__10_, s_r_12__9_, s_r_12__8_, s_r_12__7_, s_r_12__6_, s_r_12__5_, s_r_12__4_, s_r_12__3_, s_r_12__2_, s_r_12__1_, s_r_12__0_ }),
    .c_i(c_r[12]),
    .prod_accum_i({ prod_accum_12__13_, prod_accum_12__12_, prod_accum_12__11_, prod_accum_12__10_, prod_accum_12__9_, prod_accum_12__8_, prod_accum_12__7_, prod_accum_12__6_, prod_accum_12__5_, prod_accum_12__4_, prod_accum_12__3_, prod_accum_12__2_, prod_accum_12__1_, prod_accum_12__0_ }),
    .a_o(a_r[223:208]),
    .b_o(b_r[223:208]),
    .s_o({ s_r_13__15_, s_r_13__14_, s_r_13__13_, s_r_13__12_, s_r_13__11_, s_r_13__10_, s_r_13__9_, s_r_13__8_, s_r_13__7_, s_r_13__6_, s_r_13__5_, s_r_13__4_, s_r_13__3_, s_r_13__2_, s_r_13__1_, s_r_13__0_ }),
    .c_o(c_r[13]),
    .prod_accum_o({ prod_accum_13__14_, prod_accum_13__13_, prod_accum_13__12_, prod_accum_13__11_, prod_accum_13__10_, prod_accum_13__9_, prod_accum_13__8_, prod_accum_13__7_, prod_accum_13__6_, prod_accum_13__5_, prod_accum_13__4_, prod_accum_13__3_, prod_accum_13__2_, prod_accum_13__1_, prod_accum_13__0_ })
  );


  bsg_mul_array_row_16_14_0
  \genblk1_14_.genblk1.last_row 
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .v_i(v_i),
    .a_i(a_r[223:208]),
    .b_i(b_r[223:208]),
    .s_i({ s_r_13__15_, s_r_13__14_, s_r_13__13_, s_r_13__12_, s_r_13__11_, s_r_13__10_, s_r_13__9_, s_r_13__8_, s_r_13__7_, s_r_13__6_, s_r_13__5_, s_r_13__4_, s_r_13__3_, s_r_13__2_, s_r_13__1_, s_r_13__0_ }),
    .c_i(c_r[13]),
    .prod_accum_i({ prod_accum_13__14_, prod_accum_13__13_, prod_accum_13__12_, prod_accum_13__11_, prod_accum_13__10_, prod_accum_13__9_, prod_accum_13__8_, prod_accum_13__7_, prod_accum_13__6_, prod_accum_13__5_, prod_accum_13__4_, prod_accum_13__3_, prod_accum_13__2_, prod_accum_13__1_, prod_accum_13__0_ }),
    .a_o({ sv2v_dc_1, sv2v_dc_2, sv2v_dc_3, sv2v_dc_4, sv2v_dc_5, sv2v_dc_6, sv2v_dc_7, sv2v_dc_8, sv2v_dc_9, sv2v_dc_10, sv2v_dc_11, sv2v_dc_12, sv2v_dc_13, sv2v_dc_14, sv2v_dc_15, sv2v_dc_16 }),
    .b_o({ sv2v_dc_17, sv2v_dc_18, sv2v_dc_19, sv2v_dc_20, sv2v_dc_21, sv2v_dc_22, sv2v_dc_23, sv2v_dc_24, sv2v_dc_25, sv2v_dc_26, sv2v_dc_27, sv2v_dc_28, sv2v_dc_29, sv2v_dc_30, sv2v_dc_31, sv2v_dc_32 }),
    .s_o(o[30:15]),
    .c_o(o[31]),
    .prod_accum_o({ prod_accum_14__15_, o[14:0] })
  );


endmodule

