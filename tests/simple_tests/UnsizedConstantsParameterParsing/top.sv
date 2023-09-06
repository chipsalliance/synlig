module top;
   // Since current verilator doesn't support 'x and 'z values,
   // this test checks only if there are parsed withour errors
   parameter int a = '0;
   parameter int b = '1;
   parameter int c = 'x;
   parameter int d = 'z;
endmodule // top
