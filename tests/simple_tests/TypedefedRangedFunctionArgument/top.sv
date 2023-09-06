module top(output logic [31:0] o);
   typedef logic [31:0] word;   
   
   function automatic word element_sum(input word [1:0] w);
      return w[0] + w[1];
   endfunction

   assign o = element_sum({32'h1234, 32'h5678}); 
endmodule
