module dut();
enum logic [2:0] {e_idle, e_send_load} state_n, state_r; // verilog_lint: waive typedef-enums
endmodule

module top();
enum logic [2:0] {e_idle, e_send_load} state_n, state_r; // verilog_lint: waive typedef-enums
enum logic [3:0] {e_idle2, e_send_load2} state_n2, state_r2; // verilog_lint: waive typedef-enums
dut d();
dut d2();
endmodule
