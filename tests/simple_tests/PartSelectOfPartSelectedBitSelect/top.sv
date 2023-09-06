module top(output logic [5:0] o);
   logic [1:0][5:0] iccm_bank_dout_hi = 12'hABC;
   logic [1:0] iccm_rw_addr_q = 2'b10;
   
   assign o = iccm_bank_dout_hi[iccm_rw_addr_q[0:0]][5:0];
endmodule // top
