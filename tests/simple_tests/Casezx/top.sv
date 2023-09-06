module top_za(input logic [2:0] s, output logic [1:0] y); // verilog_lint: waive module-filename
always_comb
 casez (s)
  3'b1?? : y = 2'b11;
  3'b01? : y = 2'b10;
  3'b001 : y = 2'b01;
  default : y= 2'b00;
 endcase
endmodule

module top_zz(input logic [2:0] s, output logic [1:0] y); // verilog_lint: waive module-filename
always_comb
 casez (s)
  3'b1zz : y = 2'b11;
  3'b01z : y = 2'b10;
  3'b001 : y = 2'b01;
  default : y= 2'b00;
 endcase
endmodule

module top_zx(input logic [2:0] s, output logic [1:0] y); // verilog_lint: waive module-filename
always_comb
 casez (s)
  3'b1xx : y = 2'b11;
  3'b01x : y = 2'b10;
  3'b001 : y = 2'b01;
  default : y= 2'b00;
 endcase
endmodule

module top_xa(input logic [2:0] s, output logic [1:0] y); // verilog_lint: waive module-filename
always_comb
 casex (s)
  3'b1?? : y = 2'b11;
  3'b01? : y = 2'b10;
  3'b001 : y = 2'b01;
  default : y= 2'b00;
 endcase
endmodule

module top_xx(input logic [2:0] s, output logic [1:0] y); // verilog_lint: waive module-filename
always_comb
 casex (s)
  3'b1xx : y = 2'b11;
  3'b01x : y = 2'b10;
  3'b001 : y = 2'b01;
  default : y= 2'b00;
 endcase
endmodule

module top_xz(input logic [2:0] s, output logic [1:0] y); // verilog_lint: waive module-filename
always_comb
 casex (s)
  3'b1zz : y = 2'b11;
  3'b01z : y = 2'b10;
  3'b001 : y = 2'b01;
  default : y= 2'b00;
 endcase
endmodule
