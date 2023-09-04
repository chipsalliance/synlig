module top(output string o);
   parameter string NAME = "abcd";
   localparam string X = {NAME, "efgh"};
   assign o = X;
endmodule
