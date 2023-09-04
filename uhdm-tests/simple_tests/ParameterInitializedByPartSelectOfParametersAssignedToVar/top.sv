module top(output int o);
   localparam int DepthW = 5;
   localparam int unsigned WidthRatio = 20;
   localparam bit [DepthW:0] FullDepth = WidthRatio[DepthW:0];

   logic [DepthW:0] max_value;
   if (1 < 2) begin : gen_pack_mode
      assign max_value = FullDepth;
      assign o = int'(max_value);
   end
endmodule
