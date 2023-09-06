package my_pkg;
   parameter int X = 8;
   typedef logic [X-1:0] word;
endpackage // my_pkg

module top(output my_pkg::word o);
   assign o = 8'h5C;
endmodule // top
