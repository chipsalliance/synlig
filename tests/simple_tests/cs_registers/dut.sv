package ibex_pkg;
typedef enum logic[11:0] {
  // Machine information
  CSR_MHARTID   = 12'hF14,

  // Machine trap setup
  CSR_MSTATUS   = 12'h300,
  CSR_MISA      = 12'h301,
  CSR_MIE       = 12'h304,
  CSR_MTVEC     = 12'h305,

  // Machine trap handling
  CSR_MSCRATCH  = 12'h340,
  CSR_MEPC      = 12'h341,
  CSR_MCAUSE    = 12'h342,
  CSR_MTVAL     = 12'h343,
  CSR_MIP       = 12'h344,

  // Physical memory protection
  CSR_PMPCFG0   = 12'h3A0,
  CSR_PMPCFG1   = 12'h3A1,
  CSR_PMPCFG2   = 12'h3A2,
  CSR_PMPCFG3   = 12'h3A3,
  CSR_PMPADDR0  = 12'h3B0,
  CSR_PMPADDR1  = 12'h3B1,
  CSR_PMPADDR2  = 12'h3B2,
  CSR_PMPADDR3  = 12'h3B3,
  CSR_PMPADDR4  = 12'h3B4,
  CSR_PMPADDR5  = 12'h3B5,
  CSR_PMPADDR6  = 12'h3B6,
  CSR_PMPADDR7  = 12'h3B7,
  CSR_PMPADDR8  = 12'h3B8,
  CSR_PMPADDR9  = 12'h3B9,
  CSR_PMPADDR10 = 12'h3BA,
  CSR_PMPADDR11 = 12'h3BB,
  CSR_PMPADDR12 = 12'h3BC,
  CSR_PMPADDR13 = 12'h3BD,
  CSR_PMPADDR14 = 12'h3BE,
  CSR_PMPADDR15 = 12'h3BF,

  // Debug trigger
  CSR_TSELECT   = 12'h7A0,
  CSR_TDATA1    = 12'h7A1,
  CSR_TDATA2    = 12'h7A2,
  CSR_TDATA3    = 12'h7A3,
  CSR_MCONTEXT  = 12'h7A8,
  CSR_SCONTEXT  = 12'h7AA,

  // Debug/trace
  CSR_DCSR      = 12'h7b0,
  CSR_DPC       = 12'h7b1,

  // Debug
  CSR_DSCRATCH0 = 12'h7b2, // optional
  CSR_DSCRATCH1 = 12'h7b3, // optional

  // Machine Counter/Timers
  CSR_MCOUNTINHIBIT  = 12'h320,
  CSR_MHPMEVENT3     = 12'h323,
  CSR_MHPMEVENT4     = 12'h324,
  CSR_MHPMEVENT5     = 12'h325,
  CSR_MHPMEVENT6     = 12'h326,
  CSR_MHPMEVENT7     = 12'h327,
  CSR_MHPMEVENT8     = 12'h328,
  CSR_MHPMEVENT9     = 12'h329,
  CSR_MHPMEVENT10    = 12'h32A,
  CSR_MHPMEVENT11    = 12'h32B,
  CSR_MHPMEVENT12    = 12'h32C,
  CSR_MHPMEVENT13    = 12'h32D,
  CSR_MHPMEVENT14    = 12'h32E,
  CSR_MHPMEVENT15    = 12'h32F,
  CSR_MHPMEVENT16    = 12'h330,
  CSR_MHPMEVENT17    = 12'h331,
  CSR_MHPMEVENT18    = 12'h332,
  CSR_MHPMEVENT19    = 12'h333,
  CSR_MHPMEVENT20    = 12'h334,
  CSR_MHPMEVENT21    = 12'h335,
  CSR_MHPMEVENT22    = 12'h336,
  CSR_MHPMEVENT23    = 12'h337,
  CSR_MHPMEVENT24    = 12'h338,
  CSR_MHPMEVENT25    = 12'h339,
  CSR_MHPMEVENT26    = 12'h33A,
  CSR_MHPMEVENT27    = 12'h33B,
  CSR_MHPMEVENT28    = 12'h33C,
  CSR_MHPMEVENT29    = 12'h33D,
  CSR_MHPMEVENT30    = 12'h33E,
  CSR_MHPMEVENT31    = 12'h33F,
  CSR_MCYCLE         = 12'hB00,
  CSR_MINSTRET       = 12'hB02,
  CSR_MHPMCOUNTER3   = 12'hB03,
  CSR_MHPMCOUNTER4   = 12'hB04,
  CSR_MHPMCOUNTER5   = 12'hB05,
  CSR_MHPMCOUNTER6   = 12'hB06,
  CSR_MHPMCOUNTER7   = 12'hB07,
  CSR_MHPMCOUNTER8   = 12'hB08,
  CSR_MHPMCOUNTER9   = 12'hB09,
  CSR_MHPMCOUNTER10  = 12'hB0A,
  CSR_MHPMCOUNTER11  = 12'hB0B,
  CSR_MHPMCOUNTER12  = 12'hB0C,
  CSR_MHPMCOUNTER13  = 12'hB0D,
  CSR_MHPMCOUNTER14  = 12'hB0E,
  CSR_MHPMCOUNTER15  = 12'hB0F,
  CSR_MHPMCOUNTER16  = 12'hB10,
  CSR_MHPMCOUNTER17  = 12'hB11,
  CSR_MHPMCOUNTER18  = 12'hB12,
  CSR_MHPMCOUNTER19  = 12'hB13,
  CSR_MHPMCOUNTER20  = 12'hB14,
  CSR_MHPMCOUNTER21  = 12'hB15,
  CSR_MHPMCOUNTER22  = 12'hB16,
  CSR_MHPMCOUNTER23  = 12'hB17,
  CSR_MHPMCOUNTER24  = 12'hB18,
  CSR_MHPMCOUNTER25  = 12'hB19,
  CSR_MHPMCOUNTER26  = 12'hB1A,
  CSR_MHPMCOUNTER27  = 12'hB1B,
  CSR_MHPMCOUNTER28  = 12'hB1C,
  CSR_MHPMCOUNTER29  = 12'hB1D,
  CSR_MHPMCOUNTER30  = 12'hB1E,
  CSR_MHPMCOUNTER31  = 12'hB1F,
  CSR_MCYCLEH        = 12'hB80,
  CSR_MINSTRETH      = 12'hB82,
  CSR_MHPMCOUNTER3H  = 12'hB83,
  CSR_MHPMCOUNTER4H  = 12'hB84,
  CSR_MHPMCOUNTER5H  = 12'hB85,
  CSR_MHPMCOUNTER6H  = 12'hB86,
  CSR_MHPMCOUNTER7H  = 12'hB87,
  CSR_MHPMCOUNTER8H  = 12'hB88,
  CSR_MHPMCOUNTER9H  = 12'hB89,
  CSR_MHPMCOUNTER10H = 12'hB8A,
  CSR_MHPMCOUNTER11H = 12'hB8B,
  CSR_MHPMCOUNTER12H = 12'hB8C,
  CSR_MHPMCOUNTER13H = 12'hB8D,
  CSR_MHPMCOUNTER14H = 12'hB8E,
  CSR_MHPMCOUNTER15H = 12'hB8F,
  CSR_MHPMCOUNTER16H = 12'hB90,
  CSR_MHPMCOUNTER17H = 12'hB91,
  CSR_MHPMCOUNTER18H = 12'hB92,
  CSR_MHPMCOUNTER19H = 12'hB93,
  CSR_MHPMCOUNTER20H = 12'hB94,
  CSR_MHPMCOUNTER21H = 12'hB95,
  CSR_MHPMCOUNTER22H = 12'hB96,
  CSR_MHPMCOUNTER23H = 12'hB97,
  CSR_MHPMCOUNTER24H = 12'hB98,
  CSR_MHPMCOUNTER25H = 12'hB99,
  CSR_MHPMCOUNTER26H = 12'hB9A,
  CSR_MHPMCOUNTER27H = 12'hB9B,
  CSR_MHPMCOUNTER28H = 12'hB9C,
  CSR_MHPMCOUNTER29H = 12'hB9D,
  CSR_MHPMCOUNTER30H = 12'hB9E,
  CSR_MHPMCOUNTER31H = 12'hB9F,
  CSR_CPUCTRL        = 12'h7C0,
  CSR_SECURESEED     = 12'h7C1,
  CSR_END            = 12'hFFE,
  DUMMY_CSR_SETMHPMEVENT31 = 12'hFFF
} csr_num_e;
// CSR status bits
parameter int unsigned CSR_MSTATUS_MIE_BIT      = 3;
parameter int unsigned CSR_MSTATUS_MPIE_BIT     = 7;
parameter int unsigned CSR_MSTATUS_MPP_BIT_LOW  = 11;
parameter int unsigned CSR_MSTATUS_MPP_BIT_HIGH = 12;
parameter int unsigned CSR_MSTATUS_MPRV_BIT     = 17;
parameter int unsigned CSR_MSTATUS_TW_BIT       = 21;

