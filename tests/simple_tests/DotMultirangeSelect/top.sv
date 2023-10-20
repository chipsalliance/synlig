
package keymgr_pkg;
   
 typedef struct packed {
    logic valid;
    logic [1:0][255:0] key;
  } hw_key_req_t;
   
endpackage

                                                        // Originally key_sideload[NumSharesKey], but sv2v inverts unpacked
                                                        // ranges in some cases, leading to formal verification failures.
module top(input keymgr_pkg::hw_key_req_t keymgr_key_i, output logic [NumRegsKey-1:0][31:0] key_sideload [NumSharesKey-1:0]);

   parameter NumRegsKey = 8;
   parameter NumSharesKey = 2;
   
  always_comb begin : key_sideload_get
    for (int s = 0; s < NumSharesKey; s++) begin
      for (int i = 0; i < NumRegsKey; i++) begin
        key_sideload[s][i] = keymgr_key_i.key[s][i * 32 +: 32];
      end
    end
  end

endmodule
