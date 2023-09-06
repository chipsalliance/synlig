module top(output logic o);
   function automatic logic theta();
      for (int x = 0 ; x < 5 ; x++) begin
         logic a;
         a = 1'b1;
         return a;
      end
      return 1'b0;
   endfunction : theta

   assign o = theta();
endmodule : top
