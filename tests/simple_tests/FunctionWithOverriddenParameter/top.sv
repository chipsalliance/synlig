module prim_lfsr(output int o);
   parameter int unsigned LfsrDw = 12;
   function automatic logic [LfsrDw-1:0] get_1s();
      logic [LfsrDw-1:0] a = '1;
      return a;
   endfunction

   initial begin
      o = int'(get_1s());
   end
endmodule

module top(output int o);
   prim_lfsr #(
      .LfsrDw(16)
   ) u_lfsr(.o(o));
endmodule
