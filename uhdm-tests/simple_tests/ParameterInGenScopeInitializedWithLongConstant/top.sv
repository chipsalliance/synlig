module top(output logic [63:0] o);
   for (genvar c = 0; c < 1; c++) begin : gen_lfsr_chunks
      localparam logic [63:0] LfsrChunkSeed = 64'h123456789ABCDEF0;
      assign o = LfsrChunkSeed;
   end
endmodule
