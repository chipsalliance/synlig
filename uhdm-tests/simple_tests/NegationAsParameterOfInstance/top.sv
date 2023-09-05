module dut(output int o);
   parameter logic [1:0] RESVAL;
   assign o = int'(RESVAL);
endmodule

module top(output int o);
   dut #(
      .RESVAL(~(2'h0))
   ) u_dut(.o(o));
endmodule
