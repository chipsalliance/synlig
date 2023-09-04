module top(output int a, output int b);
   initial begin
      a = 0;
      b = 0;
      repeat(15) begin
         a = a + 10;
         if(a > 100) continue;
         b = b + 5;
      end
   end
endmodule
