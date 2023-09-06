`default_nettype none

module serv_rf_top
  (
   input wire         clk,
   input wire         i_rst,
   output wire         o_ibus_cyc,
   input wire [31:0]  i_ibus_rdt,
   input wire         i_ibus_ack);
   

   wire [4+1:0] wreg0;
   wire [4+1:0] wreg1;
   wire [4+1:0] rreg0;
   wire [4+1:0] rreg1;

   serv_top
   cpu
     (
      .clk      (clk),
      .i_rst    (i_rst),
      .o_wreg0     (wreg0),
      .o_wreg1     (wreg1),
      .o_rreg0     (rreg0),
      .o_rreg1     (rreg1),

      .o_ibus_cyc   (o_ibus_cyc),
      .i_ibus_rdt   (32'h00000297/*i_ibus_rdt*/),
      .i_ibus_ack   (o_ibus_cyc));

endmodule
`default_nettype wire
