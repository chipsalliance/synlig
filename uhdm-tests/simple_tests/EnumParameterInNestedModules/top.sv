module prim_subreg(output int a);
   parameter logic [4:0] RESVAL = '0;
   assign a = int'(RESVAL);
endmodule // prim_subreg

module prim_subreg_shadow(output int b);
   typedef enum logic [4:0] {
      ENUM_ITEM = 5'b10101
   } enum_t;

   parameter enum_t RESVAL = ENUM_ITEM;

   prim_subreg #(
      .RESVAL(RESVAL)
   ) staged_reg (.a(b));
endmodule // prim_subreg_shadow

module top(output int o);
   typedef enum logic [4:0] {
      ENUM_ITEM = 5'b11111
   } enum_t;

   parameter enum_t CTRL_RESET = ENUM_ITEM;

   prim_subreg_shadow #(
      .RESVAL(CTRL_RESET)
   ) u_ctrl_reg_shadowed (.b(o));

   always_comb begin
      assert(o == 31);
   end
endmodule // top
