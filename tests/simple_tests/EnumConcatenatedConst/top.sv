package state_pkg;
   parameter logic [31:0] A = 32'b1;

   typedef enum logic [63:0] {
    State = {A, A}
  } state;

endpackage

module top(output logic [63:0] o);
   assign o = state_pkg::State;
endmodule // top
