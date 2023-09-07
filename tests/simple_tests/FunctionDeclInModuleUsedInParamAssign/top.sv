module sub(input i, output o);
   parameter int M_SECURE = 1;
   assign o = i;
   
endmodule 

module top (
 input i, output o
);
   parameter M00_SECURE = 1'b0;

   
function w_1(input val);
    w_1 = val;
endfunction

   sub #( .M_SECURE({ w_1(M00_SECURE) })) m1(i,o);


endmodule // and2
