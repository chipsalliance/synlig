module top(output int o);
   // Originally was [1:6], but sv2v inverts unpacked ranges in some cases,
   // leading to formal verification failures.
   int n [6:1] = '{3{4, 5}};
   assign o = n[2];
endmodule 
