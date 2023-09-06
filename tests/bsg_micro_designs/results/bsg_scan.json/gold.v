

module top
(
  i,
  o
);

  input [15:0] i;
  output [15:0] o;

  bsg_scan
  wrapper
  (
    .i(i),
    .o(o)
  );


endmodule



module bsg_scan
(
  i,
  o
);

  input [15:0] i;
  output [15:0] o;
  wire [15:0] o;
  wire t_3__15_,t_3__14_,t_3__13_,t_3__12_,t_3__11_,t_3__10_,t_3__9_,t_3__8_,t_3__7_,
  t_3__6_,t_3__5_,t_3__4_,t_3__3_,t_3__2_,t_3__1_,t_3__0_,t_2__15_,t_2__14_,
  t_2__13_,t_2__12_,t_2__11_,t_2__10_,t_2__9_,t_2__8_,t_2__7_,t_2__6_,t_2__5_,t_2__4_,
  t_2__3_,t_2__2_,t_2__1_,t_2__0_,t_1__15_,t_1__14_,t_1__13_,t_1__12_,t_1__11_,
  t_1__10_,t_1__9_,t_1__8_,t_1__7_,t_1__6_,t_1__5_,t_1__4_,t_1__3_,t_1__2_,t_1__1_,
  t_1__0_;
  assign t_1__15_ = i[15] ^ 1'b0;
  assign t_1__14_ = i[14] ^ i[15];
  assign t_1__13_ = i[13] ^ i[14];
  assign t_1__12_ = i[12] ^ i[13];
  assign t_1__11_ = i[11] ^ i[12];
  assign t_1__10_ = i[10] ^ i[11];
  assign t_1__9_ = i[9] ^ i[10];
  assign t_1__8_ = i[8] ^ i[9];
  assign t_1__7_ = i[7] ^ i[8];
  assign t_1__6_ = i[6] ^ i[7];
  assign t_1__5_ = i[5] ^ i[6];
  assign t_1__4_ = i[4] ^ i[5];
  assign t_1__3_ = i[3] ^ i[4];
  assign t_1__2_ = i[2] ^ i[3];
  assign t_1__1_ = i[1] ^ i[2];
  assign t_1__0_ = i[0] ^ i[1];
  assign t_2__15_ = t_1__15_ ^ 1'b0;
  assign t_2__14_ = t_1__14_ ^ 1'b0;
  assign t_2__13_ = t_1__13_ ^ t_1__15_;
  assign t_2__12_ = t_1__12_ ^ t_1__14_;
  assign t_2__11_ = t_1__11_ ^ t_1__13_;
  assign t_2__10_ = t_1__10_ ^ t_1__12_;
  assign t_2__9_ = t_1__9_ ^ t_1__11_;
  assign t_2__8_ = t_1__8_ ^ t_1__10_;
  assign t_2__7_ = t_1__7_ ^ t_1__9_;
  assign t_2__6_ = t_1__6_ ^ t_1__8_;
  assign t_2__5_ = t_1__5_ ^ t_1__7_;
  assign t_2__4_ = t_1__4_ ^ t_1__6_;
  assign t_2__3_ = t_1__3_ ^ t_1__5_;
  assign t_2__2_ = t_1__2_ ^ t_1__4_;
  assign t_2__1_ = t_1__1_ ^ t_1__3_;
  assign t_2__0_ = t_1__0_ ^ t_1__2_;
  assign t_3__15_ = t_2__15_ ^ 1'b0;
  assign t_3__14_ = t_2__14_ ^ 1'b0;
  assign t_3__13_ = t_2__13_ ^ 1'b0;
  assign t_3__12_ = t_2__12_ ^ 1'b0;
  assign t_3__11_ = t_2__11_ ^ t_2__15_;
  assign t_3__10_ = t_2__10_ ^ t_2__14_;
  assign t_3__9_ = t_2__9_ ^ t_2__13_;
  assign t_3__8_ = t_2__8_ ^ t_2__12_;
  assign t_3__7_ = t_2__7_ ^ t_2__11_;
  assign t_3__6_ = t_2__6_ ^ t_2__10_;
  assign t_3__5_ = t_2__5_ ^ t_2__9_;
  assign t_3__4_ = t_2__4_ ^ t_2__8_;
  assign t_3__3_ = t_2__3_ ^ t_2__7_;
  assign t_3__2_ = t_2__2_ ^ t_2__6_;
  assign t_3__1_ = t_2__1_ ^ t_2__5_;
  assign t_3__0_ = t_2__0_ ^ t_2__4_;
  assign o[15] = t_3__15_ ^ 1'b0;
  assign o[14] = t_3__14_ ^ 1'b0;
  assign o[13] = t_3__13_ ^ 1'b0;
  assign o[12] = t_3__12_ ^ 1'b0;
  assign o[11] = t_3__11_ ^ 1'b0;
  assign o[10] = t_3__10_ ^ 1'b0;
  assign o[9] = t_3__9_ ^ 1'b0;
  assign o[8] = t_3__8_ ^ 1'b0;
  assign o[7] = t_3__7_ ^ t_3__15_;
  assign o[6] = t_3__6_ ^ t_3__14_;
  assign o[5] = t_3__5_ ^ t_3__13_;
  assign o[4] = t_3__4_ ^ t_3__12_;
  assign o[3] = t_3__3_ ^ t_3__11_;
  assign o[2] = t_3__2_ ^ t_3__10_;
  assign o[1] = t_3__1_ ^ t_3__9_;
  assign o[0] = t_3__0_ ^ t_3__8_;

endmodule

