module top(output int o);
   genvar i;
   generate
      for (i = 0; i < 1; i = i + 1) begin : gen_blk
         wire [i:i] z = '1;
      end
   endgenerate

   always_comb begin : always_block
      case (gen_blk[0].z)
        1: o = 1;
        default: o = 0;
      endcase
   end
endmodule
