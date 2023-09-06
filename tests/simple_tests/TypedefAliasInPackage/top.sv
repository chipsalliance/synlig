package lc_ctrl_pkg;
   typedef enum logic [3:0] {
      On = 4'b1010
   } lc_tx_e;

   typedef lc_tx_e lc_tx_t;

endpackage

module top(output logic [3:0] o);
   lc_ctrl_pkg::lc_tx_t lc_en_i = lc_ctrl_pkg::On;

   assign o = lc_en_i;

endmodule
