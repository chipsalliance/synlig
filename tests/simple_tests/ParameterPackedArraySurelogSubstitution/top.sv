// Surelog flag "--disable-feature=parametersubstitution" is not used purposely

module top(output logic[3:0] a);
   parameter logic [0:0][3:0] P = '{'{1'b1, 1'b0, 1'b0, 1'b0}};

   assign a = P[0];
endmodule
