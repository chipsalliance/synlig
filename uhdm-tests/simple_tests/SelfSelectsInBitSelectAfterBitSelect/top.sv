module top(output logic o);
   logic [0:0][15:0] a = 16'hABCD;
   assign o = a[0][a[0][3:0]];
endmodule
