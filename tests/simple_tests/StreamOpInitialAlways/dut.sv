module dut(
  input clk,
  input [3:0] i,
  output [7:0] o1_4,
  output [7:0] o2_4,
  output [7:0] o3_4,
  output [7:0] o4_4,
  output [7:0] o5_4,
  output [7:0] o6_4,
  output [15:0] o1_8,
  output [15:0] o2_8,
  output [15:0] o3_8,
  output [15:0] o4_8,
  output [15:0] o5_8,
  output [15:0] o6_8
);

  // initial with begin...end
  initial begin
    o1_4 = {<< 2 {i, 4'h1}};
    o1_8[15:8] = {<< 2 {i[7:4], 4'h1}};
    o1_8[7:0]  = {<< 1 {i[3:0], 4'h1}};
  end

  // initial
  initial
    o2_4 = {<< 2 {i, 4'h1}};
  initial
    o2_8[15:8] = {<< 2 {i[7:4], 4'h1}};
  initial
    o2_8[7:0]  = {<< 1 {i[3:0], 4'h1}};

  // always with event and begin...end
  always @(posedge clk) begin
    o3_4 = {<< 2 {i, 4'h1}};
    o3_8[15:8] = {<< 2 {i[7:4], 4'h1}};
    o3_8[7:0]  = {<< 1 {i[3:0], 4'h1}};
  end

  // always with event
  always @(posedge clk)
    o4_4 = {<< 2 {i, 4'h1}};
  always @(posedge clk)
    o4_8[15:8] = {<< 2 {i[7:4], 4'h1}};
  always @(posedge clk)
    o4_8[7:0]  = {<< 1 {i[3:0], 4'h1}};

  // always with begin...end
  always begin
    o5_4 = {<< 2 {i, 4'h1}};
    o5_8[15:8] = {<< 2 {i[7:4], 4'h1}};
    o5_8[7:0]  = {<< 1 {i[3:0], 4'h1}};
  end

  // always
  always
    o6_4 = {<< 2 {i, 4'h1}};
  always
    o6_8[15:8] = {<< 2 {i[7:4], 4'h1}};
  always
    o6_8[7:0]  = {<< 1 {i[3:0], 4'h1}};

endmodule
