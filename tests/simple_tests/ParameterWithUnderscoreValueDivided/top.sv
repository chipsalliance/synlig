module dut(output int a);
   parameter A = 'x;
   parameter B = 'x;
   localparam int C = A / B;

   assign a = int'(C);
endmodule // dut

module top(output int o);
   dut #(.A('d7_200), .B('d1_800)) u_dut(.a(o));
endmodule // top
