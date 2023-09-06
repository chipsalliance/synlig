module top(output reg a);
   import "DPI-C" function
     chandle test_output();

   import "DPI-C" function
     void test_input(input chandle in);

initial begin
   chandle ch = test_output();
   test_input(ch);

   if (ch == 0)
     assign a = 0;
   else
     assign a = 1;
   end
endmodule
