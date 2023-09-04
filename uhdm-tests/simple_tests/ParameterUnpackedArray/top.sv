module top(output int a, b, c, d);
   parameter int P [1:0][2:0][3:0] = '{
				       '{'{0, 1, 2, 3},
					 '{10, 11, 12, 13},
					 '{20, 21, 22, 23}},
				       '{'{100, 101, 102, 103},
					 '{110, 111, 112, 113},
					 '{120, 121, 122, 123}}
				       };
   
   assign a = P[0][0][2];
   assign b = P[0][1][3];
   assign c = P[1][2][1];
   assign d = P[1][0][3];

   always_comb begin
      assert(a == 121);
      assert(b == 110);
      assert(c == 2);
      assert(d == 20);
   end
endmodule
