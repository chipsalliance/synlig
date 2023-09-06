module top(output int o);
   initial begin
      o = 0;
      fork
         o = 1;
      join
   end
endmodule // top
