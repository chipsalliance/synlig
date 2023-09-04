
module dut  (input d,
              input rstn,
              input clk,
              output reg q);

  always_comb
      begin
       if (!rstn)
          q = 0;
       else
          q = d;
      end
endmodule
 
