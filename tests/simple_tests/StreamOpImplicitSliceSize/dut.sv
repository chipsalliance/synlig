// Stream operator use case from https://github.com/bespoke-silicon-group/basejump_stl/blob/master/bsg_misc/bsg_scan.v
module dut #(parameter bit PARAM = 1)
    (input logic [7:0] i, output logic [7:0] o);

  wire [3:0][7:0] t;

  if (PARAM)
    assign t[0] = {<< {i}};
  else
    assign t[0] = i;

  assign o = t[0];
endmodule
