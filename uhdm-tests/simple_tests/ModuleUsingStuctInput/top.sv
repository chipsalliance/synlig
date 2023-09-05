package ctrl_pkg; // verilog_lint: waive package-filename
  parameter int Banks = 2;
  parameter int PagesPerBank = 64;
endpackage

package pkg; // verilog_lint: waive package-filename
  parameter int unsigned NumBanks        = ctrl_pkg::Banks;
  parameter int unsigned PagesPerBank    = ctrl_pkg::PagesPerBank;
  parameter int Width = 4;
  typedef enum logic [Width-1:0] {
    true_e = 4'h6,
    false_e = 4'h9
  } enum_t;
  typedef enum logic [1:0] {
    seed_e,
    rma_e,
    none_e,
    invalid_e
  } phase_t;
  typedef struct packed {
    enum_t en;
  } region_cfg_t;
  typedef struct packed {
    phase_t   phase;
    region_cfg_t cfg;
  } region_attr_t;

endpackage

module foo(input pkg::region_attr_t DATA_REG);
endmodule

module top();
foo f(.DATA_REG(6'b111111));
endmodule
