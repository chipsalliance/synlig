module top(output int o);
   int a;
   initial begin
      o = 0;
      fork
         o = 1;
      join

      a = 0;
      fork
         a = 1;
      join_any
   end
endmodule // top
