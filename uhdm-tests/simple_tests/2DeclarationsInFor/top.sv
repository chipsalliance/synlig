module top(output int o);
   function automatic int theta();
      for (int x = 0 ; x < 5 ; x++) begin
         int a, b;
         a = 1;
         b = 2;
         return a + b;
      end
      return 0;
   endfunction : theta

   assign o = theta();
endmodule : top
