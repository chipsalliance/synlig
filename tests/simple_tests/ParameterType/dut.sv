module dut(input logic clk, input logic i, output logic o);
 localparam int GW_CONFIG2[2:0] = '{default:0} ;

 assign o = i;

endmodule
