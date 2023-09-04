module prim_subreg(output int x);
   parameter logic [31:0] RESVAL = '0;
   assign x = RESVAL;
endmodule

module top(output int o);
   parameter logic [31:0] RESVAL   = '0;

   prim_subreg #(
      .RESVAL(~RESVAL)
   ) staged_reg(o);

   always_comb begin
      assert(o == 32'hFFFFFFFF);
   end
endmodule
