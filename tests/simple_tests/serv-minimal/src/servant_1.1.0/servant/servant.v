`default_nettype none
module servant
(
 input wire  wb_clk,
 input wire  wb_rst,
 output wire q);

   parameter memfile = "zephyr_hello.hex";
   parameter memsize = 8192;
   parameter reset_strategy = "MINI";
   parameter sim = 0;
   parameter with_csr = 1;

   wire [31:0]   wb_mem_rdt;
   wire   wb_mem_ack;
   reg [31:0]     mem [0:memsize/4-1] /* verilator public */;

   serv_rf_top
   cpu
     (
      .clk      (wb_clk),
      .i_rst    (wb_rst),

      .o_ibus_cyc   (),
      .i_ibus_rdt   (wb_mem_rdt),
      .i_ibus_ack   (wb_mem_ack));

endmodule
