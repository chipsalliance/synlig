module top(output string o);
   parameter string NAME = "uart0";
   initial begin
      o = NAME;
   end
endmodule
