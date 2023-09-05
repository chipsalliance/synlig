module top(output logic [31:0] o);
   parameter logic [31:0] P = '1;
   assign o = P;

   always_comb begin
      assert(o == 32'hFFFF);
   end
endmodule // top
