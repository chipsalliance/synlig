module top(output int o);
   initial begin
      o = 0;
      repeat(15)
         o += 10;
   end
endmodule
