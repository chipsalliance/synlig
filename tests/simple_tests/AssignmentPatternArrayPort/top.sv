module dut(input [7:0] data);

endmodule

module top();

dut d(.data('{ default: 0 }));

endmodule
