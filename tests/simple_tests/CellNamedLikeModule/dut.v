module mod #(int x = 0) (a,b);
   input a;
   output b;
   assign b = a;
endmodule

module dut (a, b);
   input a;
   output b;
   reg c;

   mod #(.x(0)) mod(.a(a), .b(c));
   mod #(.x(1)) mod2(.a(c), .b(b));
endmodule
