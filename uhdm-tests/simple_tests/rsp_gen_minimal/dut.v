module prim_secded_64_57_enc (
  input        [56:0] data_i,
  output logic [63:0] data_o
);

  always_comb begin : p_encode
    data_o = 64'(data_i);
    data_o[57] = ^(data_o & 64'h0103FFF800007FFF);
    data_o[58] = ^(data_o & 64'h017C1FF801FF801F);
    data_o[59] = ^(data_o & 64'h01BDE1F87E0781E1);
    data_o[60] = ^(data_o & 64'h01DEEE3B8E388E22);
    data_o[61] = ^(data_o & 64'h01EF76CDB2C93244);
    data_o[62] = ^(data_o & 64'h01F7BB56D5525488);
    data_o[63] = ^(data_o & 64'h01FBDDA769A46910);
  end

endmodule : prim_secded_64_57_enc

package tlul_pkg;

  typedef enum logic [2:0] {
    AccessAck     = 3'h 0,
    AccessAckData = 3'h 1
  } tl_d_op_e;
  typedef struct packed {
    logic [7-1:0]    rsp_intg;
    logic [7-1:0]      data_intg;
  } tl_d_user_t;

  typedef struct packed {
    logic d_valid;
    tl_d_op_e d_opcode;
    logic  [2:0]    d_param;
    logic  [2-1:0]  d_size;   // Bouncing back a_size
    logic  [8-1:0]  d_source;
    logic  [1-1:0]  d_sink;
    logic  [32-1:0] d_data;
    tl_d_user_t                   d_user;
    logic                         d_error;

    logic                         a_ready;

  } tl_d2h_t;

  typedef struct packed {
    tl_d_op_e                     opcode;
    logic  [2-1:0]  size;
    logic                         error;
  } tl_d2h_rsp_intg_t;

  // extract variables used for response checking
  function automatic tl_d2h_rsp_intg_t extract_d2h_rsp_intg(tl_d2h_t tl);
    tl_d2h_rsp_intg_t payload;
    logic unused_tlul;
    unused_tlul = ^tl;
    payload.opcode = tl.d_opcode;
    payload.size   = tl.d_size;
    payload.error  = tl.d_error;
    return payload;
  endfunction // extract_d2h_rsp_intg

endpackage


module dut import tlul_pkg::*; #(
) (
  // TL-UL interface
  input  tl_d2h_t tl_i,
  output tl_d2h_t tl_o
);

  logic [7-1:0] rsp_intg;
  tl_d2h_rsp_intg_t rsp;
  logic [57-1:0] unused_payload;

  assign rsp = extract_d2h_rsp_intg(tl_i);

  prim_secded_64_57_enc u_rsp_gen (
    .data_i(57'(rsp)),
    .data_o({rsp_intg, unused_payload})
  );

  always_comb begin
    tl_o.d_user.rsp_intg = rsp_intg;
  end

endmodule // dut
