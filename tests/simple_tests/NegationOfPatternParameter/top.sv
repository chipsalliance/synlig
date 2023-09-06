module top(output logic [1:0] o);
   parameter logic [1:0] X = '{0, 1};
   assign o = ~X;
endmodule // top
