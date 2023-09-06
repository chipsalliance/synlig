module top(output int o);
   parameter  int unsigned Depth  = 500;
   localparam int unsigned PtrWidth = 3;

   if (Depth > 2) begin : gen_block
      function automatic [PtrWidth-1:0] get_casted_param();
         logic [PtrWidth-1:0] dec_tmp_sub = (PtrWidth)'(Depth);
         return dec_tmp_sub;
      endfunction

      assign o = int'(get_casted_param());
   end
   else
     assign o = 0;
endmodule
