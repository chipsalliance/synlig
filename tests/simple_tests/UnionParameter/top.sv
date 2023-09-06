package some_package; // verilog_lint: waive package-filename
typedef union packed {
  logic [3:0] bunn1_t;
  logic [3:0] bunn2_t;
} flimish_giant;

parameter flimish_giant LovingHome = '{default: 1};
endpackage : some_package
