module top(output logic[1:0] o);
   logic [4:0][1:0] x = '1;
   assign o = x[0][1:0];
endmodule
