module top(output int o);
   parameter int X = 3;
   assign o = int'($clog2(X)'(X));
endmodule
