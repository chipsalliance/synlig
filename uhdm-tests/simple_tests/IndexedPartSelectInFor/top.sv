package my_pkg;
   parameter int Shares = 2;
   parameter int KeyWidth = 64;

   typedef struct packed {
      logic [Shares-1:0][KeyWidth-1:0] key;
   } hw_key_req_t;
endpackage // my_pkg

module top(output int o);
   import my_pkg::*;
   hw_key_req_t keymgr_key_i = 128'h123456789abcdef;
   always_comb begin : key_sideload_get
      for (int i = 0; i < 1; i++) begin
         o = keymgr_key_i.key[0][i * 32 +: 32];
      end
   end
endmodule
