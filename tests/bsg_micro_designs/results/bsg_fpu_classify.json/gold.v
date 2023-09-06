

module top
(
  a_i,
  class_o
);

  input [15:0] a_i;
  output [15:0] class_o;

  bsg_fpu_classify
  wrapper
  (
    .a_i(a_i),
    .class_o(class_o)
  );


endmodule



module bsg_fpu_preprocess_e_p5_m_p10
(
  a_i,
  zero_o,
  nan_o,
  sig_nan_o,
  infty_o,
  exp_zero_o,
  man_zero_o,
  denormal_o,
  sign_o,
  exp_o,
  man_o
);

  input [15:0] a_i;
  output [4:0] exp_o;
  output [9:0] man_o;
  output zero_o;
  output nan_o;
  output sig_nan_o;
  output infty_o;
  output exp_zero_o;
  output man_zero_o;
  output denormal_o;
  output sign_o;
  wire [4:0] exp_o;
  wire [9:0] man_o;
  wire zero_o,nan_o,sig_nan_o,infty_o,exp_zero_o,man_zero_o,denormal_o,sign_o,a_i_15_,
  N0,N1,N2,N3,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N19;
  assign a_i_15_ = a_i[15];
  assign sign_o = a_i_15_;
  assign exp_o[4] = a_i[14];
  assign exp_o[3] = a_i[13];
  assign exp_o[2] = a_i[12];
  assign exp_o[1] = a_i[11];
  assign exp_o[0] = a_i[10];
  assign man_o[9] = a_i[9];
  assign man_o[8] = a_i[8];
  assign man_o[7] = a_i[7];
  assign man_o[6] = a_i[6];
  assign man_o[5] = a_i[5];
  assign man_o[4] = a_i[4];
  assign man_o[3] = a_i[3];
  assign man_o[2] = a_i[2];
  assign man_o[1] = a_i[1];
  assign man_o[0] = a_i[0];
  assign N0 = exp_o[3] | exp_o[4];
  assign N1 = exp_o[2] | N0;
  assign N2 = exp_o[1] | N1;
  assign N3 = exp_o[0] | N2;
  assign exp_zero_o = ~N3;
  assign N5 = exp_o[3] & exp_o[4];
  assign N6 = exp_o[2] & N5;
  assign N7 = exp_o[1] & N6;
  assign N8 = exp_o[0] & N7;
  assign N9 = man_o[8] | man_o[9];
  assign N10 = man_o[7] | N9;
  assign N11 = man_o[6] | N10;
  assign N12 = man_o[5] | N11;
  assign N13 = man_o[4] | N12;
  assign N14 = man_o[3] | N13;
  assign N15 = man_o[2] | N14;
  assign N16 = man_o[1] | N15;
  assign N17 = man_o[0] | N16;
  assign man_zero_o = ~N17;
  assign zero_o = exp_zero_o & man_zero_o;
  assign nan_o = N8 & N17;
  assign sig_nan_o = nan_o & N19;
  assign N19 = ~man_o[9];
  assign infty_o = N8 & man_zero_o;
  assign denormal_o = exp_zero_o & N17;

endmodule



module bsg_fpu_classify
(
  a_i,
  class_o
);

  input [15:0] a_i;
  output [15:0] class_o;
  wire [15:0] class_o;
  wire zero,nan,infty,denormal,sign,N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,sv2v_dc_1,
  sv2v_dc_2,sv2v_dc_3,sv2v_dc_4,sv2v_dc_5,sv2v_dc_6,sv2v_dc_7,sv2v_dc_8,sv2v_dc_9,
  sv2v_dc_10,sv2v_dc_11,sv2v_dc_12,sv2v_dc_13,sv2v_dc_14,sv2v_dc_15;
  assign class_o[10] = 1'b0;
  assign class_o[11] = 1'b0;
  assign class_o[12] = 1'b0;
  assign class_o[13] = 1'b0;
  assign class_o[14] = 1'b0;
  assign class_o[15] = 1'b0;

  bsg_fpu_preprocess_e_p5_m_p10
  prep
  (
    .a_i(a_i),
    .zero_o(zero),
    .nan_o(nan),
    .sig_nan_o(class_o[8]),
    .infty_o(infty),
    .denormal_o(denormal),
    .sign_o(sign),
    .exp_o({ sv2v_dc_1, sv2v_dc_2, sv2v_dc_3, sv2v_dc_4, sv2v_dc_5 }),
    .man_o({ sv2v_dc_6, sv2v_dc_7, sv2v_dc_8, sv2v_dc_9, sv2v_dc_10, sv2v_dc_11, sv2v_dc_12, sv2v_dc_13, sv2v_dc_14, sv2v_dc_15 })
  );

  assign class_o[0] = sign & infty;
  assign class_o[1] = N5 & N6;
  assign N5 = N3 & N4;
  assign N3 = N1 & N2;
  assign N1 = sign & N0;
  assign N0 = ~infty;
  assign N2 = ~denormal;
  assign N4 = ~nan;
  assign N6 = ~zero;
  assign class_o[2] = sign & denormal;
  assign class_o[3] = sign & zero;
  assign class_o[4] = N7 & zero;
  assign N7 = ~sign;
  assign class_o[5] = N7 & denormal;
  assign class_o[6] = N10 & N6;
  assign N10 = N9 & N4;
  assign N9 = N8 & N2;
  assign N8 = N7 & N0;
  assign class_o[7] = N7 & infty;
  assign class_o[9] = nan & N11;
  assign N11 = ~class_o[8];

endmodule

