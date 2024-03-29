module dut(
    input logic clk,
    input logic [3:0]       a,
    input logic [3:0]       b,
    output logic [1:0][3:0] out
);
    typedef logic [3:0] logic4;

    logic4 [1:0] vector2x4;
    assign vector2x4[0] = a;
    assign vector2x4[1] = b;
   

    assign out = vector2x4;

endmodule // dut

