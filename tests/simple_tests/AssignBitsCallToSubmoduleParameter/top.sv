module aes_reg_status #(
   parameter int Width = 1
)(
   input logic [Width-1:0] we_i,
   output int we_o
);
   assign we_o = int'(we_i);
endmodule

module top(output int o);
   logic [7:0] key_init_we [2];
   assign key_init_we[0] = '1;

   aes_reg_status #(
      .Width($bits(key_init_we))
   ) u_reg_status_key_init(
      .we_i({key_init_we[1], key_init_we[0]}),
      .we_o(o)
   );
endmodule
