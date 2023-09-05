module test_module #(
  parameter type test_parameter = logic
) (
  input test_parameter state_i
);
endmodule

module top
(
);
  localparam int StateWidth = 9;
  typedef enum logic [StateWidth-1:0] {
    StActive = 9'b100100001
  } state_e;

  state_e state_d;

  test_module #(
    .test_parameter(state_e)
  ) inst1 (
    .state_i (state_d)
  );

endmodule : top
