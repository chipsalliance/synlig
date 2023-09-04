package lc_ctrl_pkg;
   parameter int TxWidth = 4;
   typedef logic [TxWidth-1:0] lc_tx_t;
endpackage : lc_ctrl_pkg

module top import lc_ctrl_pkg::lc_tx_t; (
   output lc_tx_t o
);
   assign o = 5;
endmodule
