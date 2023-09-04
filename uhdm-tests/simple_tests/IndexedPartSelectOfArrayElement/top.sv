module top(output logic [1:0] o);
   typedef struct packed {
      logic [7:0] source;
   } tl_h2d_t;

   tl_h2d_t a[1:0] = '{8'h12, 8'h34};
   assign o = a[0].source[6 -: 2];
endmodule
