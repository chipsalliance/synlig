module dut1;
endmodule // dut1

module dut2;
endmodule // dut2

module top(output int o);
   bind dut1 dut2 u_dut2();
   assign o = 1;
endmodule // top
