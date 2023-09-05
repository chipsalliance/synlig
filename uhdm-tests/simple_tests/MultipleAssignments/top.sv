module top (
    input logic clk,
    input logic wire_i,
    output logic wire_o,
    output logic register_o
);

  localparam int SHIFT = 3;
  logic [SHIFT-1:0] register;

  always_ff @(posedge clk) begin
      for (int i = SHIFT-1; i >= 1; i = i - 1)begin
          register[i] = register[i-1];
      end
      register[0] = wire_i; // blocking
      register_o <= register[SHIFT-1]; // non-blocking
  end

  assign wire_o = wire_i; // continuous assignment

endmodule
