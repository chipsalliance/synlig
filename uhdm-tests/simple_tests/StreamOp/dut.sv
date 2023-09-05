module dut(output logic [31:0] a, b, output logic [63:0] c, d);
  logic[31:0] x;
  logic[31:0] y;

  initial begin
     x = { 8'd23, 8'd42, 8'd127, 8'd255 };
     a = { << 8 {x} };
  end

  assign y = { 8'd255, 8'd127, 8'd42, 8'd23 };
  
  assign b = { << 8 {y} };
  assign c = { << 8 {x, y} };
  assign d = { >> 8 {x, y} };

endmodule
