module otp_ctrl_ecc_reg #(
   parameter  int Depth = 128
) (
   output logic [Depth-1:0] a
);
   assign a = '1;
endmodule : otp_ctrl_ecc_reg

module top(output int o);
   typedef struct packed {
      int x;
   } part_info_t;

   parameter part_info_t Info = part_info_t'(16);
   localparam int NumScrmblBlocks = Info.x;

   logic [NumScrmblBlocks-1:0] data;

   otp_ctrl_ecc_reg #(
      .Depth(NumScrmblBlocks)
   ) u_otp_ctrl_ecc_reg (
      .a(data)
   );

   assign o = int'(data);
endmodule : top
