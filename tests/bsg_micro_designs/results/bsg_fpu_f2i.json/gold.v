

module top
(
  a_i,
  signed_i,
  z_o,
  invalid_o
);

  input [15:0] a_i;
  output [15:0] z_o;
  input signed_i;
  output invalid_o;

  bsg_fpu_f2i
  wrapper
  (
    .a_i(a_i),
    .z_o(z_o),
    .signed_i(signed_i),
    .invalid_o(invalid_o)
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



module bsg_fpu_f2i
(
  a_i,
  signed_i,
  z_o,
  invalid_o
);

  input [15:0] a_i;
  output [15:0] z_o;
  input signed_i;
  output invalid_o;
  wire [15:0] z_o,shifted,inverted,post_round;
  wire invalid_o,N0,N1,N2,N3,N4,zero,nan,infty,sign,N5,exp_too_big,N6,exp_too_small,N7,
  N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,N22,N23,N24,N25,N26,N27,
  N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,N41,N42,N43,N44,N45,N46,N47,
  N48,N49,N50,N51,N52,N53,N54,N55,N56;
  wire [4:0] exp,shamt;
  wire [9:0] mantissa;
  wire [15:4] preshift;

  bsg_fpu_preprocess_e_p5_m_p10
  preprocess
  (
    .a_i(a_i),
    .zero_o(zero),
    .nan_o(nan),
    .infty_o(infty),
    .sign_o(sign),
    .exp_o(exp),
    .man_o(mantissa)
  );

  assign N5 = exp > { 1'b1, 1'b1, 1'b1, 1'b0, 1'b1 };
  assign N6 = exp > { 1'b1, 1'b1, 1'b1, 1'b1, 1'b0 };
  assign exp_too_small = exp < { 1'b1, 1'b1, 1'b1, 1'b1 };
  assign shifted = { preshift, 1'b0, 1'b0, 1'b0, 1'b0 } >> shamt;
  assign { N11, N10, N9, N8, N7 } = { 1'b1, 1'b1, 1'b1, 1'b0, 1'b1 } - exp;
  assign { N16, N15, N14, N13, N12 } = { 1'b1, 1'b1, 1'b1, 1'b1, 1'b0 } - exp;
  assign post_round = inverted + sign;
  assign exp_too_big = (N0)? N5 : 
                       (N1)? N6 : 1'b0;
  assign N0 = signed_i;
  assign N1 = preshift[15];
  assign preshift[14:4] = (N0)? { 1'b1, mantissa } : 
                          (N1)? { mantissa, 1'b0 } : 1'b0;
  assign shamt = (N0)? { N11, N10, N9, N8, N7 } : 
                 (N1)? { N16, N15, N14, N13, N12 } : 1'b0;
  assign N25 = (N2)? signed_i : 
               (N3)? N56 : 1'b0;
  assign N2 = sign;
  assign N3 = N24;
  assign z_o = (N4)? { preshift[15:15], 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 } : 
               (N27)? { N25, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24 } : 
               (N30)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
               (N33)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
               (N36)? { sign, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24, N24 } : 
               (N39)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
               (N23)? post_round : 1'b0;
  assign N4 = nan;
  assign invalid_o = (N4)? 1'b1 : 
                     (N27)? 1'b1 : 
                     (N30)? 1'b1 : 
                     (N33)? 1'b0 : 
                     (N36)? 1'b1 : 
                     (N39)? 1'b0 : 
                     (N23)? 1'b0 : 1'b0;
  assign inverted[15] = N40 ^ shifted[15];
  assign N40 = signed_i & sign;
  assign inverted[14] = N41 ^ shifted[14];
  assign N41 = signed_i & sign;
  assign inverted[13] = N42 ^ shifted[13];
  assign N42 = signed_i & sign;
  assign inverted[12] = N43 ^ shifted[12];
  assign N43 = signed_i & sign;
  assign inverted[11] = N44 ^ shifted[11];
  assign N44 = signed_i & sign;
  assign inverted[10] = N45 ^ shifted[10];
  assign N45 = signed_i & sign;
  assign inverted[9] = N46 ^ shifted[9];
  assign N46 = signed_i & sign;
  assign inverted[8] = N47 ^ shifted[8];
  assign N47 = signed_i & sign;
  assign inverted[7] = N48 ^ shifted[7];
  assign N48 = signed_i & sign;
  assign inverted[6] = N49 ^ shifted[6];
  assign N49 = signed_i & sign;
  assign inverted[5] = N50 ^ shifted[5];
  assign N50 = signed_i & sign;
  assign inverted[4] = N51 ^ shifted[4];
  assign N51 = signed_i & sign;
  assign inverted[3] = N52 ^ shifted[3];
  assign N52 = signed_i & sign;
  assign inverted[2] = N53 ^ shifted[2];
  assign N53 = signed_i & sign;
  assign inverted[1] = N54 ^ shifted[1];
  assign N54 = signed_i & sign;
  assign inverted[0] = N55 ^ shifted[0];
  assign N55 = signed_i & sign;
  assign N17 = N56 & sign;
  assign N56 = ~signed_i;
  assign N18 = infty | nan;
  assign N19 = N17 | N18;
  assign N20 = zero | N19;
  assign N21 = exp_too_big | N20;
  assign N22 = exp_too_small | N21;
  assign N23 = ~N22;
  assign preshift[15] = N56;
  assign N24 = ~sign;
  assign N26 = ~nan;
  assign N27 = infty & N26;
  assign N28 = ~infty;
  assign N29 = N26 & N28;
  assign N30 = N17 & N29;
  assign N31 = ~N17;
  assign N32 = N29 & N31;
  assign N33 = zero & N32;
  assign N34 = ~zero;
  assign N35 = N32 & N34;
  assign N36 = exp_too_big & N35;
  assign N37 = ~exp_too_big;
  assign N38 = N35 & N37;
  assign N39 = exp_too_small & N38;

endmodule

