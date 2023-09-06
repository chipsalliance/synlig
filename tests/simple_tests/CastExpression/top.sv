module top(output logic [4:0] o);
   parameter P = 4;

   logic [15:0] a = 16'hAB;

   assign o = (P + 1)'(a);

endmodule
