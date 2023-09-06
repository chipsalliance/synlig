module top(output int foo_size, output int bar_size, output int enum_size);
  typedef enum logic [2:0] {
      e_zero  = 0
    , e_one   = 1
    , e_two   = 2
    , e_three = 3
    , e_four  = 4
  } numbers_e;

  typedef struct packed {
    logic [31:0] f_member;
  } foo_t;

  typedef struct packed {
    numbers_e    b_member;
    logic [28:0] b_padding;
  }  bar_t;

  typedef union packed {
    foo_t member_foo;
    bar_t member_bar;
  } union_t;

  union_t u;

  assign foo_size = $bits(foo_t);
  assign bar_size = $bits(bar_t);
  assign enum_size = $bits(numbers_e);
endmodule
