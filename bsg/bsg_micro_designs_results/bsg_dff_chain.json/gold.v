

module top
(
  clk_i,
  data_i,
  data_o
);

  input [15:0] data_i;
  output [15:0] data_o;
  input clk_i;

  bsg_dff_chain
  wrapper
  (
    .data_i(data_i),
    .data_o(data_o),
    .clk_i(clk_i)
  );


endmodule



module bsg_dff_width_p16
(
  clk_i,
  data_i,
  data_o
);

  input [15:0] data_i;
  output [15:0] data_o;
  input clk_i;
  wire [15:0] data_o;
  reg data_o_15_sv2v_reg,data_o_14_sv2v_reg,data_o_13_sv2v_reg,data_o_12_sv2v_reg,
  data_o_11_sv2v_reg,data_o_10_sv2v_reg,data_o_9_sv2v_reg,data_o_8_sv2v_reg,
  data_o_7_sv2v_reg,data_o_6_sv2v_reg,data_o_5_sv2v_reg,data_o_4_sv2v_reg,data_o_3_sv2v_reg,
  data_o_2_sv2v_reg,data_o_1_sv2v_reg,data_o_0_sv2v_reg;
  assign data_o[15] = data_o_15_sv2v_reg;
  assign data_o[14] = data_o_14_sv2v_reg;
  assign data_o[13] = data_o_13_sv2v_reg;
  assign data_o[12] = data_o_12_sv2v_reg;
  assign data_o[11] = data_o_11_sv2v_reg;
  assign data_o[10] = data_o_10_sv2v_reg;
  assign data_o[9] = data_o_9_sv2v_reg;
  assign data_o[8] = data_o_8_sv2v_reg;
  assign data_o[7] = data_o_7_sv2v_reg;
  assign data_o[6] = data_o_6_sv2v_reg;
  assign data_o[5] = data_o_5_sv2v_reg;
  assign data_o[4] = data_o_4_sv2v_reg;
  assign data_o[3] = data_o_3_sv2v_reg;
  assign data_o[2] = data_o_2_sv2v_reg;
  assign data_o[1] = data_o_1_sv2v_reg;
  assign data_o[0] = data_o_0_sv2v_reg;

  always @(posedge clk_i) begin
    if(1'b1) begin
      data_o_15_sv2v_reg <= data_i[15];
      data_o_14_sv2v_reg <= data_i[14];
      data_o_13_sv2v_reg <= data_i[13];
      data_o_12_sv2v_reg <= data_i[12];
      data_o_11_sv2v_reg <= data_i[11];
      data_o_10_sv2v_reg <= data_i[10];
      data_o_9_sv2v_reg <= data_i[9];
      data_o_8_sv2v_reg <= data_i[8];
      data_o_7_sv2v_reg <= data_i[7];
      data_o_6_sv2v_reg <= data_i[6];
      data_o_5_sv2v_reg <= data_i[5];
      data_o_4_sv2v_reg <= data_i[4];
      data_o_3_sv2v_reg <= data_i[3];
      data_o_2_sv2v_reg <= data_i[2];
      data_o_1_sv2v_reg <= data_i[1];
      data_o_0_sv2v_reg <= data_i[0];
    end 
  end


endmodule



module bsg_dff_chain
(
  clk_i,
  data_i,
  data_o
);

  input [15:0] data_i;
  output [15:0] data_o;
  input clk_i;
  wire [15:0] data_o;
  wire \chained.data_delayed_15__15_ ,\chained.data_delayed_15__14_ ,
  \chained.data_delayed_15__13_ ,\chained.data_delayed_15__12_ ,\chained.data_delayed_15__11_ ,
  \chained.data_delayed_15__10_ ,\chained.data_delayed_15__9_ ,
  \chained.data_delayed_15__8_ ,\chained.data_delayed_15__7_ ,\chained.data_delayed_15__6_ ,
  \chained.data_delayed_15__5_ ,\chained.data_delayed_15__4_ ,\chained.data_delayed_15__3_ ,
  \chained.data_delayed_15__2_ ,\chained.data_delayed_15__1_ ,
  \chained.data_delayed_15__0_ ,\chained.data_delayed_14__15_ ,\chained.data_delayed_14__14_ ,
  \chained.data_delayed_14__13_ ,\chained.data_delayed_14__12_ ,
  \chained.data_delayed_14__11_ ,\chained.data_delayed_14__10_ ,\chained.data_delayed_14__9_ ,
  \chained.data_delayed_14__8_ ,\chained.data_delayed_14__7_ ,\chained.data_delayed_14__6_ ,
  \chained.data_delayed_14__5_ ,\chained.data_delayed_14__4_ ,
  \chained.data_delayed_14__3_ ,\chained.data_delayed_14__2_ ,\chained.data_delayed_14__1_ ,
  \chained.data_delayed_14__0_ ,\chained.data_delayed_13__15_ ,\chained.data_delayed_13__14_ ,
  \chained.data_delayed_13__13_ ,\chained.data_delayed_13__12_ ,
  \chained.data_delayed_13__11_ ,\chained.data_delayed_13__10_ ,\chained.data_delayed_13__9_ ,
  \chained.data_delayed_13__8_ ,\chained.data_delayed_13__7_ ,\chained.data_delayed_13__6_ ,
  \chained.data_delayed_13__5_ ,\chained.data_delayed_13__4_ ,
  \chained.data_delayed_13__3_ ,\chained.data_delayed_13__2_ ,\chained.data_delayed_13__1_ ,
  \chained.data_delayed_13__0_ ,\chained.data_delayed_12__15_ ,\chained.data_delayed_12__14_ ,
  \chained.data_delayed_12__13_ ,\chained.data_delayed_12__12_ ,
  \chained.data_delayed_12__11_ ,\chained.data_delayed_12__10_ ,\chained.data_delayed_12__9_ ,
  \chained.data_delayed_12__8_ ,\chained.data_delayed_12__7_ ,
  \chained.data_delayed_12__6_ ,\chained.data_delayed_12__5_ ,\chained.data_delayed_12__4_ ,
  \chained.data_delayed_12__3_ ,\chained.data_delayed_12__2_ ,\chained.data_delayed_12__1_ ,
  \chained.data_delayed_12__0_ ,\chained.data_delayed_11__15_ ,
  \chained.data_delayed_11__14_ ,\chained.data_delayed_11__13_ ,\chained.data_delayed_11__12_ ,
  \chained.data_delayed_11__11_ ,\chained.data_delayed_11__10_ ,\chained.data_delayed_11__9_ ,
  \chained.data_delayed_11__8_ ,\chained.data_delayed_11__7_ ,
  \chained.data_delayed_11__6_ ,\chained.data_delayed_11__5_ ,\chained.data_delayed_11__4_ ,
  \chained.data_delayed_11__3_ ,\chained.data_delayed_11__2_ ,\chained.data_delayed_11__1_ ,
  \chained.data_delayed_11__0_ ,\chained.data_delayed_10__15_ ,
  \chained.data_delayed_10__14_ ,\chained.data_delayed_10__13_ ,\chained.data_delayed_10__12_ ,
  \chained.data_delayed_10__11_ ,\chained.data_delayed_10__10_ ,
  \chained.data_delayed_10__9_ ,\chained.data_delayed_10__8_ ,\chained.data_delayed_10__7_ ,
  \chained.data_delayed_10__6_ ,\chained.data_delayed_10__5_ ,\chained.data_delayed_10__4_ ,
  \chained.data_delayed_10__3_ ,\chained.data_delayed_10__2_ ,
  \chained.data_delayed_10__1_ ,\chained.data_delayed_10__0_ ,\chained.data_delayed_9__15_ ,
  \chained.data_delayed_9__14_ ,\chained.data_delayed_9__13_ ,\chained.data_delayed_9__12_ ,
  \chained.data_delayed_9__11_ ,\chained.data_delayed_9__10_ ,
  \chained.data_delayed_9__9_ ,\chained.data_delayed_9__8_ ,\chained.data_delayed_9__7_ ,
  \chained.data_delayed_9__6_ ,\chained.data_delayed_9__5_ ,\chained.data_delayed_9__4_ ,
  \chained.data_delayed_9__3_ ,\chained.data_delayed_9__2_ ,\chained.data_delayed_9__1_ ,
  \chained.data_delayed_9__0_ ,\chained.data_delayed_8__15_ ,
  \chained.data_delayed_8__14_ ,\chained.data_delayed_8__13_ ,\chained.data_delayed_8__12_ ,
  \chained.data_delayed_8__11_ ,\chained.data_delayed_8__10_ ,\chained.data_delayed_8__9_ ,
  \chained.data_delayed_8__8_ ,\chained.data_delayed_8__7_ ,
  \chained.data_delayed_8__6_ ,\chained.data_delayed_8__5_ ,\chained.data_delayed_8__4_ ,
  \chained.data_delayed_8__3_ ,\chained.data_delayed_8__2_ ,\chained.data_delayed_8__1_ ,
  \chained.data_delayed_8__0_ ,\chained.data_delayed_7__15_ ,\chained.data_delayed_7__14_ ,
  \chained.data_delayed_7__13_ ,\chained.data_delayed_7__12_ ,
  \chained.data_delayed_7__11_ ,\chained.data_delayed_7__10_ ,\chained.data_delayed_7__9_ ,
  \chained.data_delayed_7__8_ ,\chained.data_delayed_7__7_ ,\chained.data_delayed_7__6_ ,
  \chained.data_delayed_7__5_ ,\chained.data_delayed_7__4_ ,\chained.data_delayed_7__3_ ,
  \chained.data_delayed_7__2_ ,\chained.data_delayed_7__1_ ,
  \chained.data_delayed_7__0_ ,\chained.data_delayed_6__15_ ,\chained.data_delayed_6__14_ ,
  \chained.data_delayed_6__13_ ,\chained.data_delayed_6__12_ ,\chained.data_delayed_6__11_ ,
  \chained.data_delayed_6__10_ ,\chained.data_delayed_6__9_ ,
  \chained.data_delayed_6__8_ ,\chained.data_delayed_6__7_ ,\chained.data_delayed_6__6_ ,
  \chained.data_delayed_6__5_ ,\chained.data_delayed_6__4_ ,\chained.data_delayed_6__3_ ,
  \chained.data_delayed_6__2_ ,\chained.data_delayed_6__1_ ,\chained.data_delayed_6__0_ ,
  \chained.data_delayed_5__15_ ,\chained.data_delayed_5__14_ ,
  \chained.data_delayed_5__13_ ,\chained.data_delayed_5__12_ ,\chained.data_delayed_5__11_ ,
  \chained.data_delayed_5__10_ ,\chained.data_delayed_5__9_ ,\chained.data_delayed_5__8_ ,
  \chained.data_delayed_5__7_ ,\chained.data_delayed_5__6_ ,
  \chained.data_delayed_5__5_ ,\chained.data_delayed_5__4_ ,\chained.data_delayed_5__3_ ,
  \chained.data_delayed_5__2_ ,\chained.data_delayed_5__1_ ,\chained.data_delayed_5__0_ ,
  \chained.data_delayed_4__15_ ,\chained.data_delayed_4__14_ ,\chained.data_delayed_4__13_ ,
  \chained.data_delayed_4__12_ ,\chained.data_delayed_4__11_ ,
  \chained.data_delayed_4__10_ ,\chained.data_delayed_4__9_ ,\chained.data_delayed_4__8_ ,
  \chained.data_delayed_4__7_ ,\chained.data_delayed_4__6_ ,\chained.data_delayed_4__5_ ,
  \chained.data_delayed_4__4_ ,\chained.data_delayed_4__3_ ,\chained.data_delayed_4__2_ ,
  \chained.data_delayed_4__1_ ,\chained.data_delayed_4__0_ ,
  \chained.data_delayed_3__15_ ,\chained.data_delayed_3__14_ ,\chained.data_delayed_3__13_ ,
  \chained.data_delayed_3__12_ ,\chained.data_delayed_3__11_ ,\chained.data_delayed_3__10_ ,
  \chained.data_delayed_3__9_ ,\chained.data_delayed_3__8_ ,
  \chained.data_delayed_3__7_ ,\chained.data_delayed_3__6_ ,\chained.data_delayed_3__5_ ,
  \chained.data_delayed_3__4_ ,\chained.data_delayed_3__3_ ,\chained.data_delayed_3__2_ ,
  \chained.data_delayed_3__1_ ,\chained.data_delayed_3__0_ ,\chained.data_delayed_2__15_ ,
  \chained.data_delayed_2__14_ ,\chained.data_delayed_2__13_ ,
  \chained.data_delayed_2__12_ ,\chained.data_delayed_2__11_ ,\chained.data_delayed_2__10_ ,
  \chained.data_delayed_2__9_ ,\chained.data_delayed_2__8_ ,\chained.data_delayed_2__7_ ,
  \chained.data_delayed_2__6_ ,\chained.data_delayed_2__5_ ,\chained.data_delayed_2__4_ ,
  \chained.data_delayed_2__3_ ,\chained.data_delayed_2__2_ ,
  \chained.data_delayed_2__1_ ,\chained.data_delayed_2__0_ ,\chained.data_delayed_1__15_ ,
  \chained.data_delayed_1__14_ ,\chained.data_delayed_1__13_ ,\chained.data_delayed_1__12_ ,
  \chained.data_delayed_1__11_ ,\chained.data_delayed_1__10_ ,
  \chained.data_delayed_1__9_ ,\chained.data_delayed_1__8_ ,\chained.data_delayed_1__7_ ,
  \chained.data_delayed_1__6_ ,\chained.data_delayed_1__5_ ,\chained.data_delayed_1__4_ ,
  \chained.data_delayed_1__3_ ,\chained.data_delayed_1__2_ ,\chained.data_delayed_1__1_ ,
  \chained.data_delayed_1__0_ ;

  bsg_dff_width_p16
  \chained.genblk1_1_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i(data_i),
    .data_o({ \chained.data_delayed_1__15_ , \chained.data_delayed_1__14_ , \chained.data_delayed_1__13_ , \chained.data_delayed_1__12_ , \chained.data_delayed_1__11_ , \chained.data_delayed_1__10_ , \chained.data_delayed_1__9_ , \chained.data_delayed_1__8_ , \chained.data_delayed_1__7_ , \chained.data_delayed_1__6_ , \chained.data_delayed_1__5_ , \chained.data_delayed_1__4_ , \chained.data_delayed_1__3_ , \chained.data_delayed_1__2_ , \chained.data_delayed_1__1_ , \chained.data_delayed_1__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_2_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_1__15_ , \chained.data_delayed_1__14_ , \chained.data_delayed_1__13_ , \chained.data_delayed_1__12_ , \chained.data_delayed_1__11_ , \chained.data_delayed_1__10_ , \chained.data_delayed_1__9_ , \chained.data_delayed_1__8_ , \chained.data_delayed_1__7_ , \chained.data_delayed_1__6_ , \chained.data_delayed_1__5_ , \chained.data_delayed_1__4_ , \chained.data_delayed_1__3_ , \chained.data_delayed_1__2_ , \chained.data_delayed_1__1_ , \chained.data_delayed_1__0_  }),
    .data_o({ \chained.data_delayed_2__15_ , \chained.data_delayed_2__14_ , \chained.data_delayed_2__13_ , \chained.data_delayed_2__12_ , \chained.data_delayed_2__11_ , \chained.data_delayed_2__10_ , \chained.data_delayed_2__9_ , \chained.data_delayed_2__8_ , \chained.data_delayed_2__7_ , \chained.data_delayed_2__6_ , \chained.data_delayed_2__5_ , \chained.data_delayed_2__4_ , \chained.data_delayed_2__3_ , \chained.data_delayed_2__2_ , \chained.data_delayed_2__1_ , \chained.data_delayed_2__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_3_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_2__15_ , \chained.data_delayed_2__14_ , \chained.data_delayed_2__13_ , \chained.data_delayed_2__12_ , \chained.data_delayed_2__11_ , \chained.data_delayed_2__10_ , \chained.data_delayed_2__9_ , \chained.data_delayed_2__8_ , \chained.data_delayed_2__7_ , \chained.data_delayed_2__6_ , \chained.data_delayed_2__5_ , \chained.data_delayed_2__4_ , \chained.data_delayed_2__3_ , \chained.data_delayed_2__2_ , \chained.data_delayed_2__1_ , \chained.data_delayed_2__0_  }),
    .data_o({ \chained.data_delayed_3__15_ , \chained.data_delayed_3__14_ , \chained.data_delayed_3__13_ , \chained.data_delayed_3__12_ , \chained.data_delayed_3__11_ , \chained.data_delayed_3__10_ , \chained.data_delayed_3__9_ , \chained.data_delayed_3__8_ , \chained.data_delayed_3__7_ , \chained.data_delayed_3__6_ , \chained.data_delayed_3__5_ , \chained.data_delayed_3__4_ , \chained.data_delayed_3__3_ , \chained.data_delayed_3__2_ , \chained.data_delayed_3__1_ , \chained.data_delayed_3__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_4_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_3__15_ , \chained.data_delayed_3__14_ , \chained.data_delayed_3__13_ , \chained.data_delayed_3__12_ , \chained.data_delayed_3__11_ , \chained.data_delayed_3__10_ , \chained.data_delayed_3__9_ , \chained.data_delayed_3__8_ , \chained.data_delayed_3__7_ , \chained.data_delayed_3__6_ , \chained.data_delayed_3__5_ , \chained.data_delayed_3__4_ , \chained.data_delayed_3__3_ , \chained.data_delayed_3__2_ , \chained.data_delayed_3__1_ , \chained.data_delayed_3__0_  }),
    .data_o({ \chained.data_delayed_4__15_ , \chained.data_delayed_4__14_ , \chained.data_delayed_4__13_ , \chained.data_delayed_4__12_ , \chained.data_delayed_4__11_ , \chained.data_delayed_4__10_ , \chained.data_delayed_4__9_ , \chained.data_delayed_4__8_ , \chained.data_delayed_4__7_ , \chained.data_delayed_4__6_ , \chained.data_delayed_4__5_ , \chained.data_delayed_4__4_ , \chained.data_delayed_4__3_ , \chained.data_delayed_4__2_ , \chained.data_delayed_4__1_ , \chained.data_delayed_4__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_5_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_4__15_ , \chained.data_delayed_4__14_ , \chained.data_delayed_4__13_ , \chained.data_delayed_4__12_ , \chained.data_delayed_4__11_ , \chained.data_delayed_4__10_ , \chained.data_delayed_4__9_ , \chained.data_delayed_4__8_ , \chained.data_delayed_4__7_ , \chained.data_delayed_4__6_ , \chained.data_delayed_4__5_ , \chained.data_delayed_4__4_ , \chained.data_delayed_4__3_ , \chained.data_delayed_4__2_ , \chained.data_delayed_4__1_ , \chained.data_delayed_4__0_  }),
    .data_o({ \chained.data_delayed_5__15_ , \chained.data_delayed_5__14_ , \chained.data_delayed_5__13_ , \chained.data_delayed_5__12_ , \chained.data_delayed_5__11_ , \chained.data_delayed_5__10_ , \chained.data_delayed_5__9_ , \chained.data_delayed_5__8_ , \chained.data_delayed_5__7_ , \chained.data_delayed_5__6_ , \chained.data_delayed_5__5_ , \chained.data_delayed_5__4_ , \chained.data_delayed_5__3_ , \chained.data_delayed_5__2_ , \chained.data_delayed_5__1_ , \chained.data_delayed_5__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_6_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_5__15_ , \chained.data_delayed_5__14_ , \chained.data_delayed_5__13_ , \chained.data_delayed_5__12_ , \chained.data_delayed_5__11_ , \chained.data_delayed_5__10_ , \chained.data_delayed_5__9_ , \chained.data_delayed_5__8_ , \chained.data_delayed_5__7_ , \chained.data_delayed_5__6_ , \chained.data_delayed_5__5_ , \chained.data_delayed_5__4_ , \chained.data_delayed_5__3_ , \chained.data_delayed_5__2_ , \chained.data_delayed_5__1_ , \chained.data_delayed_5__0_  }),
    .data_o({ \chained.data_delayed_6__15_ , \chained.data_delayed_6__14_ , \chained.data_delayed_6__13_ , \chained.data_delayed_6__12_ , \chained.data_delayed_6__11_ , \chained.data_delayed_6__10_ , \chained.data_delayed_6__9_ , \chained.data_delayed_6__8_ , \chained.data_delayed_6__7_ , \chained.data_delayed_6__6_ , \chained.data_delayed_6__5_ , \chained.data_delayed_6__4_ , \chained.data_delayed_6__3_ , \chained.data_delayed_6__2_ , \chained.data_delayed_6__1_ , \chained.data_delayed_6__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_7_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_6__15_ , \chained.data_delayed_6__14_ , \chained.data_delayed_6__13_ , \chained.data_delayed_6__12_ , \chained.data_delayed_6__11_ , \chained.data_delayed_6__10_ , \chained.data_delayed_6__9_ , \chained.data_delayed_6__8_ , \chained.data_delayed_6__7_ , \chained.data_delayed_6__6_ , \chained.data_delayed_6__5_ , \chained.data_delayed_6__4_ , \chained.data_delayed_6__3_ , \chained.data_delayed_6__2_ , \chained.data_delayed_6__1_ , \chained.data_delayed_6__0_  }),
    .data_o({ \chained.data_delayed_7__15_ , \chained.data_delayed_7__14_ , \chained.data_delayed_7__13_ , \chained.data_delayed_7__12_ , \chained.data_delayed_7__11_ , \chained.data_delayed_7__10_ , \chained.data_delayed_7__9_ , \chained.data_delayed_7__8_ , \chained.data_delayed_7__7_ , \chained.data_delayed_7__6_ , \chained.data_delayed_7__5_ , \chained.data_delayed_7__4_ , \chained.data_delayed_7__3_ , \chained.data_delayed_7__2_ , \chained.data_delayed_7__1_ , \chained.data_delayed_7__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_8_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_7__15_ , \chained.data_delayed_7__14_ , \chained.data_delayed_7__13_ , \chained.data_delayed_7__12_ , \chained.data_delayed_7__11_ , \chained.data_delayed_7__10_ , \chained.data_delayed_7__9_ , \chained.data_delayed_7__8_ , \chained.data_delayed_7__7_ , \chained.data_delayed_7__6_ , \chained.data_delayed_7__5_ , \chained.data_delayed_7__4_ , \chained.data_delayed_7__3_ , \chained.data_delayed_7__2_ , \chained.data_delayed_7__1_ , \chained.data_delayed_7__0_  }),
    .data_o({ \chained.data_delayed_8__15_ , \chained.data_delayed_8__14_ , \chained.data_delayed_8__13_ , \chained.data_delayed_8__12_ , \chained.data_delayed_8__11_ , \chained.data_delayed_8__10_ , \chained.data_delayed_8__9_ , \chained.data_delayed_8__8_ , \chained.data_delayed_8__7_ , \chained.data_delayed_8__6_ , \chained.data_delayed_8__5_ , \chained.data_delayed_8__4_ , \chained.data_delayed_8__3_ , \chained.data_delayed_8__2_ , \chained.data_delayed_8__1_ , \chained.data_delayed_8__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_9_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_8__15_ , \chained.data_delayed_8__14_ , \chained.data_delayed_8__13_ , \chained.data_delayed_8__12_ , \chained.data_delayed_8__11_ , \chained.data_delayed_8__10_ , \chained.data_delayed_8__9_ , \chained.data_delayed_8__8_ , \chained.data_delayed_8__7_ , \chained.data_delayed_8__6_ , \chained.data_delayed_8__5_ , \chained.data_delayed_8__4_ , \chained.data_delayed_8__3_ , \chained.data_delayed_8__2_ , \chained.data_delayed_8__1_ , \chained.data_delayed_8__0_  }),
    .data_o({ \chained.data_delayed_9__15_ , \chained.data_delayed_9__14_ , \chained.data_delayed_9__13_ , \chained.data_delayed_9__12_ , \chained.data_delayed_9__11_ , \chained.data_delayed_9__10_ , \chained.data_delayed_9__9_ , \chained.data_delayed_9__8_ , \chained.data_delayed_9__7_ , \chained.data_delayed_9__6_ , \chained.data_delayed_9__5_ , \chained.data_delayed_9__4_ , \chained.data_delayed_9__3_ , \chained.data_delayed_9__2_ , \chained.data_delayed_9__1_ , \chained.data_delayed_9__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_10_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_9__15_ , \chained.data_delayed_9__14_ , \chained.data_delayed_9__13_ , \chained.data_delayed_9__12_ , \chained.data_delayed_9__11_ , \chained.data_delayed_9__10_ , \chained.data_delayed_9__9_ , \chained.data_delayed_9__8_ , \chained.data_delayed_9__7_ , \chained.data_delayed_9__6_ , \chained.data_delayed_9__5_ , \chained.data_delayed_9__4_ , \chained.data_delayed_9__3_ , \chained.data_delayed_9__2_ , \chained.data_delayed_9__1_ , \chained.data_delayed_9__0_  }),
    .data_o({ \chained.data_delayed_10__15_ , \chained.data_delayed_10__14_ , \chained.data_delayed_10__13_ , \chained.data_delayed_10__12_ , \chained.data_delayed_10__11_ , \chained.data_delayed_10__10_ , \chained.data_delayed_10__9_ , \chained.data_delayed_10__8_ , \chained.data_delayed_10__7_ , \chained.data_delayed_10__6_ , \chained.data_delayed_10__5_ , \chained.data_delayed_10__4_ , \chained.data_delayed_10__3_ , \chained.data_delayed_10__2_ , \chained.data_delayed_10__1_ , \chained.data_delayed_10__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_11_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_10__15_ , \chained.data_delayed_10__14_ , \chained.data_delayed_10__13_ , \chained.data_delayed_10__12_ , \chained.data_delayed_10__11_ , \chained.data_delayed_10__10_ , \chained.data_delayed_10__9_ , \chained.data_delayed_10__8_ , \chained.data_delayed_10__7_ , \chained.data_delayed_10__6_ , \chained.data_delayed_10__5_ , \chained.data_delayed_10__4_ , \chained.data_delayed_10__3_ , \chained.data_delayed_10__2_ , \chained.data_delayed_10__1_ , \chained.data_delayed_10__0_  }),
    .data_o({ \chained.data_delayed_11__15_ , \chained.data_delayed_11__14_ , \chained.data_delayed_11__13_ , \chained.data_delayed_11__12_ , \chained.data_delayed_11__11_ , \chained.data_delayed_11__10_ , \chained.data_delayed_11__9_ , \chained.data_delayed_11__8_ , \chained.data_delayed_11__7_ , \chained.data_delayed_11__6_ , \chained.data_delayed_11__5_ , \chained.data_delayed_11__4_ , \chained.data_delayed_11__3_ , \chained.data_delayed_11__2_ , \chained.data_delayed_11__1_ , \chained.data_delayed_11__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_12_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_11__15_ , \chained.data_delayed_11__14_ , \chained.data_delayed_11__13_ , \chained.data_delayed_11__12_ , \chained.data_delayed_11__11_ , \chained.data_delayed_11__10_ , \chained.data_delayed_11__9_ , \chained.data_delayed_11__8_ , \chained.data_delayed_11__7_ , \chained.data_delayed_11__6_ , \chained.data_delayed_11__5_ , \chained.data_delayed_11__4_ , \chained.data_delayed_11__3_ , \chained.data_delayed_11__2_ , \chained.data_delayed_11__1_ , \chained.data_delayed_11__0_  }),
    .data_o({ \chained.data_delayed_12__15_ , \chained.data_delayed_12__14_ , \chained.data_delayed_12__13_ , \chained.data_delayed_12__12_ , \chained.data_delayed_12__11_ , \chained.data_delayed_12__10_ , \chained.data_delayed_12__9_ , \chained.data_delayed_12__8_ , \chained.data_delayed_12__7_ , \chained.data_delayed_12__6_ , \chained.data_delayed_12__5_ , \chained.data_delayed_12__4_ , \chained.data_delayed_12__3_ , \chained.data_delayed_12__2_ , \chained.data_delayed_12__1_ , \chained.data_delayed_12__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_13_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_12__15_ , \chained.data_delayed_12__14_ , \chained.data_delayed_12__13_ , \chained.data_delayed_12__12_ , \chained.data_delayed_12__11_ , \chained.data_delayed_12__10_ , \chained.data_delayed_12__9_ , \chained.data_delayed_12__8_ , \chained.data_delayed_12__7_ , \chained.data_delayed_12__6_ , \chained.data_delayed_12__5_ , \chained.data_delayed_12__4_ , \chained.data_delayed_12__3_ , \chained.data_delayed_12__2_ , \chained.data_delayed_12__1_ , \chained.data_delayed_12__0_  }),
    .data_o({ \chained.data_delayed_13__15_ , \chained.data_delayed_13__14_ , \chained.data_delayed_13__13_ , \chained.data_delayed_13__12_ , \chained.data_delayed_13__11_ , \chained.data_delayed_13__10_ , \chained.data_delayed_13__9_ , \chained.data_delayed_13__8_ , \chained.data_delayed_13__7_ , \chained.data_delayed_13__6_ , \chained.data_delayed_13__5_ , \chained.data_delayed_13__4_ , \chained.data_delayed_13__3_ , \chained.data_delayed_13__2_ , \chained.data_delayed_13__1_ , \chained.data_delayed_13__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_14_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_13__15_ , \chained.data_delayed_13__14_ , \chained.data_delayed_13__13_ , \chained.data_delayed_13__12_ , \chained.data_delayed_13__11_ , \chained.data_delayed_13__10_ , \chained.data_delayed_13__9_ , \chained.data_delayed_13__8_ , \chained.data_delayed_13__7_ , \chained.data_delayed_13__6_ , \chained.data_delayed_13__5_ , \chained.data_delayed_13__4_ , \chained.data_delayed_13__3_ , \chained.data_delayed_13__2_ , \chained.data_delayed_13__1_ , \chained.data_delayed_13__0_  }),
    .data_o({ \chained.data_delayed_14__15_ , \chained.data_delayed_14__14_ , \chained.data_delayed_14__13_ , \chained.data_delayed_14__12_ , \chained.data_delayed_14__11_ , \chained.data_delayed_14__10_ , \chained.data_delayed_14__9_ , \chained.data_delayed_14__8_ , \chained.data_delayed_14__7_ , \chained.data_delayed_14__6_ , \chained.data_delayed_14__5_ , \chained.data_delayed_14__4_ , \chained.data_delayed_14__3_ , \chained.data_delayed_14__2_ , \chained.data_delayed_14__1_ , \chained.data_delayed_14__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_15_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_14__15_ , \chained.data_delayed_14__14_ , \chained.data_delayed_14__13_ , \chained.data_delayed_14__12_ , \chained.data_delayed_14__11_ , \chained.data_delayed_14__10_ , \chained.data_delayed_14__9_ , \chained.data_delayed_14__8_ , \chained.data_delayed_14__7_ , \chained.data_delayed_14__6_ , \chained.data_delayed_14__5_ , \chained.data_delayed_14__4_ , \chained.data_delayed_14__3_ , \chained.data_delayed_14__2_ , \chained.data_delayed_14__1_ , \chained.data_delayed_14__0_  }),
    .data_o({ \chained.data_delayed_15__15_ , \chained.data_delayed_15__14_ , \chained.data_delayed_15__13_ , \chained.data_delayed_15__12_ , \chained.data_delayed_15__11_ , \chained.data_delayed_15__10_ , \chained.data_delayed_15__9_ , \chained.data_delayed_15__8_ , \chained.data_delayed_15__7_ , \chained.data_delayed_15__6_ , \chained.data_delayed_15__5_ , \chained.data_delayed_15__4_ , \chained.data_delayed_15__3_ , \chained.data_delayed_15__2_ , \chained.data_delayed_15__1_ , \chained.data_delayed_15__0_  })
  );


  bsg_dff_width_p16
  \chained.genblk1_16_.ch_reg 
  (
    .clk_i(clk_i),
    .data_i({ \chained.data_delayed_15__15_ , \chained.data_delayed_15__14_ , \chained.data_delayed_15__13_ , \chained.data_delayed_15__12_ , \chained.data_delayed_15__11_ , \chained.data_delayed_15__10_ , \chained.data_delayed_15__9_ , \chained.data_delayed_15__8_ , \chained.data_delayed_15__7_ , \chained.data_delayed_15__6_ , \chained.data_delayed_15__5_ , \chained.data_delayed_15__4_ , \chained.data_delayed_15__3_ , \chained.data_delayed_15__2_ , \chained.data_delayed_15__1_ , \chained.data_delayed_15__0_  }),
    .data_o(data_o)
  );


endmodule

