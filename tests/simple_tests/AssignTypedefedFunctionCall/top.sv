module top(output logic [31:0] o);
   typedef logic [31:0] word;
   function automatic word get_abcd();
      return 32'hABCD;
   endfunction

   word x = get_abcd();
   assign o = x;
endmodule
