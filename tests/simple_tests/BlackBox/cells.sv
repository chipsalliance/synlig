`celldefine
(* blackbox *)
module I_BUF #(
  parameter WEAK_KEEPER = "NONE",
  parameter DRIVE = "STRONG"
  ) (
  input logic I,
  input logic EN,
  output logic O
);

endmodule
`endcelldefine
