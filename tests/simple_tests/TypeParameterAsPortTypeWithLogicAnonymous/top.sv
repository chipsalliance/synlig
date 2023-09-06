module test_module #(
  parameter type test_parameter = logic [3:0]
) (
  input test_parameter a_in,
  output a
);
  assign a = a_in[0];
endmodule

module top(output a, output b);
  logic [3:0] val = 5;
  test_module #(.test_parameter(logic[1:0])) inst1(.a_in(val), .a(a));
  test_module inst2(.a_in(val), .a(b));
endmodule
