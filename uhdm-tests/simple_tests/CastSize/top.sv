module top(output logic [4:0] o);
   logic [15:0] a = 16'hAB;

   assign o = 5'(a);

endmodule
