module top(output logic o);
   logic [15:0] a = 16'hABCD;
   assign o = a[a[3:0]];
endmodule
