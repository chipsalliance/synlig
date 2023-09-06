package sw_test_status_pkg;
   typedef enum int {
      X = 10
   } my_enum_e;
endpackage

interface sw_test_status_if(output int x);
   import sw_test_status_pkg::*;
   assign x = X;
endinterface

module top(output int o);
   sw_test_status_if u_sw(.x(o));
endmodule // top
