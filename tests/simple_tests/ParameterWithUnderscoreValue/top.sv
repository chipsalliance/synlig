module dut(output int a);
   parameter P = 'x;
   assign a = int'(P);
endmodule // dut

module top(output int o);
   dut #(.P('d7_200)) u_dut(.a(o));
endmodule // top
