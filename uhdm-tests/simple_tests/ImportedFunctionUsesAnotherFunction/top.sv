package pkg; // verilog_lint: waive package-filename
  parameter int PARAM = 10;
  function automatic int func_2();
    return PARAM;
  endfunction
  function automatic int func_1();
    return func_2();
  endfunction
endpackage
module top();
import pkg::func_1;
int result;
assign result = func_1();
endmodule
