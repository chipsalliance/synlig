module dut
#(
   parameter int Width
) (
   input [Width-1:0] wmask_i,
   output int x
);
   assign x = int'(wmask_i);
endmodule

module top(output int o);
   parameter int Width = 16;
   parameter int EccWidth = 3;

   dut #(
      .Width(Width + EccWidth)
   ) u_dut (
      .wmask_i({Width+EccWidth{1'b1}}),
      .x(o)
   );
endmodule
