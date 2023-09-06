package my_pkg;
   typedef enum logic [3:0] {
       On = 4'b1010,
       Off = 4'b1111
   } lc_tx_t;
endpackage

module top(output int o);
   my_pkg::lc_tx_t [1:0] x = '{my_pkg::On, my_pkg::Off};
   assign o = int'(x);
endmodule
