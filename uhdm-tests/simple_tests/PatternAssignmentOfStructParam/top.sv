package top_pkg; // verilog_lint: waive package-filename

  typedef struct packed {
    logic a;
    logic b;
    logic c;
    logic d;
  } my_struct_t;

  parameter top_pkg::my_struct_t MyParameter = '{
    a: 1'b1,
    b: 1'b0,
    c: 1'b1,
    d: 1'b0
  };

endpackage : top_pkg

module top (
    output top_pkg::my_struct_t z,
    output top_pkg::my_struct_t zz
);

  top_pkg::my_struct_t test_struct;

  always_comb begin
    test_struct = '{
      a: 1'b0,
      b: 1'b1,
      c: 1'b0,
      d: 1'b1
    };
  end

  assign z = top_pkg::MyParameter;
  assign zz = test_struct;

endmodule : top
