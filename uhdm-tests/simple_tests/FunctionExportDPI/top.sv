module top(output int o);
   export "DPI-C" function get_1;
   function int get_1();
      return 1;
   endfunction // get_1

   import "DPI-C" context function int get_2;
   assign o = get_2();
endmodule
