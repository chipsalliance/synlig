typedef struct packed {
  logic a;
  logic b;
} status_t;

module top (
    output status_t status_out00,
    output status_t status_out01,
    output status_t status_out10,
    output status_t status_out11
);

  status_t [1:0][1:0] group_status;

  assign group_status[0][0].a = 1'b1;
  assign group_status[0][0].b = 1'b0;
  assign status_out00 = group_status[0][0];

  assign group_status[0][1].a = 1'b1;
  assign group_status[0][1].b = 1'b0;
  assign status_out01 = group_status[0][1];

  assign group_status[1][0].a = 1'b1;
  assign group_status[1][0].b = 1'b0;
  assign status_out10 = group_status[1][0];

  assign group_status[1][1].a = 1'b1;
  assign group_status[1][1].b = 1'b0;
  assign status_out11 = group_status[1][1];

endmodule : top

