package adc_ctrl_reg_pkg;
  typedef enum int {
    ADC_CTRL_INTR_STATE,
    ADC_CTRL_INTR_ENABLE
  } adc_ctrl_id_e;
endpackage

import adc_ctrl_reg_pkg::* ;

module M();
  import adc_ctrl_reg_pkg::* ;
endmodule

module top ();
  M m1();
endmodule

