module top(output logic [5:0] o);
   typedef struct packed {
      logic [2:0] x;
   } my_struct;

   typedef my_struct [1:0] my_struct_array;
   
   logic [15:0] a = 16'hAB;

   assign o = my_struct_array'(a);

endmodule
