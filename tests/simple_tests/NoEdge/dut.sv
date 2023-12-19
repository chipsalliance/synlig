module dut(clk, fifo_push, fullness_in);
   parameter               DEPTH      = 4;
   parameter               DEPTH_BITS = 2; //0 is ilegal
   input                      clk;
   input wire               fifo_push;
   
   output reg [DEPTH-1:0]           fullness_in;
   reg [DEPTH_BITS-1:0]       ptr_in;
   
   always @(/*AUTOSENSE*/fifo_push or ptr_in)
     begin
    fullness_in = 4'b0;
    fullness_in[ptr_in] = fifo_push;
     end
 
endmodule


