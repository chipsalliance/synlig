module top(output int o [2:0][3:0]);
   assign o = '{'{0, 1, 2, 3},
                '{10, 11, 12, 13},
                '{20, 21, 22, 23}};
endmodule
