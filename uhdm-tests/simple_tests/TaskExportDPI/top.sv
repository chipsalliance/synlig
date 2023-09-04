module top(output int a);
   export "DPI-C" task get_1;
   task get_1(output int o);
      o = 1;
   endtask // get_1

   import "DPI-C" context task get_2(output int x);
   
   initial begin
      get_2(a);
   end
endmodule
