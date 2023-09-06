`default_nettype none
module serv_ctrl
  (
   input wire        clk,
   input wire        i_rst,
   //State
   input wire        utype,
   //Data
   input wire        imm,
   input wire        bufreg_q,
   output wire        ctrl_rd,
   //External
   output reg [31:0] o_ibus_adr);

   wire       pc_plus_offset_aligned;
   wire       offset_b;

 assign ctrl_rd  = (utype & pc_plus_offset_aligned);

   assign offset_b = utype ? (imm ): bufreg_q;
endmodule
