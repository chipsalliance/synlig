module dut (
    input logic clk,
    input logic             a,
    input logic [3:0]       b,
    output logic [1:0][3:0] out
);
    typedef logic [3:0] logic4;

    typedef struct packed {
        logic4 [1:0] vector2x4;
    } s_t;
    s_t s;

    always_comb begin
        s = '0;
        s.vector2x4[a] = b;
    end

    assign out = s.vector2x4;

endmodule
