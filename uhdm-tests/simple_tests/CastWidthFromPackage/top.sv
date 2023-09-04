package my_pkg;
   parameter int Width = 4;
endpackage // my_pkg

module top(output logic [3:0] o);
   int a = 1;
   assign o = my_pkg::Width'(a);
endmodule // top
