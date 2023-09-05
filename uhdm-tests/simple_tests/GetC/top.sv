module top(output byte o);
   string a = "Test";
   assign o = a.getc(2);
endmodule
