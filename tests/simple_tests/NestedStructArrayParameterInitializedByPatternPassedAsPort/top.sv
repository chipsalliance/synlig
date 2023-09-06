package flash_ctrl_pkg;
   typedef struct packed {
      struct packed {
         logic q;
      } he_en;
   } mp_region_cfg_t;

   typedef struct packed {
      mp_region_cfg_t cfg;
   } data_region_attr_t;

   parameter data_region_attr_t HwDataAttr[1] = '{
     '{
         cfg: '{
                  he_en: 1'b1
               }
      }
   };
endpackage : flash_ctrl_pkg

module flash_mp_data_region_sel import flash_ctrl_pkg::*; (
   input data_region_attr_t region_attrs_i [1],
   output logic x
);
   assign x = region_attrs_i[0].cfg;
endmodule

module top(output logic o);
   import flash_ctrl_pkg::*;
   flash_mp_data_region_sel u_hw_sel (
      .region_attrs_i(HwDataAttr),
      .x(o)
   );
endmodule
