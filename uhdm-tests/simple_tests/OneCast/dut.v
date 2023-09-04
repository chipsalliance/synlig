module dut (a, b);
  input a;
  output [31:0] b;
  reg [31:0] b;
  localparam ONE = 1;
  localparam TWO = 0;
  localparam THREE = 1;
  localparam FOUR = 0;
  // Test casting in param_assign
  localparam DUMMY = 32'(ONE);
  // Casting in normal assignments
  assign b =  (0 << 0)
            | (1 << 2)
            | (32'(a) << 3)
            | (1 << 4)
            | (32'(ONE) << 1)
            | (1 << 5);

endmodule
