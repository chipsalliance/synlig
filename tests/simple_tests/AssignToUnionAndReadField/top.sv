module top(output logic [3:0] o);
   union packed {
      bit [3:0] field;
   } un;

   initial begin
      un = 4'hA;
      o = un.field;
   end
endmodule
