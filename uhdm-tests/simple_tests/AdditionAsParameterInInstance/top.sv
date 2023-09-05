module dut(output int a);
   parameter int P = 0;
   assign a = P;
endmodule // dut

module top(output int o);
   parameter int X = 1;
   parameter int Y = 2;
   dut #(
      .P(X + Y)
   ) u_dut(
      .a(o)
   );
endmodule // top
