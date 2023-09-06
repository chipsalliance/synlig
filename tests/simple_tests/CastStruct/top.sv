module top(output logic [4:0] o);
   typedef struct packed {
      logic [4:0] x;
   } my_struct;
   
   logic [15:0] a = 16'hAB;

   assign o = my_struct'(a);

endmodule
