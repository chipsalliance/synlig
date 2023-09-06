interface sw_test_status_if(output int x);
   assign x = 10;
endinterface

module top(output int o);
   sw_test_status_if u_sw(.x(o));
endmodule // top
