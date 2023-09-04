package my_pkg;
   typedef struct packed {
      logic [1:0] rxblvl;
      logic [15:0] nco;
   } uart_reg2hw_ctrl_reg_t;

   typedef struct  packed {
      uart_reg2hw_ctrl_reg_t ctrl;
   } uart_reg2hw_t;
endpackage // my_pkg
   
module top(output int o);
   my_pkg::uart_reg2hw_t reg2hw;
   assign o = $bits(reg2hw.ctrl.nco);
   always_comb begin
      assert(o == 16);
   end
endmodule // top
