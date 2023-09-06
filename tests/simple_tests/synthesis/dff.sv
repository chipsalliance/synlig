module top (
  input c,
  input d,
  output q
);

always @(posedge c)
  q <= d;

endmodule
