package ibex_pkg;
typedef enum logic [1:0] {
  PMP_MODE_OFF   = 2'b00,
  PMP_MODE_TOR   = 2'b01,
  PMP_MODE_NA4   = 2'b10,
  PMP_MODE_NAPOT = 2'b11
} pmp_cfg_mode_e;
typedef struct packed {
  logic          lock;
  pmp_cfg_mode_e mode;
  logic          exec;
  logic          write;
  logic          read;
} pmp_cfg_t;

typedef enum logic [1:0] {
  PMP_ACC_EXEC    = 2'b00,
  PMP_ACC_WRITE   = 2'b01,
  PMP_ACC_READ    = 2'b10
} pmp_req_e;

typedef enum logic[1:0] {
  PRIV_LVL_M = 2'b11,
  PRIV_LVL_H = 2'b10,
  PRIV_LVL_S = 2'b01,
  PRIV_LVL_U = 2'b00
} priv_lvl_e;

endpackage

module dut();
// Adapted from ibex_pmp.sv
import ibex_pkg::*;

parameter int unsigned PMPGranularity = 0;
parameter int unsigned PMPNumChan     = 2;
parameter int unsigned PMPNumRegions  = 4;

logic                                       pmp_req_err_o     [PMPNumChan];
ibex_pkg::priv_lvl_e                        priv_mode_i       [PMPNumChan];
ibex_pkg::pmp_req_e                         pmp_req_type_i    [PMPNumChan];
logic [33:0]                                pmp_req_addr_i    [PMPNumChan];
ibex_pkg::pmp_cfg_t                         csr_pmp_cfg_i     [PMPNumRegions];
logic [33:0]                                csr_pmp_addr_i    [PMPNumRegions];
logic [33:0]                                region_start_addr [PMPNumRegions];
logic [33:PMPGranularity+2]                 region_addr_mask  [PMPNumRegions];
logic [PMPNumChan-1:0][PMPNumRegions-1:0]   region_match_gt;
logic [PMPNumChan-1:0][PMPNumRegions-1:0]   region_match_lt;
logic [PMPNumChan-1:0][PMPNumRegions-1:0]   region_match_eq;
logic [PMPNumChan-1:0][PMPNumRegions-1:0]   region_match_all;
logic [PMPNumChan-1:0][PMPNumRegions-1:0]   region_perm_check;
logic [PMPNumChan-1:0]                      access_fault;

assign csr_pmp_cfg_i[0].lock  = 1'b0;
assign csr_pmp_cfg_i[0].mode  = PMP_MODE_TOR;
assign csr_pmp_cfg_i[0].exec  = 1'b0;
assign csr_pmp_cfg_i[0].write = 1'b0;
assign csr_pmp_cfg_i[0].read  = 1'b0;
assign csr_pmp_addr_i[0] = 34'h000000000;
assign pmp_req_type_i[0] = PMP_ACC_EXEC;

assign csr_pmp_cfg_i[1].lock  = 1'b1;
assign csr_pmp_cfg_i[1].mode  = PMP_MODE_NA4;
assign csr_pmp_cfg_i[1].exec  = 1'b1;
assign csr_pmp_cfg_i[1].write = 1'b1;
assign csr_pmp_cfg_i[1].read  = 1'b1;
assign csr_pmp_addr_i[1] = 34'h111111111;
assign pmp_req_type_i[1] = PMP_ACC_EXEC;

assign csr_pmp_cfg_i[2].lock  = 1'b1;
assign csr_pmp_cfg_i[2].mode  = PMP_MODE_NAPOT;
assign csr_pmp_cfg_i[2].exec  = 1'b1;
assign csr_pmp_cfg_i[2].write = 1'b1;
assign csr_pmp_cfg_i[2].read  = 1'b1;
assign csr_pmp_addr_i[2] = 34'h111111111;

assign csr_pmp_cfg_i[3].lock  = 1'b1;
assign csr_pmp_cfg_i[3].mode  = PMP_MODE_TOR;
assign csr_pmp_cfg_i[3].exec  = 1'b1;
assign csr_pmp_cfg_i[3].write = 1'b1;
assign csr_pmp_cfg_i[3].read  = 1'b1;
assign csr_pmp_addr_i[3] = 34'h111111111;


assign pmp_req_addr_i[0] = 34'h000000000;
assign pmp_req_addr_i[1] = 34'h111111111;

assign priv_mode_i[0] = PRIV_LVL_M;
assign priv_mode_i[1] = PRIV_LVL_H;
for (genvar r = 0; r < PMPNumRegions; r++) begin : g_addr_exp1
  assign region_start_addr[r] = (csr_pmp_cfg_i[r].mode == PMP_MODE_TOR) ? 34'h000000000 : csr_pmp_addr_i[r];
end

for (genvar r = 0; r < PMPNumRegions; r++) begin : g_addr_exp2
  if (r == 0) begin : g_entry0
    assign region_start_addr[r] = (csr_pmp_cfg_i[r].mode == PMP_MODE_TOR) ? 34'h000000000 :
                                                                            csr_pmp_addr_i[r];
  end else begin : g_oth
    assign region_start_addr[r] = (csr_pmp_cfg_i[r].mode == PMP_MODE_TOR) ? csr_pmp_addr_i[r-1] :
                                                                            csr_pmp_addr_i[r];
  end
  for (genvar b = PMPGranularity+2; b < 34; b++) begin : g_bitmask
    if (b == PMPGranularity+2) begin : g_bit0
      assign region_addr_mask[r][b] = (csr_pmp_cfg_i[r].mode != PMP_MODE_NAPOT);
    end else begin : g_others
      assign region_addr_mask[r][b] = (csr_pmp_cfg_i[r].mode != PMP_MODE_NAPOT) |
                                      ~&csr_pmp_addr_i[r][b-1:PMPGranularity+2];
    end
  end
