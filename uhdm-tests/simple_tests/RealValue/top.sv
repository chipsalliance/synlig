module top(output reg a);
   initial begin
      real b = 0.5;
      if (b + b == 1)
         a = 1;
      else
         a = 0;
   end
endmodule
