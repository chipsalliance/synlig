module dut(output int o);

  typedef struct packed {
    byte b0;
    byte b1;
    byte b2;
    byte b3;
  } foo_bytes_t;

  typedef union packed {
    foo_bytes_t bytes;
    int i;
  } foo_t;

  typedef struct packed {
    bit [4:0] padding_0;
    foo_t foo;
    bit [2:0] padding_1;
  } bar_t;

  bar_t bar;

  always_comb begin
    bar.foo.bytes.b0 = 8'h10;
    bar.foo.bytes.b1 = 8'h11;
    bar.foo.bytes.b2 = 8'h13;
    bar.foo.bytes.b3 = 8'h17;
  end

  assign o = bar.foo.i;

endmodule
