module FooMod();
  typedef struct packed {
    int member;
  } foo_typedef_t;

  localparam foo_typedef_t FooParam = '{ member: 32'haa551234 };
endmodule

module dut(output o);
  typedef enum bit[1:0] { enum_const_0 = 0, enum_const_1 = 1 } enum_e;
  localparam int ArrayParam [2] = '{ 4, 8 };

  localparam enum_e IndexParam = enum_const_1;

  localparam int IAmConst = ArrayParam[IndexParam];

  typedef struct packed {
    logic [IAmConst-1:0]   things_breaking_member_a;
    logic [IAmConst:0]     things_breaking_member_b;
  } things_breaking_typedef_t;

  FooMod foo_instance();

  assign o = '0;
endmodule
