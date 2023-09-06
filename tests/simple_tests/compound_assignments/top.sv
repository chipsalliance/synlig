module top(output logic a, b, c, d, e, f, g, h, i, j, k, l);
   initial begin
      a  = 1;
      a -= 1;
      b  = 4;
      b /= 2;
      c  = 5;
      c %= 2;
      d  = 1;
      d <<= 1;
      e  = 8;
      e >>= 1;
      f  = 1;
      f += 1;
      g  = 2;
      g *= 3;
      h  = 3;
      h &= 1;
      i  = 6;
      i |= 4;
      j  = 1;
      j ^= 0;
      k  = 5;
      k <<<= 1;
      l  = 5;
      l >>>= 1;
   end
endmodule
