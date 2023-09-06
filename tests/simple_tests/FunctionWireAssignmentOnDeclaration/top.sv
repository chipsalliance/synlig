module top(
  input logic [2:0] i,
  output logic [2:0] o);
function automatic logic [2:0] test(logic [2:0] in);
  logic [2:0] data = in;
  return data;
endfunction

assign o = test(i);
endmodule
