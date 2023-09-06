module dut #(
  int unsigned XLEN = 32
)(
  output logic [XLEN-1:0] a, b
);
  logic [XLEN-1:0] x;
  logic [XLEN-1:0] y;

  // reverse bit order
  function automatic logic [XLEN-1:0] bitrev (logic [XLEN-1:0] val);
    bitrev = {<<{val}};
  endfunction: bitrev

  initial begin
    x = XLEN'('h01234567);
    a = bitrev(x);
  end

  assign y = XLEN'('h89abcdef);
  assign b = bitrev(y);

endmodule: dut
