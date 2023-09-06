package flash_phy_pkg; // verilog_lint: waive package-filename
parameter int FullDataWidth = 10;
typedef struct packed {
  logic ack;
  logic done;
  logic [FullDataWidth-1:0] rdata;
} flash_phy_prim_flash_rsp_t;
endpackage
module dut(output flash_phy_pkg::flash_phy_prim_flash_rsp_t [9:0] flash_rsp_o);
assign flash_rsp_o[0].ack = 1'b1;
endmodule
module top();
dut d();
endmodule
