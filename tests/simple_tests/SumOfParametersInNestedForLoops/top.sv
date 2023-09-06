module top(output int o);
   parameter int X = 1;
   parameter int Y = 2;
   for (genvar i = 0 ; i < 1 ; i++) begin
      for (genvar y = 0 ; y < 1 ; y++) begin
         localparam int Offset = X + Y;
         assign o = Offset;
      end
  end
endmodule
