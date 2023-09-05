module top(output logic a);
    logic [1:0][3:0] x = {4'hF, 4'hF};

   function automatic logic my_func(logic [1:0][3:0] arg);
      return arg[0][0];
   endfunction

   assign a = my_func(x);

endmodule
