

module top
(
  data0_i,
  data1_i,
  sel_i,
  data_o
);

  input [15:0] data0_i;
  input [15:0] data1_i;
  input [0:0] sel_i;
  output [15:0] data_o;

  bsg_mux_segmented
  wrapper
  (
    .data0_i(data0_i),
    .data1_i(data1_i),
    .sel_i(sel_i),
    .data_o(data_o)
  );


endmodule



module bsg_mux_segmented
(
  data0_i,
  data1_i,
  sel_i,
  data_o
);

  input [15:0] data0_i;
  input [15:0] data1_i;
  input [0:0] sel_i;
  output [15:0] data_o;
  wire [15:0] data_o;
  wire N0,N1;
  assign data_o = (N0)? data1_i : 
                  (N1)? data0_i : 1'b0;
  assign N0 = sel_i[0];
  assign N1 = ~sel_i[0];

endmodule