// CSR interrupt pending/enable bits
parameter int unsigned CSR_MSIX_BIT      = 3;
parameter int unsigned CSR_MTIX_BIT      = 7;
parameter int unsigned CSR_MEIX_BIT      = 11;
parameter int unsigned CSR_MFIX_BIT_LOW  = 16;
parameter int unsigned CSR_MFIX_BIT_HIGH = 30;

// Privileged mode
typedef enum logic[1:0] {
  PRIV_LVL_M = 2'b11,
  PRIV_LVL_H = 2'b10,
  PRIV_LVL_S = 2'b01,
  PRIV_LVL_U = 2'b00
} priv_lvl_e;

parameter logic [1:0] CSR_MISA_MXL = 2'd1;
// Interrupt requests
typedef struct packed {
  logic        irq_software;
  logic        irq_timer;
  logic        irq_external;
  logic [14:0] irq_fast; // 15 fast interrupts,
                         // one interrupt is reserved for NMI (not visible through mip/mie)
} irqs_t;

parameter int unsigned PMP_MAX_REGIONS      = 16;
parameter int unsigned PMP_CFG_W            = 8;

// Constants for the dcsr.xdebugver fields
typedef enum logic[3:0] {
   XDEBUGVER_NO     = 4'd0, // no external debug support
   XDEBUGVER_STD    = 4'd4, // external debug according to RISC-V debug spec
   XDEBUGVER_NONSTD = 4'd15 // debug not conforming to RISC-V debug spec
} x_debug_ver_e;

