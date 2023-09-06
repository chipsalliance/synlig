interface sim_sram_if(input int x);   
   int start_addr = x;
endinterface // sim_sram_if

module top(output int o);
   sim_sram_if u_sim_sram_if(10);
   assign o = u_sim_sram_if.start_addr;
endmodule // top
