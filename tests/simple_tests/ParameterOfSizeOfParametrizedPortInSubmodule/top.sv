module submodule #(
   parameter int X = 15
) (
   output logic [X-1:0] a
);
   parameter logic [$bits(a)-1:0] Y = '1;
   assign a = Y;
endmodule

module top(
   output logic [14:0] o,
   output logic [4:0] p,
   output logic [9:0] r
);
   submodule u_sub_default(.a(o));
   submodule #(.X(5)) u_sub_5(.a(p));
   submodule #(.X(10)) u_sub_10(.a(r));
endmodule
