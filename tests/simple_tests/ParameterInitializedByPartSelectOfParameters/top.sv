module top(output logic [5:0] o);
   localparam int DepthW = 5;
   localparam int unsigned WidthRatio = 20;
   localparam bit [DepthW:0] FullDepth = WidthRatio[DepthW:0];
   assign o = FullDepth;
endmodule
