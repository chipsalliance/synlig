
class u;
	  int i;
endclass

module top(output [3:0] b);
  class c;
    function void foo(int i);
    endfunction
  endclass
  u one;
  c two;
endmodule
