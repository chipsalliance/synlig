package lc_ctrl_pkg;
   parameter int TxWidth = 4;
endpackage : lc_ctrl_pkg

module top(output int o);
   import lc_ctrl_pkg::TxWidth;
   assign o = TxWidth;
endmodule
