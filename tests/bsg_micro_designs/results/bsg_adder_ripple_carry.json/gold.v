

module top
(
  a_i,
  b_i,
  s_o,
  c_o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] s_o;
  output c_o;

  bsg_adder_ripple_carry
  wrapper
  (
    .a_i(a_i),
    .b_i(b_i),
    .s_o(s_o),
    .c_o(c_o)
  );


endmodule



module bsg_adder_ripple_carry
(
  a_i,
  b_i,
  s_o,
  c_o
);

  input [15:0] a_i;
  input [15:0] b_i;
  output [15:0] s_o;
  output c_o;
  wire [15:0] s_o;
  wire c_o;
  assign { c_o, s_o } = a_i + b_i;

endmodule