// Debug cause
typedef enum logic [2:0] {
  DBG_CAUSE_NONE    = 3'h0,
  DBG_CAUSE_EBREAK  = 3'h1,
  DBG_CAUSE_TRIGGER = 3'h2,
  DBG_CAUSE_HALTREQ = 3'h3,
  DBG_CAUSE_STEP    = 3'h4
} dbg_cause_e;

endpackage

module dut(input clk);
import ibex_pkg::*;

typedef struct packed {
  logic      mie;
  logic      mpie;
  priv_lvl_e mpp;
  logic      mprv;
  logic      tw;
} status_t;

typedef struct packed {
    x_debug_ver_e xdebugver;
    logic [11:0]  zero2;
    logic         ebreakm;
    logic         zero1;
    logic         ebreaks;
    logic         ebreaku;
    logic         stepie;
    logic         stopcount;
    logic         stoptime;
    dbg_cause_e   cause;
    logic         zero0;
    logic         mprven;
    logic         nmip;
    logic         step;
    priv_lvl_e    prv;
} dcsr_t;

dcsr_t       dcsr_q;
assign dcsr_q.xdebugver = XDEBUGVER_NO;
assign dcsr_q.zero2 = 12'b000000000000;
assign dcsr_q.ebreakm = 1'b1;
assign dcsr_q.zero1 = 1'b0;
assign dcsr_q.ebreaks = 1'b1;
assign dcsr_q.ebreaku = 1'b0;
assign dcsr_q.stepie = 1'b0;
assign dcsr_q.stopcount = 1'b1;
assign dcsr_q.stoptime = 1'b1;
assign dcsr_q.cause = DBG_CAUSE_STEP;
assign dcsr_q.zero0 = 1'b0;
assign dcsr_q.mprven = 1'b1;
assign dcsr_q.nmip = 1'b1;
assign dcsr_q.step = 1'b1;
assign dcsr_q.prv = PRIV_LVL_M;

parameter bit          RV32M             = 1;
parameter bit          RV32E             = 0;

