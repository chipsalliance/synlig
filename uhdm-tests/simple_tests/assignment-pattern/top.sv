package p;
   typedef struct packed {
      integer 	  r;
      integer 	  th;
   } C;

   typedef struct packed {
      logic [2:0][63:0] a;
   } S;
endpackage

module top(output integer i, j, k, l_r, l_th,
	   output logic [63:0] m1, m2, m3,
	   output logic [2:0]  n);

   assign i = '{31:1, 23:1, 15:1, 8:1, default: 0};
   assign j = '{default: 1, 31:0};
   assign k = '{0:1, default: 0};

   p::C l = '{th:170, r:1};
   assign {l_r, l_th} = l;

   p::S m = '{'{64'h9, 64'h12, 64'h21}};
   assign {m1, m2, m3} = m;

   assign n = '{1, 1, 0};

   always_comb begin
      assert(i == 32'b10000000100000001000000100000000);
      assert(j == 32'b01111111111111111111111111111111);
      assert(k == 32'b00000000000000000000000000000001);

      assert(l == 64'b0000000000000000000000000000000100000000000000000000000010101010);
      assert(m == 192'h000900120021);

      assert(n == 3'b110);
   end
endmodule
