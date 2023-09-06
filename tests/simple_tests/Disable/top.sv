module top(output int o);
   initial begin
      o = 1;
   end

   // disable statement is unsupported in current verilator
   // so the the call of this function will hang the program
   // in infinite loop
   // It only tests parsing of forever and disable statements
   task automatic forever_test();
      forever begin : loop
         o = 10;
         disable loop;
      end
   endtask
endmodule
