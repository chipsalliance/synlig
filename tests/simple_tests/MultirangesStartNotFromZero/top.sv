module top();
   typedef struct packed {
      logic       v;
      logic       ready_and_rev;
      logic [66-1:0] data;
  } bp_mem_ready_and_link_t;
  logic [1-1:0][68-1:0]  mem_fwd_link_i;
  logic [1-1:0][68-1:0]  mem_rev_link_o;
  logic [1-1:0][68-1:0]  mem_dma_link_o;
  typedef enum logic[2:0] {p_e=3'd0, w_e, e_e, n_e, s_e} Dirs;
  bp_mem_ready_and_link_t [s_e:n_e][1-1:0] mem_ver_link_lo;

  assign mem_rev_link_o = mem_ver_link_lo[n_e];
  assign mem_ver_link_lo[s_e] = mem_fwd_link_i;
  assign mem_dma_link_o = mem_ver_link_lo[s_e];
   typedef struct packed {
      logic       v;
      logic       ready_and_rev;
      logic [66-1:0] data;
  } bp_io_ready_and_link_t;
  bp_io_ready_and_link_t [1-1:0][e_e:w_e] io_fwd_link_li;
  bp_io_ready_and_link_t [1-1:0][e_e:w_e] io_fwd_link_lo;
  bp_io_ready_and_link_t [1-1:0][e_e:w_e] io_rev_link_li;
  bp_io_ready_and_link_t [1-1:0][e_e:w_e] io_rev_link_lo;
  bp_io_ready_and_link_t [1-1:0][s_e:w_e] io_fwd_mesh_lo;
  bp_io_ready_and_link_t [1-1:0][s_e:w_e] io_fwd_mesh_li;
assign io_fwd_mesh_lo[0][e_e:w_e] = io_fwd_link_lo[0][e_e:w_e];
  for (genvar i = 0; i < 1; i++)
    begin : gen_cmd_link
      assign io_fwd_link_li[i][e_e:w_e] = io_fwd_mesh_li[i][e_e:w_e];
    end
endmodule
