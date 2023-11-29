module dut(
    input logic clk,
    input logic [3:0] a,
    input logic [3:0] b,
    output logic [1:0][3:0] out
);
    typedef logic [3:0] logic4;

    typedef struct packed {
        logic4 [1:0] vector2x4;
    } s_t;
    s_t s;

   assign s.vector2x4[0] = a;
   assign s.vector2x4[1] = b;

   assign out = s.vector2x4;

endmodule