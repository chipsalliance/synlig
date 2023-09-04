module rv_dm(input logic clk_i);
endmodule // rv_dm

module dmidpi(input logic clk_i);
endmodule // dmidpi

module top(output int o);
   if (1) begin: gen_bind
      bind rv_dm dmidpi u_dmidpi(.clk_i);
   end
   assign o = 10;
endmodule // top
