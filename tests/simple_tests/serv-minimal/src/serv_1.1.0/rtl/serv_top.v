`default_nettype none

module serv_top
   (
   input wire           clk,
   input wire           i_rst,
   //RF Interface
   output wire [4+1:0] o_wreg0,
   output wire [4+1:0] o_wreg1,
   output wire [4+1:0] o_rreg0,
   output wire [4+1:0] o_rreg1,

   output wire           o_ibus_cyc,
   input wire [31:0]         i_ibus_rdt,
   input wire           i_ibus_ack);

   wire          jump;
   reg          utype;
   wire          imm;

   wire    bufreg_q;
   wire    ctrl_rd;
   
   reg        ibus_cyc;


   assign o_ibus_cyc = ibus_cyc & !i_rst;
   always @(posedge clk) begin
      if (i_ibus_ack | i_rst)
  ibus_cyc <= i_rst;
   end

   reg [4:0] opcode;

   wire co_ctrl_utype       = !opcode[4] & opcode[2] & opcode[0];
         always @(posedge clk) begin
            if (i_ibus_ack) begin
               opcode <= i_ibus_rdt[6:2];
            end
         end

         always @(*) begin
            utype       = co_ctrl_utype;
         end

   serv_ctrl
   ctrl
     (
      .clk        (clk),
      .i_rst      (i_rst),
      //State
      .utype    (utype),
      //Data
      .imm      (imm),
      .bufreg_q      (bufreg_q),
      .ctrl_rd       (ctrl_rd),
      //External
      .o_ibus_adr ());

endmodule
`default_nettype wire
