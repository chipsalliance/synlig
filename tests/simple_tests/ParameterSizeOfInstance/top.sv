package aes_pkg;
   parameter logic [159:0] P_PKG =
      160'hc132b5723c5a4cf4743b3c7c32d580f74f1713a;
endpackage // aes_pkg

module aes_cipher_core import aes_pkg::*;(output int x);
   parameter logic [159:0] P_INSTANCE = P_PKG;
   assign x = P_INSTANCE[31:0];
endmodule // aes_cipher_core

module top import aes_pkg::*;(output int o);
   aes_cipher_core #(
      .P_INSTANCE(P_PKG)
   ) u_aes_cipher_core (.x(o));
endmodule // top
