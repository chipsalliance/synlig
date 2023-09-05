module test_module #(
  parameter type test_parameter = logic [8:0]
) (
  input test_parameter state_i
);
endmodule

module top();
  typedef logic state_e;
  state_e state_d;

  test_module #(
    .test_parameter(state_e)
  ) inst1 (
    .state_i(state_d)
  );

  typedef logic [2:0] foo_type;
  foo_type foo_inst;

  test_module #(
    .test_parameter(foo_type)
  ) inst2 (
    .state_i(foo_inst)
  );

  test_module #(
    .test_parameter(foo_type)
  ) inst3 (
    .state_i(foo_inst)
  );
endmodule
