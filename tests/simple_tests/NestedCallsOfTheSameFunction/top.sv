package my_pkg;
   function automatic int aes_mul2(int x);
      return 2 * x;
   endfunction

   function automatic int aes_mul4(int x);
      return aes_mul2(aes_mul2(x));
   endfunction
endpackage // my_pkg

module top(output int o);
   assign o = my_pkg::aes_mul4(1);
endmodule // top
