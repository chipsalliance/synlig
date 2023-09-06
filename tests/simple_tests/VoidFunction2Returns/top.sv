package my_pkg;
   function automatic void assign_1(output int x);
      assign x = 1;
      return;
      assign x = 2;
      return;
   endfunction // assign_1
endpackage // my_pkg

module top(output int o);
   initial begin
      my_pkg::assign_1(o);
   end
endmodule // top
