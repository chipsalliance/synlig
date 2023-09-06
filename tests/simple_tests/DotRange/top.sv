typedef struct packed {logic [2:0] k;} foo_struct_t;
typedef struct packed {logic [2:0][6:0] l;} bar_struct_t;

module top (
    input  foo_struct_t foo,
    output bar_struct_t bar
);
  assign bar.l[2][1] = foo.k[2];
endmodule : top
