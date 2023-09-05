module top(output logic [31:0] o);
   typedef struct packed {
      logic [31:0] data;
   } dmi_t;

   logic [$bits(dmi_t)-1:0] dr_q = 32'hABCD;
   typedef logic [$bits(dmi_t)-1:0] dr_q_type;

   assign o = dr_q[$bits(dr_q_type)-1:0];
endmodule
