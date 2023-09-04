module top(output logic [17:0] o);
   localparam logic[17:0] X = ~(15);
   assign o = X;
endmodule
