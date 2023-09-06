module top(output logic[3:0] a, b, c, d);
   logic [1:0][2:0][3:0] x = '{
            '{'{0, 1, 1, 0},
             '{1, 1, 1, 0},
             '{0, 1, 0, 1}},
            '{'{0, 1, 1, 0},
             '{1, 1, 1, 0},
             '{0, 1, 0, 1}}
   };

   assign a = x[0][0];
   assign b = x[0][1];
   assign c = x[1][0];
   assign d = x[1][2];

   always_comb begin
      assert(a == 5);
      assert(b == 14);
      assert(c == 5);
      assert(d == 6);
   end
endmodule
