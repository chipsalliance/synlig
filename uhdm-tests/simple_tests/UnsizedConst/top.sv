typedef struct packed {logic [3:0] a;} my_struct_packed_t;

module top (
    output wire [3:0] out1,
    output wire out2,
    output my_struct_packed_t out3,
    output wire out4
);
  assign out1   = '1;
  assign out2   = (out1 == 4'b1111);
  assign out3.a = '1;
  assign out4   = (out3 == '1);
endmodule : top
