module rv_dm(output int a);
endmodule // rv_dm

module dmidpi(output int b);
   assign b = 10;
endmodule // dmidpi

module top(output int o);
   bind rv_dm dmidpi u_dmidpi(.b(a));
   rv_dm u_rv_dm(.a(o));
endmodule // top
