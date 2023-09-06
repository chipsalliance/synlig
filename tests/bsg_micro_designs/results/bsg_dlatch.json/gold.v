

module top
(
  clk_i,
  data_i,
  data_o
);

  input [15:0] data_i;
  output [15:0] data_o;
  input clk_i;

  bsg_dlatch
  wrapper
  (
    .data_i(data_i),
    .data_o(data_o),
    .clk_i(clk_i)
  );


endmodule



module bsg_dlatch
(
  clk_i,
  data_i,
  data_o
);

  input [15:0] data_i;
  output [15:0] data_o;
  input clk_i;
  wire [15:0] data_o;
  reg data_o_15_sv2v_reg,data_o_14_sv2v_reg,data_o_13_sv2v_reg,data_o_12_sv2v_reg,
  data_o_11_sv2v_reg,data_o_10_sv2v_reg,data_o_9_sv2v_reg,data_o_8_sv2v_reg,
  data_o_7_sv2v_reg,data_o_6_sv2v_reg,data_o_5_sv2v_reg,data_o_4_sv2v_reg,data_o_3_sv2v_reg,
  data_o_2_sv2v_reg,data_o_1_sv2v_reg,data_o_0_sv2v_reg;
  assign data_o[15] = data_o_15_sv2v_reg;
  assign data_o[14] = data_o_14_sv2v_reg;
  assign data_o[13] = data_o_13_sv2v_reg;
  assign data_o[12] = data_o_12_sv2v_reg;
  assign data_o[11] = data_o_11_sv2v_reg;
  assign data_o[10] = data_o_10_sv2v_reg;
  assign data_o[9] = data_o_9_sv2v_reg;
  assign data_o[8] = data_o_8_sv2v_reg;
  assign data_o[7] = data_o_7_sv2v_reg;
  assign data_o[6] = data_o_6_sv2v_reg;
  assign data_o[5] = data_o_5_sv2v_reg;
  assign data_o[4] = data_o_4_sv2v_reg;
  assign data_o[3] = data_o_3_sv2v_reg;
  assign data_o[2] = data_o_2_sv2v_reg;
  assign data_o[1] = data_o_1_sv2v_reg;
  assign data_o[0] = data_o_0_sv2v_reg;

  always @(data_i[15] or clk_i) begin
    if(clk_i) begin
      data_o_15_sv2v_reg <= data_i[15];
    end 
  end


  always @(data_i[14] or clk_i) begin
    if(clk_i) begin
      data_o_14_sv2v_reg <= data_i[14];
    end 
  end


  always @(data_i[13] or clk_i) begin
    if(clk_i) begin
      data_o_13_sv2v_reg <= data_i[13];
    end 
  end


  always @(data_i[12] or clk_i) begin
    if(clk_i) begin
      data_o_12_sv2v_reg <= data_i[12];
    end 
  end


  always @(data_i[11] or clk_i) begin
    if(clk_i) begin
      data_o_11_sv2v_reg <= data_i[11];
    end 
  end


  always @(data_i[10] or clk_i) begin
    if(clk_i) begin
      data_o_10_sv2v_reg <= data_i[10];
    end 
  end


  always @(data_i[9] or clk_i) begin
    if(clk_i) begin
      data_o_9_sv2v_reg <= data_i[9];
    end 
  end


  always @(data_i[8] or clk_i) begin
    if(clk_i) begin
      data_o_8_sv2v_reg <= data_i[8];
    end 
  end


  always @(data_i[7] or clk_i) begin
    if(clk_i) begin
      data_o_7_sv2v_reg <= data_i[7];
    end 
  end


  always @(data_i[6] or clk_i) begin
    if(clk_i) begin
      data_o_6_sv2v_reg <= data_i[6];
    end 
  end


  always @(data_i[5] or clk_i) begin
    if(clk_i) begin
      data_o_5_sv2v_reg <= data_i[5];
    end 
  end


  always @(data_i[4] or clk_i) begin
    if(clk_i) begin
      data_o_4_sv2v_reg <= data_i[4];
    end 
  end


  always @(data_i[3] or clk_i) begin
    if(clk_i) begin
      data_o_3_sv2v_reg <= data_i[3];
    end 
  end


  always @(data_i[2] or clk_i) begin
    if(clk_i) begin
      data_o_2_sv2v_reg <= data_i[2];
    end 
  end


  always @(data_i[1] or clk_i) begin
    if(clk_i) begin
      data_o_1_sv2v_reg <= data_i[1];
    end 
  end


  always @(data_i[0] or clk_i) begin
    if(clk_i) begin
      data_o_0_sv2v_reg <= data_i[0];
    end 
  end


endmodule

