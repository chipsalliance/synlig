

module top
(
  v_i,
  fc_o,
  v_o,
  fc_i
);

  input [15:0] v_i;
  output [15:0] fc_o;
  output [15:0] v_o;
  input [15:0] fc_i;

  bsg_flow_convert
  wrapper
  (
    .v_i(v_i),
    .fc_o(fc_o),
    .v_o(v_o),
    .fc_i(fc_i)
  );


endmodule



module bsg_flow_convert
(
  v_i,
  fc_o,
  v_o,
  fc_i
);

  input [15:0] v_i;
  output [15:0] fc_o;
  output [15:0] v_o;
  input [15:0] fc_i;
  wire [15:0] fc_o,v_o;
  assign fc_o[15] = fc_i[15];
  assign fc_o[14] = fc_i[14];
  assign fc_o[13] = fc_i[13];
  assign fc_o[12] = fc_i[12];
  assign fc_o[11] = fc_i[11];
  assign fc_o[10] = fc_i[10];
  assign fc_o[9] = fc_i[9];
  assign fc_o[8] = fc_i[8];
  assign fc_o[7] = fc_i[7];
  assign fc_o[6] = fc_i[6];
  assign fc_o[5] = fc_i[5];
  assign fc_o[4] = fc_i[4];
  assign fc_o[3] = fc_i[3];
  assign fc_o[2] = fc_i[2];
  assign fc_o[1] = fc_i[1];
  assign fc_o[0] = fc_i[0];
  assign v_o[15] = v_i[15];
  assign v_o[14] = v_i[14];
  assign v_o[13] = v_i[13];
  assign v_o[12] = v_i[12];
  assign v_o[11] = v_i[11];
  assign v_o[10] = v_i[10];
  assign v_o[9] = v_i[9];
  assign v_o[8] = v_i[8];
  assign v_o[7] = v_i[7];
  assign v_o[6] = v_i[6];
  assign v_o[5] = v_i[5];
  assign v_o[4] = v_i[4];
  assign v_o[3] = v_i[3];
  assign v_o[2] = v_i[2];
  assign v_o[1] = v_i[1];
  assign v_o[0] = v_i[0];

endmodule

