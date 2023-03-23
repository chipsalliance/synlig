

module top
(
  way_id_i,
  data_o,
  mask_o
);

  input [3:0] way_id_i;
  output [14:0] data_o;
  output [14:0] mask_o;

  bsg_lru_pseudo_tree_decode
  wrapper
  (
    .way_id_i(way_id_i),
    .data_o(data_o),
    .mask_o(mask_o)
  );


endmodule



module bsg_lru_pseudo_tree_decode
(
  way_id_i,
  data_o,
  mask_o
);

  input [3:0] way_id_i;
  output [14:0] data_o;
  output [14:0] mask_o;
  wire [14:0] data_o,mask_o;
  wire N0,N1,N2,N3;
  assign mask_o[0] = 1'b1;
  assign data_o[0] = 1'b1 & N0;
  assign N0 = ~way_id_i[3];
  assign mask_o[1] = 1'b1 & N0;
  assign data_o[1] = mask_o[1] & N1;
  assign N1 = ~way_id_i[2];
  assign mask_o[2] = 1'b1 & way_id_i[3];
  assign data_o[2] = mask_o[2] & N1;
  assign mask_o[3] = mask_o[1] & N1;
  assign data_o[3] = mask_o[3] & N2;
  assign N2 = ~way_id_i[1];
  assign mask_o[4] = mask_o[1] & way_id_i[2];
  assign data_o[4] = mask_o[4] & N2;
  assign mask_o[5] = mask_o[2] & N1;
  assign data_o[5] = mask_o[5] & N2;
  assign mask_o[6] = mask_o[2] & way_id_i[2];
  assign data_o[6] = mask_o[6] & N2;
  assign mask_o[7] = mask_o[3] & N2;
  assign data_o[7] = mask_o[7] & N3;
  assign N3 = ~way_id_i[0];
  assign mask_o[8] = mask_o[3] & way_id_i[1];
  assign data_o[8] = mask_o[8] & N3;
  assign mask_o[9] = mask_o[4] & N2;
  assign data_o[9] = mask_o[9] & N3;
  assign mask_o[10] = mask_o[4] & way_id_i[1];
  assign data_o[10] = mask_o[10] & N3;
  assign mask_o[11] = mask_o[5] & N2;
  assign data_o[11] = mask_o[11] & N3;
  assign mask_o[12] = mask_o[5] & way_id_i[1];
  assign data_o[12] = mask_o[12] & N3;
  assign mask_o[13] = mask_o[6] & N2;
  assign data_o[13] = mask_o[13] & N3;
  assign mask_o[14] = mask_o[6] & way_id_i[1];
  assign data_o[14] = mask_o[14] & N3;

endmodule

