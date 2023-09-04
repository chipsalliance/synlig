module sub(input logic data_i, output logic o);
   assign o = data_i;
endmodule

module top(
   input logic [3:0][3:0] data_i,
   output logic [3:0][3:0] o
);
   for (genvar j = 0; j < 4; j++) begin : gen_sbox_j
      for (genvar i = 0; i < 4; i++) begin : gen_sbox_i
         sub u_sub (
            .data_i(data_i[i][j]),
            .o(o[i][j])
         );
      end
   end
endmodule
