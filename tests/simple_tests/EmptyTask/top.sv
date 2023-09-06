package my_pkg;
   task empty_task();
   endtask // empty_task
endpackage // my_pkg

module top(output o);
   initial begin
      my_pkg::empty_task();
   end
   assign o = 1'b1;
endmodule // top
