module dut1(output logic [1:0] a);
   parameter logic [1:0] P1 = 2'b0;
   assign a = P1;
endmodule // dut1

module dut2(output logic [1:0] b);
   parameter logic [1:0] P2 = 2'b11;
   dut1 #(
      .P1(~P2)
   ) u_dut1(
      .a(b)
   );
endmodule // dut2

module top(output logic [1:0] o);
   parameter logic [1:0] X = '{0, 1};
   dut2 #(
      .P2(X)
   ) u_dut2(
      .b(o)
   );
endmodule // top
