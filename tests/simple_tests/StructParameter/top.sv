module top(output logic o);
   typedef struct packed {
    logic a;
  } alert_tx_t;

   parameter alert_tx_t P = '{a: 1'b1};

   assign o = P.a;
endmodule
