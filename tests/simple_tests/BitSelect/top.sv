module top(output logic a);
   logic x [1:0] = '{0, 1};
   assign a = x[0];
endmodule
