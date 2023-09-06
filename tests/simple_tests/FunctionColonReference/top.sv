package pkg;
   function automatic logic get1();
      return 1'b1;
   endfunction : get1
endpackage

module top(output a);
   assign a = pkg::get1();
endmodule
   
