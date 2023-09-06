module top #(
  parameter  int Width = 16
) (
   output logic o
);
  localparam int ParWidth = (Width <=  26) ? 6 :
                            (Width <= 120) ? 7 : 8;

  assign o = (ParWidth == 6);

endmodule
