package my_pkg;
   task assign_1(inout logic x);
      assign x = 1'b1;
      return;
      assign x = 1'b0;
   endtask // assign_1
endpackage // my_pkg

module top(output logic o);
   initial begin
      assign o = 1'b0;
      my_pkg::assign_1(o);
   end
endmodule // top
