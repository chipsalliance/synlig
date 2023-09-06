module top(output int a);
   int x [1:0][0:0] = '{'{1}, '{0}};

   function automatic int my_func(int arg [1:0][0:0]);
      return arg[1][0];
   endfunction

   assign a = my_func(x);
endmodule