localparam logic [31:0] MISA_VALUE =
    (0                 <<  0)  // A - Atomic Instructions extension
  | (1                 <<  2)  // C - Compressed extension
  | (0                 <<  3)  // D - Double precision floating-point extension
  | (32'(RV32E)        <<  4)  // E - RV32E base ISA
  | (0                 <<  5)  // F - Single precision floating-point extension
  | (32'(!RV32E)       <<  8)  // I - RV32I/64I/128I base ISA
  | (32'(RV32M)        << 12)  // M - Integer Multiply/Divide extension
  | (0                 << 13)  // N - User level interrupts supported
  | (0                 << 18)  // S - Supervisor mode implemented
  | (1                 << 20)  // U - User mode implemented
  | (0                 << 23)  // X - Non-standard extensions present
  | (32'(CSR_MISA_MXL) << 30); // M-XLEN

localparam logic [31:0] MISA_VALUE_RESULT = 32'b01000000000100000001000100000100;

csr_num_e   csr_addr_i;
status_t     mstatus_q;
irqs_t       mie_q;
irqs_t       mip;

assign mie_q.irq_software = 1'b1;
assign mie_q.irq_timer    = 1'b1;
assign mie_q.irq_external = 1'b1;
assign mie_q.irq_fast     = 15'b111111111111111;

assign mip.irq_software = 1'b1;
assign mip.irq_timer    = 1'b1;
assign mip.irq_external = 1'b1;
assign mip.irq_fast     = 15'b111111111111111;

assign mstatus_q.mie  = 1'b1;
assign mstatus_q.mpie = 1'b1;
assign mstatus_q.mpp  = PRIV_LVL_M;
assign mstatus_q.mprv = 1'b1;
assign mstatus_q.tw   = 1'b1;


logic [31:0] csr_rdata_int;
logic [31:0] hart_id_i;
assign hart_id_i = 32'h11111111;
logic        illegal_csr;
logic  [5:0] mcause_q;
assign mcause_q = 6'b111111;
logic        debug_mode_i;
assign debug_mode_i = 1'b1;

logic [PMP_MAX_REGIONS-1:0][31:0]                 pmp_addr_rdata;
logic [PMP_MAX_REGIONS-1:0][PMP_CFG_W-1:0]        pmp_cfg_rdata;

assign pmp_cfg_rdata[0] = 8'b00000000;
assign pmp_cfg_rdata[1] = 8'b11111111;
assign pmp_cfg_rdata[2] = 8'b00000000;
assign pmp_cfg_rdata[3] = 8'b11111111;
assign pmp_cfg_rdata[15] = 8'b10101010;

logic [31:0][31:0] mhpmevent;
logic  [4:0] mhpmcounter_idx;

assign mhpmevent[0] = 32'h11111111;
assign mhpmevent[1] = 32'h00001111;
assign mhpmevent[2] = 32'h11111111;
assign mhpmevent[3] = 32'h00001111;
assign mhpmevent[31] = 32'h00000000;

always @(posedge clk) begin
assert(pmp_cfg_rdata[0] == 8'b00000000);
assert(pmp_cfg_rdata[1] == 8'b11111111);
assert(pmp_cfg_rdata[2] == 8'b00000000);
assert(pmp_cfg_rdata[3] == 8'b11111111);

  csr_rdata_int = '0;
  illegal_csr   = 1'b0;

  unique case (csr_addr_i)
    CSR_MHARTID: begin
      csr_rdata_int = hart_id_i;
      csr_addr_i = CSR_MSTATUS;
      assert(csr_rdata_int == hart_id_i);
      end
    CSR_MSTATUS: begin
      csr_rdata_int                                                   = '0;
      csr_rdata_int[CSR_MSTATUS_MIE_BIT]                              = mstatus_q.mie;
      csr_rdata_int[CSR_MSTATUS_MPIE_BIT]                             = mstatus_q.mpie;
      csr_rdata_int[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] = mstatus_q.mpp;
      csr_rdata_int[CSR_MSTATUS_MPRV_BIT]                             = mstatus_q.mprv;
      csr_rdata_int[CSR_MSTATUS_TW_BIT]                               = mstatus_q.tw;
      csr_addr_i = CSR_MISA;
      assert(csr_rdata_int[CSR_MSTATUS_MIE_BIT] == mstatus_q.mie);
      assert(csr_rdata_int[CSR_MSTATUS_MPIE_BIT] == mstatus_q.mpie);
      assert(csr_rdata_int[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] == mstatus_q.mpp);
      assert(csr_rdata_int[CSR_MSTATUS_MPRV_BIT] == mstatus_q.mprv);
      assert(csr_rdata_int[CSR_MSTATUS_TW_BIT] == mstatus_q.tw);
      end
    CSR_MISA: begin
      csr_rdata_int = MISA_VALUE;
      csr_addr_i = CSR_MIE;
      assert(csr_rdata_int == MISA_VALUE);
      assert(MISA_VALUE == MISA_VALUE_RESULT);
      end
    CSR_MIE: begin
      csr_rdata_int                                     = '0;
      csr_rdata_int[CSR_MSIX_BIT]                       = mie_q.irq_software;
      csr_rdata_int[CSR_MTIX_BIT]                       = mie_q.irq_timer;
      csr_rdata_int[CSR_MEIX_BIT]                       = mie_q.irq_external;
      csr_rdata_int[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW] = mie_q.irq_fast;
      csr_addr_i = CSR_MCAUSE;
      assert(csr_rdata_int[CSR_MSIX_BIT] == mie_q.irq_software);
      assert(csr_rdata_int[CSR_MTIX_BIT] == mie_q.irq_timer);
      assert(csr_rdata_int[CSR_MEIX_BIT] == mie_q.irq_external);
      assert(csr_rdata_int[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW] == mie_q.irq_fast);
      end
    CSR_MCAUSE: begin
      csr_rdata_int = {mcause_q[5], 26'b0, mcause_q[4:0]};
      csr_addr_i = CSR_MIP;
      assert(csr_rdata_int == 32'b10000000000000000000000000011111);
      end
    CSR_MIP: begin
      csr_rdata_int                                     = '0;
      csr_rdata_int[CSR_MSIX_BIT]                       = mip.irq_software;
      csr_rdata_int[CSR_MTIX_BIT]                       = mip.irq_timer;
      csr_rdata_int[CSR_MEIX_BIT]                       = mip.irq_external;
      csr_rdata_int[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW] = mip.irq_fast;
      csr_addr_i = CSR_PMPCFG0;
      assert(csr_rdata_int[CSR_MSIX_BIT] == mip.irq_software);
      assert(csr_rdata_int[CSR_MTIX_BIT] == mip.irq_timer);
      assert(csr_rdata_int[CSR_MEIX_BIT] == mip.irq_external);
      assert(csr_rdata_int[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW] == mip.irq_fast);
    end
    CSR_PMPCFG0: begin
      csr_rdata_int = {pmp_cfg_rdata[3],  pmp_cfg_rdata[2], pmp_cfg_rdata[1],  pmp_cfg_rdata[0]};
      csr_addr_i = CSR_PMPADDR15;
      assert(csr_rdata_int == 32'b11111111000000001111111100000000);
      end
    CSR_PMPADDR15: begin
      csr_rdata_int = pmp_addr_rdata[15];
      csr_addr_i = CSR_DCSR;
      assert(csr_rdata_int == pmp_addr_rdata[15]);
      end
    CSR_DCSR: begin
      csr_rdata_int = dcsr_q;
      illegal_csr = ~debug_mode_i;
      csr_addr_i = CSR_MHPMEVENT3;
      mhpmcounter_idx = 5'd3;
      assert(mhpmcounter_idx == 5'b00011);
      assert(mhpmevent[mhpmcounter_idx] == 32'h00001111);
      assert(csr_rdata_int == dcsr_q);
      assert(dcsr_q == 32'b00000000000000001010011100011111);
      assert(csr_rdata_int == 32'b00000000000000001010011100011111);
      assert(illegal_csr == 1'b0);
      end
    CSR_MHPMEVENT3,
       CSR_MHPMEVENT4,  CSR_MHPMEVENT5,  CSR_MHPMEVENT6,  CSR_MHPMEVENT7,
       CSR_MHPMEVENT8,  CSR_MHPMEVENT9,  CSR_MHPMEVENT10, CSR_MHPMEVENT11,
       CSR_MHPMEVENT12, CSR_MHPMEVENT13, CSR_MHPMEVENT14, CSR_MHPMEVENT15,
       CSR_MHPMEVENT16, CSR_MHPMEVENT17, CSR_MHPMEVENT18, CSR_MHPMEVENT19,
       CSR_MHPMEVENT20, CSR_MHPMEVENT21, CSR_MHPMEVENT22, CSR_MHPMEVENT23,
       CSR_MHPMEVENT24, CSR_MHPMEVENT25, CSR_MHPMEVENT26, CSR_MHPMEVENT27,
       CSR_MHPMEVENT28, CSR_MHPMEVENT29, CSR_MHPMEVENT30, CSR_MHPMEVENT31: begin
         csr_rdata_int = mhpmevent[mhpmcounter_idx];
         assert(csr_rdata_int == mhpmevent[mhpmcounter_idx]);
         csr_addr_i = DUMMY_CSR_SETMHPMEVENT31;
       end
    DUMMY_CSR_SETMHPMEVENT31: begin
      if (mhpmcounter_idx != 5'd31) begin
        csr_addr_i = CSR_MHPMEVENT31;
      end else begin
        csr_addr_i = CSR_END;
      end
      mhpmcounter_idx = 5'd31;
      assert(mhpmcounter_idx == 5'b11111);
      assert(mhpmevent[mhpmcounter_idx] == 32'h00000000);
    end

    default: begin
      illegal_csr = 1'b1;
      csr_addr_i = CSR_MHARTID;
      end
  endcase
end

endmodule
