

module top
(
  a_i,
  b_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [31:0] o;

  bsg_mul_synth
  wrapper
  (
    .a_i(a_i),
    .b_i(b_i),
    .o(o)
  );


endmodule



module bsg_mul_synth
(
  a_i,
  b_i,
  o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [31:0] o;
  wire [31:0] o;
  assign o = a_i * b_i;

endmodule

