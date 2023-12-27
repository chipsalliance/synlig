module dut #(
		      parameter ENTSEL = 2,
		      parameter ENTNUM = 4
		     )
  (
   input logic clk,
   input wire [ENTNUM-1:0] in,
   output reg [ENTSEL-1:0] out,
   output reg              en
   );

   integer 		   i;
   always @ (*) begin
      out = 0;
      en = 0;
      
      for (i = ENTNUM-1; i >= 0 ; i = i - 1) begin
	 if (in[i]) begin
	    out = i;
	    en = 1;
	 end
      end
      
   end
   
endmodule // search_from_top
