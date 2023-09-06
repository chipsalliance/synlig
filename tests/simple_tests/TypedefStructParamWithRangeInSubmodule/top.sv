package top_pkg; // verilog_lint: waive package-filename
  parameter MpRegions = 8;

  typedef struct packed {
    logic [8:0] base;
    logic [9:0] size;
  } mp_region_cfg_t;

  typedef struct packed {
    mp_region_cfg_t [MpRegions:0] region_cfgs;
  } flash_req_t;

  parameter flash_req_t FLASH_REQ_DEFAULT = '{
    region_cfgs:   '0
  };
endpackage : top_pkg

module flash_ctrl_arb import top_pkg::*; (
);
endmodule

module top
  import top_pkg::*;
#(
);
  flash_ctrl_arb u_ctrl_arb (
  );

endmodule
