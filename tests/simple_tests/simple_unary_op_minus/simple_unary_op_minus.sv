/*
:name: simple_unary_op_minus
:description: minimal - operator simulation test (without result verification)
:tags: 11.3
*/
module top(input [3:0] a, output [3:0] b);
    assign b = -a;
endmodule