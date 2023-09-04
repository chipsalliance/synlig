module top(output int o);
   parameter int RhoOffset [2]  = '{0, 1};
   for (genvar i = 0 ; i < 1 ; i++) begin
      for (genvar y = 0 ; y < 1 ; y++) begin
         assign o = RhoOffset[1];
      end
  end
endmodule
