module sub(input logic data_i, output logic o);
   assign o = data_i;
endmodule

module top(
   input logic [0:0][3:0] data_i,
   output logic [3:0] o
);
   for (genvar j = 0; j < 4; j++) begin : gen_sbox_j
      sub u_sub (
         .data_i(data_i[0][j]),
         .o(o[j])
      );
   end
endmodule
