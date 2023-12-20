module dut(
    input logic clk,
    input logic [3:0]       a,
    input logic [3:0]       b,
    output logic [1:0][3:0] out
);

    struct packed {
        logic [1:0][3:0] vector2x4;
    } s;

    assign s.vector2x4[0] = a;
    assign s.vector2x4[1] = b;

    assign out = s.vector2x4;

endmodule
