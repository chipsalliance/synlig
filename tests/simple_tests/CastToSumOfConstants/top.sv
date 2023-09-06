module top(output logic [2:0] o);
   // We cast to the smaller width than the constant requires
   // to see if the proper number of bits is taken
   assign o = (1 + 2)'(31);
endmodule
