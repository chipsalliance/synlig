module top(output logic[2:0] o);
   function automatic logic [2:0] get_3rd(logic [2:0] mat [3:0]);
      return mat[3];
   endfunction // get_3rd

   logic [2:0] a [3:0] = '{default: '{default: 0}};
   assign a[3][2] = 1'b1;

   assign o = get_3rd(a);
endmodule // top
