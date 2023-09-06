module top;
   // Since current verilator doesn't support 'x and 'z values,
   // this test checks only if there are parsed withour errors
   int a = '0;
   int b = '1;
   int c = 'x;
   int d = 'z;
endmodule // top
