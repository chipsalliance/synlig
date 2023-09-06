interface sim_sram_if;
   parameter int W = 32;
   logic [W-1:0] start_addr = '1;
endinterface

module top(output int o);
   sim_sram_if #(.W(16)) u_sim_sram_if();
   assign o = int'(u_sim_sram_if.start_addr);
endmodule // top
