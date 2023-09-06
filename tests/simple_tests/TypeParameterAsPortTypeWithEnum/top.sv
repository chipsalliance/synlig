module test_module #(
  parameter type test_parameter = logic [8:0]
) (
  input test_parameter state_i
);
endmodule

module top();
  typedef enum logic [7:0] {
    FooVariant = 8'b10010101
  } enum_foo_e;
  enum_foo_e foo_inst;

  test_module #(
    .test_parameter(enum_foo_e)
  ) inst1 (
    .state_i(foo_inst)
  );

  typedef enum logic [8:0] {
    BarVariant = 9'b100100001
  } enum_bar_e;
  enum_bar_e bar_inst;

  test_module #(
    .test_parameter(enum_bar_e)
  ) inst2 (
    .state_i(bar_inst)
  );
endmodule
