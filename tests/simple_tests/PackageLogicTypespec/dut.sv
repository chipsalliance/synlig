package my_pkg;

  typedef logic [31:0] my_type_t;

endpackage

module dut (input my_pkg::my_type_t my_in, output logic [31:0] my_out);
  assign my_out = my_in;
endmodule
