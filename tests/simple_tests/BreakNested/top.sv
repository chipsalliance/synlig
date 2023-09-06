module top(output int a, output int b);
   initial begin
      a = 0;
      b = 0;
      repeat(15) begin
         if(a > 100) begin
            for (int i = 0; i < 5; i++) begin
               if (b > 15)
                  break;
               b = b + 5;
            end
            break;
         end
         a = a + 10;
      end
   end
endmodule
