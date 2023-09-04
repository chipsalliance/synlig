module top(output logic a);
   logic x [1:0] = '{1, 0};
   assign a = x[1];
endmodule
