module top(input logic clk, output logic[3:0] out);
   typedef enum logic [3:0] {
        LMR      = 4'b0000,
        REF      = 4'b0001,
        PRE      = 4'b0010,
        ACT      = 4'b0011,
        WRITE    = 4'b0100,
        READ     = 4'b0101,
        BST      = 4'b0110,
        NOP      = 4'b0111,
        DESELECT = 4'b1xxx
   } dfi_cmd_e;

   assign out = DESELECT;
endmodule
