module top  (input logic [2:0] sel,   output logic [1:0] y);
  always_comb
    case (sel) inside
      3'b000, 3'b001, 3'b010, 3'b011 : y = 2'b01;
      [4:7] : y = 2'b10;
  endcase
endmodule : top
