package my_pkg;
   function automatic logic get1();
      get1 = 1'b1;
   endfunction // get1
endpackage // my_pkg

module top(output o);
   assign o = my_pkg::get1();
endmodule // top
