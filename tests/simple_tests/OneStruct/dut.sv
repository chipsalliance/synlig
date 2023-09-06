module dut (a, b);
  input a;
  output [16:0] b;

  typedef struct packed {
    logic [7:0] addr;
    logic [7:0] data;
    logic wr;
  } mem_s;

  mem_s [1:0] packed_mem;
  mem_s memArray[8];
  mem_s memMulti[10][20];

  mem_s mem;

  always @(a) begin
    if (a == 1'b0)  begin
      mem.addr = 0;
      mem.data = 0;
    end else begin
      mem.addr = 128;
      mem.data = 255;
    end
  end

  assign mem.wr = a;
  assign b[16] = mem.wr;
  assign b[15:8] = mem.data;
  assign b[7:0] = mem.addr;

endmodule
