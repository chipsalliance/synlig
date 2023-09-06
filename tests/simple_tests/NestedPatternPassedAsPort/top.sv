package flash_ctrl_pkg;
   typedef struct packed {
      logic phase;
   } data_region_attr_t;
endpackage : flash_ctrl_pkg

module flash_mp_data_region_sel import flash_ctrl_pkg::*; (
   input data_region_attr_t region_attrs_i [1],
   output logic x
);
   assign x = region_attrs_i[0].phase;
endmodule

module top(output logic o);
   import flash_ctrl_pkg::*;
   flash_mp_data_region_sel u_hw_sel (
      .region_attrs_i(
         '{
            '{
               phase: 1'b1
             }
          }),
      .x(o)
   );
endmodule
