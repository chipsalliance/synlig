

module top
(
  vec_i,
  fwd_o,
  fwd_datapath_o,
  bk_o,
  bk_datapath_o
);

  input [3:0] vec_i;
  output [7:0] fwd_o;
  output [7:0] fwd_datapath_o;
  output [7:0] bk_o;
  output [7:0] bk_datapath_o;

  bsg_scatter_gather
  wrapper
  (
    .vec_i(vec_i),
    .fwd_o(fwd_o),
    .fwd_datapath_o(fwd_datapath_o),
    .bk_o(bk_o),
    .bk_datapath_o(bk_datapath_o)
  );


endmodule



module bsg_scatter_gather
(
  vec_i,
  fwd_o,
  fwd_datapath_o,
  bk_o,
  bk_datapath_o
);

  input [3:0] vec_i;
  output [7:0] fwd_o;
  output [7:0] fwd_datapath_o;
  output [7:0] bk_o;
  output [7:0] bk_datapath_o;
  wire [7:0] fwd_o,fwd_datapath_o,bk_o,bk_datapath_o;
  wire N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,
  N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,N41,
  N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53,N54,N55,N56,N57,N58,N59,N60,N61;
  assign bk_datapath_o[0] = 1'b0;
  assign bk_datapath_o[1] = 1'b0;
  assign bk_datapath_o[3] = 1'b0;
  assign fwd_datapath_o[5] = 1'b0;
  assign fwd_datapath_o[6] = 1'b0;
  assign fwd_datapath_o[7] = 1'b0;
  assign N20 = N16 & N17;
  assign N21 = N18 & N19;
  assign N22 = N20 & N21;
  assign N23 = vec_i[3] | vec_i[2];
  assign N24 = vec_i[1] | N19;
  assign N25 = N23 | N24;
  assign N27 = N18 | vec_i[0];
  assign N28 = N23 | N27;
  assign N30 = N18 | N19;
  assign N31 = N23 | N30;
  assign N33 = vec_i[3] | N17;
  assign N34 = vec_i[1] | vec_i[0];
  assign N35 = N33 | N34;
  assign N37 = N33 | N24;
  assign N39 = N33 | N27;
  assign N41 = N33 | N30;
  assign N43 = N16 | vec_i[2];
  assign N44 = N43 | N34;
  assign N46 = N43 | N24;
  assign N48 = N43 | N27;
  assign N50 = N43 | N30;
  assign N52 = N16 | N17;
  assign N53 = N52 | N34;
  assign N55 = N52 | N24;
  assign N57 = N52 | N27;
  assign N59 = vec_i[3] & vec_i[2];
  assign N60 = vec_i[1] & vec_i[0];
  assign N61 = N59 & N60;
  assign bk_o = (N0)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 } : 
                (N1)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                (N2)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1 } : 
                (N3)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                (N4)? { 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1 } : 
                (N5)? { 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                (N6)? { 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1 } : 
                (N7)? { 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                (N8)? { 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 } : 
                (N9)? { 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                (N10)? { 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1 } : 
                (N11)? { 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                (N12)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1 } : 
                (N13)? { 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                (N14)? { 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1 } : 
                (N15)? { 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 } : 1'b0;
  assign N0 = N22;
  assign N1 = N26;
  assign N2 = N29;
  assign N3 = N32;
  assign N4 = N36;
  assign N5 = N38;
  assign N6 = N40;
  assign N7 = N42;
  assign N8 = N45;
  assign N9 = N47;
  assign N10 = N49;
  assign N11 = N51;
  assign N12 = N54;
  assign N13 = N56;
  assign N14 = N58;
  assign N15 = N61;
  assign { bk_datapath_o[7:4], bk_datapath_o[2:2] } = (N0)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                      (N1)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                      (N2)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                      (N3)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 } : 
                                                      (N4)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                      (N5)? { 1'b0, 1'b0, 1'b0, 1'b1, 1'b0 } : 
                                                      (N6)? { 1'b0, 1'b0, 1'b0, 1'b1, 1'b0 } : 
                                                      (N7)? { 1'b0, 1'b0, 1'b1, 1'b0, 1'b1 } : 
                                                      (N8)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                                                      (N9)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                                                      (N10)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                                                      (N11)? { 1'b1, 1'b0, 1'b0, 1'b0, 1'b1 } : 
                                                      (N12)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                                                      (N13)? { 1'b1, 1'b0, 1'b0, 1'b1, 1'b0 } : 
                                                      (N14)? { 1'b1, 1'b0, 1'b0, 1'b1, 1'b0 } : 
                                                      (N15)? { 1'b1, 1'b1, 1'b1, 1'b0, 1'b1 } : 1'b0;
  assign fwd_o = (N0)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 } : 
                 (N1)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                 (N2)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1 } : 
                 (N3)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                 (N4)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0 } : 
                 (N5)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                 (N6)? { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1 } : 
                 (N7)? { 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                 (N8)? { 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1 } : 
                 (N9)? { 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0 } : 
                 (N10)? { 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1 } : 
                 (N11)? { 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                 (N12)? { 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0 } : 
                 (N13)? { 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                 (N14)? { 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1 } : 
                 (N15)? { 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 } : 1'b0;
  assign fwd_datapath_o[4:0] = (N0)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                               (N1)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                               (N2)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 } : 
                               (N3)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                               (N4)? { 1'b0, 1'b0, 1'b0, 1'b1, 1'b0 } : 
                               (N5)? { 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                               (N6)? { 1'b0, 1'b0, 1'b1, 1'b0, 1'b1 } : 
                               (N7)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                               (N8)? { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1 } : 
                               (N9)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 } : 
                               (N10)? { 1'b0, 1'b1, 1'b0, 1'b0, 1'b1 } : 
                               (N11)? { 1'b1, 1'b0, 1'b0, 1'b0, 1'b0 } : 
                               (N12)? { 1'b0, 1'b1, 1'b0, 1'b1, 1'b0 } : 
                               (N13)? { 1'b1, 1'b0, 1'b1, 1'b0, 1'b0 } : 
                               (N14)? { 1'b1, 1'b0, 1'b1, 1'b0, 1'b1 } : 
                               (N15)? { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 } : 1'b0;
  assign N16 = ~vec_i[3];
  assign N17 = ~vec_i[2];
  assign N18 = ~vec_i[1];
  assign N19 = ~vec_i[0];
  assign N26 = ~N25;
  assign N29 = ~N28;
  assign N32 = ~N31;
  assign N36 = ~N35;
  assign N38 = ~N37;
  assign N40 = ~N39;
  assign N42 = ~N41;
  assign N45 = ~N44;
  assign N47 = ~N46;
  assign N49 = ~N48;
  assign N51 = ~N50;
  assign N54 = ~N53;
  assign N56 = ~N55;
  assign N58 = ~N57;

endmodule

