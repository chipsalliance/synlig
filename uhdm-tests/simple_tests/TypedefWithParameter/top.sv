package my_pkg;
   parameter int X = 8;
   typedef logic [X-1:0] word;
endpackage // my_pkg

module top(output logic [7:0] o);
   my_pkg::word w = 8'h5C;
   assign o = w;
endmodule // top
