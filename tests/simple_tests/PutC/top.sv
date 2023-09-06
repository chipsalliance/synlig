module top(output reg a);
   string b = "Test";
   initial
      begin
         b.putc(2, "x");
         if(b == "Text")
            a = 1;
         else
            a = 0;
      end
endmodule
