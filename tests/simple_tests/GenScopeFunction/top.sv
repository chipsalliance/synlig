module top(output int o);
   parameter int unsigned Depth = 4;

   if (Depth > 2) begin : gen_block
      function automatic int get1();
         return 1;
      endfunction // get1

      assign o = get1();
   end : gen_block
   else
     assign o = 0;
endmodule
