module dut(
    input logic clk,
    input logic [3:0]       a,
    input logic [3:0]       b,
    output logic [1:0][3:0] out
);
    typedef logic [1:0][3:0] logic2x4;

    logic2x4 [1:0] vector2x2x4;
    assign vector2x2x4[0][0] = a;
    assign vector2x2x4[0][1] = b;

    assign out = vector2x2x4[0];

endmodule
