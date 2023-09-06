module top(output logic [31:0] o);
   typedef logic [31:0] word;
   word x = 32'hABCD;
   assign o = x;
endmodule
