typedef struct packed {
   int 	       x;
} my_struct;

module top(output my_struct o);
   assign o.x = 10;
endmodule // top
