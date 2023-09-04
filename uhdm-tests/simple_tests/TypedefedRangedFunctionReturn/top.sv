module top(output logic [31:0] a, b);
   typedef logic [31:0] word;
   function automatic word[1:0] get_2_abcd();
      return {32'hABCD, 32'hABCD};
   endfunction

   assign {a, b} = get_2_abcd();
endmodule
