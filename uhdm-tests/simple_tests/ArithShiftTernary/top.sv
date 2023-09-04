module top(
  output int oL,
  output int oR
);
  assign oL = 256 <<< (1 ? 1 : 0);
  assign oR = 256 >>> (1 ? 1 : 0);
endmodule
