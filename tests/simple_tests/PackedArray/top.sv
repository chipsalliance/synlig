package pkg;
  typedef struct packed {
    logic        x;
  } struct_a;

  typedef struct packed {
    struct_a [1:0] a;
  } struct_b;

endpackage

module top(input i, output o);
   pkg::struct_b b;
   assign b.a[1].x = i;
   assign o = b.a[1].x;
   
endmodule // top
