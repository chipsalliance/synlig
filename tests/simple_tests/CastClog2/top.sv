module top(output logic [1:0] o);
   parameter int X = 3;
   // We cast it to the smaller size
   // to see how the width will be reduced
   assign o = $clog2(X)'(31);
endmodule
