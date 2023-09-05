module top(output logic o);
   typedef logic [31:0] word;
   function automatic logic check_if_abcd(input word x);
      return x == 32'hABCD;
   endfunction

   word a = 32'hABCD;
   assign o = check_if_abcd(a);
endmodule
