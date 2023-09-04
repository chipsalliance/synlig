package pkg; // verilog_lint: waive package-filename

  parameter int J = 3;
  parameter int K = 2;

  typedef struct packed {
    logic a;
    logic b;
    logic c;
  } my_packed_struct_t;

  typedef union packed {
    my_packed_struct_t [K:0][J:0] my_array;
    my_packed_struct_t [K:0][J:0] my_array2;
  } my_packed_union_with_array_t;

  typedef struct packed {
    my_packed_struct_t [K:0] my_array;
  } my_packed_struct_with_array_t;

endpackage : pkg

module top;
import pkg::*;

my_packed_struct_with_array_t t;

assign t.my_array[0].a = 1'b1;
assign t.my_array[1].a = 1'b0;
assign t.my_array[2].a = 1'b1;
assign t.my_array[0].b = 1'b1;
assign t.my_array[1].c = 1'b0;

my_packed_union_with_array_t u;

assign u.my_array[0] = '{
  '{1'b1, 1'b1, 1'b1},
  '{1'b0, 1'b0, 1'b0},
  '{1'b1, 1'b0, 1'b1},
  '{1'b0, 1'b1, 1'b0}
  };
assign u.my_array[1] = '{
  '{1'b1, 1'b0, 1'b1},
  '{1'b0, 1'b1, 1'b0},
  '{1'b1, 1'b1, 1'b1},
  '{1'b0, 1'b0, 1'b0}
  };

always_comb begin
  assert(t.my_array[0].a == 1'b1);
  assert(t.my_array[1].a == 1'b0);
  assert(t.my_array[2].a == 1'b1);
  assert(t.my_array[0].b == 1'b1);
  assert(t.my_array[1].c == 1'b0);

  assert(u.my_array[0] == 12'b111000101010);
  assert(u.my_array[1] == 12'b101010111000);
end
endmodule : top
