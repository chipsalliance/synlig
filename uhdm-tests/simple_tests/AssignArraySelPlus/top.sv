module top (output logic [3:0] data [15:0]);

initial begin
  data[10][0 +: 4] = 4'hf;
end
endmodule
