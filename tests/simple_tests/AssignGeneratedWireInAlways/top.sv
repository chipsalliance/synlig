module top(output logic o);
   genvar i;
   generate
      for (i = 0; i < 1; i = i + 1) begin : gen_blk
         wire [i:i] z = '1;
      end
   endgenerate

   always_comb begin : always_block
      o = gen_blk[0].z;
   end
endmodule
