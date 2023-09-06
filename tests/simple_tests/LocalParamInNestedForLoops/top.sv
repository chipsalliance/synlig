module top(output int o);
   parameter int RhoOffset [2]  = '{0, 1};
   for (genvar i = 0 ; i < 1 ; i++) begin
      for (genvar y = 0 ; y < 1 ; y++) begin
         localparam int Offset = RhoOffset[1];
         assign o = Offset;
      end
  end
endmodule
