package my_pkg;
   function automatic logic get_1();
      return 1'b1;
   endfunction // get_1

   function automatic logic get_1_by_function();
      return get_1();
   endfunction // get_1_by_function
endpackage // my_pkg

module top(output logic o);
   assign o = my_pkg::get_1_by_function();
endmodule // top
