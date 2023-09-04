module top(output logic [31:0] o);
   typedef logic [31:0] word;
   function automatic word get_abcd();
      return 32'hABCD;
   endfunction

   assign o = get_abcd();
endmodule
