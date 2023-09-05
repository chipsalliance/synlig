package kmac_pkg;
   typedef struct packed {
      logic [95:0] Prefix;
   } app_config_t;

   parameter app_config_t A = '{
      Prefix: 96'(96'h 4c52_5443_5f4d_4f52_4001_0001)
   };
endpackage : kmac_pkg

module top(output int o);
   import kmac_pkg::*;
   assign o = 32'(A.Prefix);
endmodule
