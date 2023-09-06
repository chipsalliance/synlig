package my_pkg;
   typedef enum logic [3:0] {
       On = 4'b1010
   } lc_tx_t;
endpackage

module top(output int o);
   my_pkg::lc_tx_t [7:0] x = '{8{my_pkg::On}};
   assign o = x;
endmodule
