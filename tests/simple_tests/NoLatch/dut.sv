module dut (
    input logic clk,
    input logic a,
    input logic b
);

    always_comb begin
        logic temp = 0; 
        if (a)
            temp = b;
    end

endmodule 
