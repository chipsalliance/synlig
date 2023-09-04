module dut(input a, output b);

function f2 (int i, int j);
endfunction


// Parsing test - does Verilator understand the AST below?
// (can be optimized out)
function f1();
   for ( int i=0;i<4; i++) begin
      f2(i,0);
   end
endfunction

assign b = a;

endmodule
