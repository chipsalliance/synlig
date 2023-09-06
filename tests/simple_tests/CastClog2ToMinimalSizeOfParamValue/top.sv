module top(output logic [1:0] o);
   parameter int X = 3;
   assign o = $clog2(X)'(X);
endmodule
