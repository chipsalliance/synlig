module top(output logic a, b, c, d);
   parameter logic P [1:0][2:0][3:0] = '{
					 '{'{0, 1, 0, 1},
					   '{0, 1, 1, 1},
					   '{0, 1, 1, 1}},
					 '{'{0, 1, 1, 1},
					   '{0, 1, 1, 1},
					   '{0, 1, 1, 1}}
					 };
   
   assign a = P[0][0][2];
   assign b = P[0][1][3];
   assign c = P[1][2][1];
   assign d = P[1][0][3];

   always_comb begin
      assert(a == 1);
      assert(b == 0);
      assert(c == 0);
      assert(d == 0);
   end
endmodule
