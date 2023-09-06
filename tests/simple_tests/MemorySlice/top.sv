module top #(parameter N=8) // verilog_lint: waive explicit-parameter-storage-type
   (input logic ck, input logic [3:0] sin,
    output logic [3:0] sout);
logic [3:0] mem [N-1:0]; // verilog_lint: waive unpacked-dimensions-range-ordering
assign sout = mem[N-1];
always_ff @ (posedge ck)
begin
  mem [N-1:1] <= mem [N-2:0];
  mem [0] <= sin;
end
endmodule
