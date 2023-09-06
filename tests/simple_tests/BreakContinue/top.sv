module top(output int a, output int b);
   initial begin
      a = 0;
      b = 0;
      repeat(15) begin
         if(a > 100) begin
            if (b > 10)
               break;
            b = b + 5;
            continue;
         end
         a = a + 10;
      end
   end
endmodule
