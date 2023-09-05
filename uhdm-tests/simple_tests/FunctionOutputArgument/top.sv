package my_pkg;
   function automatic void assign_1(output logic x);
      assign x = 1'b1;
   endfunction // assign_1
endpackage // my_pkg

module top(output o);
   initial begin
      my_pkg::assign_1(o);
   end
endmodule // top
