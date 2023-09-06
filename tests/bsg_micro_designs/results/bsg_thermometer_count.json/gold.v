

module top
(
  i,
  o
);

  input [15:0] i;
  output [4:0] o;

  bsg_thermometer_count
  wrapper
  (
    .i(i),
    .o(o)
  );


endmodule



module bsg_encode_one_hot_width_p17
(
  i,
  addr_o,
  v_o
);

  input [16:0] i;
  output [4:0] addr_o;
  output v_o;
  wire [4:0] addr_o;
  wire v_o,v_4__0_,v_3__24_,v_3__16_,v_3__8_,v_3__0_,v_2__28_,v_2__24_,v_2__20_,
  v_2__16_,v_2__12_,v_2__8_,v_2__4_,v_2__0_,v_1__30_,v_1__28_,v_1__26_,v_1__24_,v_1__22_,
  v_1__20_,v_1__18_,v_1__16_,v_1__14_,v_1__12_,v_1__10_,v_1__8_,v_1__6_,v_1__4_,
  v_1__2_,v_1__0_,addr_4__18_,addr_4__17_,addr_4__16_,addr_4__2_,addr_4__1_,
  addr_4__0_,addr_3__25_,addr_3__24_,addr_3__17_,addr_3__16_,addr_3__9_,addr_3__8_,
  addr_3__1_,addr_3__0_,addr_2__28_,addr_2__24_,addr_2__20_,addr_2__16_,addr_2__12_,
  addr_2__8_,addr_2__4_,addr_2__0_;
  assign v_1__0_ = i[1] | i[0];
  assign v_1__2_ = i[3] | i[2];
  assign v_1__4_ = i[5] | i[4];
  assign v_1__6_ = i[7] | i[6];
  assign v_1__8_ = i[9] | i[8];
  assign v_1__10_ = i[11] | i[10];
  assign v_1__12_ = i[13] | i[12];
  assign v_1__14_ = i[15] | i[14];
  assign v_1__16_ = 1'b0 | i[16];
  assign v_1__18_ = 1'b0 | 1'b0;
  assign v_1__20_ = 1'b0 | 1'b0;
  assign v_1__22_ = 1'b0 | 1'b0;
  assign v_1__24_ = 1'b0 | 1'b0;
  assign v_1__26_ = 1'b0 | 1'b0;
  assign v_1__28_ = 1'b0 | 1'b0;
  assign v_1__30_ = 1'b0 | 1'b0;
  assign v_2__0_ = v_1__2_ | v_1__0_;
  assign addr_2__0_ = i[1] | i[3];
  assign v_2__4_ = v_1__6_ | v_1__4_;
  assign addr_2__4_ = i[5] | i[7];
  assign v_2__8_ = v_1__10_ | v_1__8_;
  assign addr_2__8_ = i[9] | i[11];
  assign v_2__12_ = v_1__14_ | v_1__12_;
  assign addr_2__12_ = i[13] | i[15];
  assign v_2__16_ = v_1__18_ | v_1__16_;
  assign addr_2__16_ = 1'b0 | 1'b0;
  assign v_2__20_ = v_1__22_ | v_1__20_;
  assign addr_2__20_ = 1'b0 | 1'b0;
  assign v_2__24_ = v_1__26_ | v_1__24_;
  assign addr_2__24_ = 1'b0 | 1'b0;
  assign v_2__28_ = v_1__30_ | v_1__28_;
  assign addr_2__28_ = 1'b0 | 1'b0;
  assign v_3__0_ = v_2__4_ | v_2__0_;
  assign addr_3__1_ = v_1__2_ | v_1__6_;
  assign addr_3__0_ = addr_2__0_ | addr_2__4_;
  assign v_3__8_ = v_2__12_ | v_2__8_;
  assign addr_3__9_ = v_1__10_ | v_1__14_;
  assign addr_3__8_ = addr_2__8_ | addr_2__12_;
  assign v_3__16_ = v_2__20_ | v_2__16_;
  assign addr_3__17_ = v_1__18_ | v_1__22_;
  assign addr_3__16_ = addr_2__16_ | addr_2__20_;
  assign v_3__24_ = v_2__28_ | v_2__24_;
  assign addr_3__25_ = v_1__26_ | v_1__30_;
  assign addr_3__24_ = addr_2__24_ | addr_2__28_;
  assign v_4__0_ = v_3__8_ | v_3__0_;
  assign addr_4__2_ = v_2__4_ | v_2__12_;
  assign addr_4__1_ = addr_3__1_ | addr_3__9_;
  assign addr_4__0_ = addr_3__0_ | addr_3__8_;
  assign addr_o[4] = v_3__24_ | v_3__16_;
  assign addr_4__18_ = v_2__20_ | v_2__28_;
  assign addr_4__17_ = addr_3__17_ | addr_3__25_;
  assign addr_4__16_ = addr_3__16_ | addr_3__24_;
  assign v_o = addr_o[4] | v_4__0_;
  assign addr_o[3] = v_3__8_ | v_3__24_;
  assign addr_o[2] = addr_4__2_ | addr_4__18_;
  assign addr_o[1] = addr_4__1_ | addr_4__17_;
  assign addr_o[0] = addr_4__0_ | addr_4__16_;

endmodule



module bsg_thermometer_count
(
  i,
  o
);

  input [15:0] i;
  output [4:0] o;
  wire [4:0] o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14;
  wire [15:0] \big.one_hot ;

  bsg_encode_one_hot_width_p17
  \big.encode_one_hot 
  (
    .i({ i[15:15], \big.one_hot  }),
    .addr_o(o)
  );

  assign \big.one_hot [15] = N0 & i[14];
  assign N0 = ~i[15];
  assign \big.one_hot [14] = N1 & i[13];
  assign N1 = ~i[14];
  assign \big.one_hot [13] = N2 & i[12];
  assign N2 = ~i[13];
  assign \big.one_hot [12] = N3 & i[11];
  assign N3 = ~i[12];
  assign \big.one_hot [11] = N4 & i[10];
  assign N4 = ~i[11];
  assign \big.one_hot [10] = N5 & i[9];
  assign N5 = ~i[10];
  assign \big.one_hot [9] = N6 & i[8];
  assign N6 = ~i[9];
  assign \big.one_hot [8] = N7 & i[7];
  assign N7 = ~i[8];
  assign \big.one_hot [7] = N8 & i[6];
  assign N8 = ~i[7];
  assign \big.one_hot [6] = N9 & i[5];
  assign N9 = ~i[6];
  assign \big.one_hot [5] = N10 & i[4];
  assign N10 = ~i[5];
  assign \big.one_hot [4] = N11 & i[3];
  assign N11 = ~i[4];
  assign \big.one_hot [3] = N12 & i[2];
  assign N12 = ~i[3];
  assign \big.one_hot [2] = N13 & i[1];
  assign N13 = ~i[2];
  assign \big.one_hot [1] = N14 & i[0];
  assign N14 = ~i[1];
  assign \big.one_hot [0] = ~i[0];

endmodule

