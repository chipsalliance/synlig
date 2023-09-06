module top(output int a);
   function automatic int test_while(int x);
       while (1) begin
           if (x > 100) break;
           x = x << 1;
           if (x > 50) continue;
           x = x + 2;
       end
       return x;
   endfunction
   initial a = test_while(1);
endmodule
