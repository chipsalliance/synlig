module top #(
   parameter int X = 15
) (
   output logic [X-1:0] o
);
   parameter logic [$bits(o)-1:0] Y = '1;
   assign o = Y;
endmodule
