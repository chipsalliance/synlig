module top(output reg a);
   int n[1:2][1:3] = '{'{0,1,2},'{4, 4, 4}};

   initial begin
      if (n[1][2] == 1)
         a = 1;
      else
         a = 0;
   end
endmodule
