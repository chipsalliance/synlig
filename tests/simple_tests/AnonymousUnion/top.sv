module top(output int o);
   union packed {
      int v1;
      int v2;
   } un;

   initial begin
      un.v1 = 1;
      o = un.v2;
   end
endmodule
