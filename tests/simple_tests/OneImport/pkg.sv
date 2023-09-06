package my_pkg;
  typedef enum logic [5:0] {
    OPCODE_LOAD     = 6'h03,
    OPCODE_STORE    = 6'h13
  } opcode_e;

parameter int unsigned PMP_CFG_W = 2;

endpackage
