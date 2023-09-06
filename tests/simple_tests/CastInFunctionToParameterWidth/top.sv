module top #(
   parameter int unsigned Depth = 3,
   parameter int unsigned PTR_WIDTH = 15
)(
   output logic [PTR_WIDTH-1:0] o
);
   assign o = get_casted_depth();

   function automatic [PTR_WIDTH-1:0] get_casted_depth();
      return (PTR_WIDTH)'(Depth);
   endfunction
endmodule
