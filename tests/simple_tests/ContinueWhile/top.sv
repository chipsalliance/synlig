module top(output int a);
   function automatic int test_while(int x);
       while (x < 100) begin
           if (x > 100) continue;
           x = x << 1;
       end
       return x;
   endfunction
   initial a = test_while(1);
endmodule
