module top(output logic [3:0] o);
   union {
      bit [7:0] v1;
      bit [3:0] v2;
   } un;

   initial begin
      un.v1 = 8'hAB;
      o = un.v2;
   end
endmodule
