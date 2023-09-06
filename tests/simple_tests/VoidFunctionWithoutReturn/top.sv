package my_pkg;
   function automatic void get_no_value();
   endfunction // get_no_value
endpackage // my_pkg

module top(output o);
   initial begin
      my_pkg::get_no_value();
   end
   assign o = 1'b1;
endmodule // top
