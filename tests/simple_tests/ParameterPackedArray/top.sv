module top(output logic[3:0] a, b, c, d);
   parameter logic [1:0][2:0][3:0] P = '{
					 '{'{0, 1, 1, 0},
					   '{1, 1, 1, 0},
					   '{0, 1, 0, 1}},
					 '{'{0, 1, 1, 0},
					   '{1, 1, 1, 0},
					   '{0, 1, 0, 1}}
					 };

   assign a = P[0][0];
   assign b = P[0][1];
   assign c = P[1][0];
   assign d = P[1][2];

   always_comb begin
      assert(a == 5);
      assert(b == 14);
      assert(c == 5);
      assert(d == 6);
   end

endmodule
