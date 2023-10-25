module dut (input clk);

  reg [5:0] x [4:0];

function automatic function_a (input [5:0] x [4:0]);
  function_a = 1;
endfunction

function automatic function_b (input [5:0] x [4:0]);
  function_b = 0;
endfunction

endmodule
