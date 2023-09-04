package pkg;
  typedef enum logic[7:0] {
    ONE,
    TWO,
    THREE
  } enum_t;

  typedef enum_t alias_t;

  typedef struct packed {
     logic[7:0] x;
  } struct_t;

  typedef logic [7:0] third_alias_t;
endpackage;

module dut (input clk, input pkg::enum_t a, output pkg::alias_t b);
   typedef pkg::struct_t second_alias_t; // Can be moved to pkg after
                                         // https://github.com/chipsalliance/Surelog/issues/1388

   second_alias_t c;
   pkg::third_alias_t d;
   assign c = a;
   assign d = c;
   assign b = d;
endmodule
