module top(output string o);
   parameter string NAME = "abcd";
   assign o = {NAME, "efgh"};
endmodule
