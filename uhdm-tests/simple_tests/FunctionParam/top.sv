module top(output int o);
   parameter int X [1:0] = '{0, 1};

   function automatic int theta();
      return X[0];
   endfunction : theta

   assign o = theta();
endmodule