end

for (genvar c = 0; c < PMPNumChan; c++) begin : g_access_check
  for (genvar r = 0; r < PMPNumRegions; r++) begin : g_regions
    assign region_match_eq[c][r] = (pmp_req_addr_i[c][33:PMPGranularity+2] &
                                    region_addr_mask[r]) ==
                                   (region_start_addr[r][33:PMPGranularity+2] &
                                    region_addr_mask[r]);
    assign region_match_gt[c][r] = pmp_req_addr_i[c][33:PMPGranularity+2] >
                                   region_start_addr[r][33:PMPGranularity+2];
    assign region_match_lt[c][r] = pmp_req_addr_i[c][33:PMPGranularity+2] <
                                   csr_pmp_addr_i[r][33:PMPGranularity+2];

    always_comb begin
      region_match_all[c][r] = 1'b0;
      unique case (csr_pmp_cfg_i[r].mode)
        PMP_MODE_OFF   : region_match_all[c][r] = 1'b0;
        PMP_MODE_NA4   : region_match_all[c][r] = region_match_eq[c][r];
        PMP_MODE_NAPOT : region_match_all[c][r] = region_match_eq[c][r];
        PMP_MODE_TOR   : begin
          region_match_all[c][r] = (region_match_eq[c][r] | region_match_gt[c][r]) &
                                   region_match_lt[c][r];
        end
        default        : region_match_all[c][r] = 1'b0;
      endcase
    end

    // Check specific required permissions
    assign region_perm_check[c][r] =
        ((pmp_req_type_i[c] == PMP_ACC_EXEC)  & csr_pmp_cfg_i[r].exec) |
        ((pmp_req_type_i[c] == PMP_ACC_WRITE) & csr_pmp_cfg_i[r].write) |
        ((pmp_req_type_i[c] == PMP_ACC_READ)  & csr_pmp_cfg_i[r].read);
  end

  // Access fault determination / prioritization
  always_comb begin
    // Default is allow for M-mode, deny for other modes
    access_fault[c] = (priv_mode_i[c] != PRIV_LVL_M);

    // PMP entries are statically prioritized, from 0 to N-1
    // The lowest-numbered PMP entry which matches an address determines accessability
    for (int r = PMPNumRegions-1; r >= 0; r--) begin
      if (region_match_all[c][r]) begin
        access_fault[c] = (priv_mode_i[c] == PRIV_LVL_M) ?
            // For M-mode, any region which matches with the L-bit clear, or with sufficient
            // access permissions will be allowed
            (csr_pmp_cfg_i[r].lock & ~region_perm_check[c][r]) :
            // For other modes, the lock bit doesn't matter
            ~region_perm_check[c][r];
      end
    end
  end

  assign pmp_req_err_o[c] = access_fault[c];
end

always_comb begin
  assert(1'b0          == csr_pmp_cfg_i[0].lock);
  assert(PMP_MODE_TOR  == csr_pmp_cfg_i[0].mode);
  assert(1'b0          == csr_pmp_cfg_i[0].exec);
  assert(1'b0          == csr_pmp_cfg_i[0].write);
  assert(1'b0          == csr_pmp_cfg_i[0].read);
  assert(6'b001000     == csr_pmp_cfg_i[0]);
  assert(34'h000000000 == region_start_addr[0]);

  assert(1'b1             == csr_pmp_cfg_i[1].lock);
  assert(PMP_MODE_NA4     == csr_pmp_cfg_i[1].mode);
  assert(1'b1             == csr_pmp_cfg_i[1].exec);
  assert(1'b1             == csr_pmp_cfg_i[1].write);
  assert(1'b1             == csr_pmp_cfg_i[1].read);
  assert(6'b110111        == csr_pmp_cfg_i[1]);
  assert(csr_pmp_addr_i[1] == region_start_addr[1]);

  assert(csr_pmp_cfg_i[2].mode == PMP_MODE_NAPOT);
  assert(region_addr_mask[2][2] == 1'b0);
  assert(region_addr_mask[2][3] == 1'b1);
  assert(csr_pmp_cfg_i[3].mode == PMP_MODE_TOR);
  assert(region_addr_mask[3][2] == 1'b1);
  assert(region_addr_mask[3][3] == 1'b1);

  assert(region_match_eq[0][0] == 1'b1);
  assert(region_match_gt[0][0] == 1'b0);
  assert(region_match_lt[0][0] == 1'b0);

  assert(region_match_eq[0][1] == 1'b0);
  assert(region_match_gt[0][1] == 1'b0);
  assert(region_match_lt[0][1] == 1'b1);

  assert(region_match_eq[1][0] == 1'b0);
  assert(region_match_gt[1][0] == 1'b1);
  assert(region_match_lt[1][0] == 1'b0);

  assert(region_match_all[0][0] == 1'b0);
  assert(region_match_all[0][1] == region_match_eq[0][1]);
  assert(region_match_all[1][0] == 1'b0);
  assert(region_match_all[1][1] == region_match_eq[1][1]);

  assert(region_perm_check[0][0] == 1'b0);
  assert(region_perm_check[1][0] == 1'b0);
  assert(region_perm_check[1][1] == 1'b1);
  assert(region_perm_check[0][1] == 1'b1);

  assert(priv_mode_i[0] == PRIV_LVL_M);
  assert(priv_mode_i[1] == PRIV_LVL_H);

  assert(region_match_all[1][1] == 1'b1);

  assert(access_fault[0] == 1'b0);
  assert(access_fault[1] == ~region_perm_check[1][1]);
end
endmodule
