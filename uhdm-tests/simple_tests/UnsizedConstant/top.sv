module top(output logic [31:0] o);
   assign o = '1;
   always_comb begin
      assert(o == 32'hFFFF);
   end
endmodule // top
