module top(output int o);
   initial begin
      o = 1;
   end

   // The call of this function will hang the program
   // in infinite loop
   // It only tests parsing of forever statement
   task automatic forever_test();
      forever begin : loop
         o = 10;
      end
   endtask
endmodule
