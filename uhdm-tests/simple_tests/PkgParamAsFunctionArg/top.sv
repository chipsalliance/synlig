package pkg;

  parameter logic [1:0] P = {1'b1, 1'b0};
     
endpackage
 

module top(output a);
   
   function automatic logic get_first(logic [1:0] x);
      return x[1];
   endfunction

   assign a = get_first(pkg::P);
 
endmodule
