package aes_pkg;
   parameter logic [7:0][3:0] X = 32'habcd;
endpackage // aes_pkg

module aes_cipher_core import aes_pkg::*;
   #(parameter logic [7:0][3:0] P = X)
   (output int a);

   assign a = X;
endmodule // aes_cipher_core

module top(output int o);
   aes_cipher_core u_aes_cipher_core(.a(o));
endmodule
