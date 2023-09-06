

module top
(
  i0,
  i1,
  o
);

  input [15:0] i0;
  input [15:0] i1;
  output [15:0] o;

  bsg_dff_gatestack
  wrapper
  (
    .i0(i0),
    .i1(i1),
    .o(o)
  );


endmodule



module bsg_dff_gatestack
(
  i0,
  i1,
  o
);

  input [15:0] i0;
  input [15:0] i1;
  output [15:0] o;
  wire [15:0] o;
  reg o_0_sv2v_reg,o_1_sv2v_reg,o_2_sv2v_reg,o_3_sv2v_reg,o_4_sv2v_reg,o_5_sv2v_reg,
  o_6_sv2v_reg,o_7_sv2v_reg,o_8_sv2v_reg,o_9_sv2v_reg,o_10_sv2v_reg,o_11_sv2v_reg,
  o_12_sv2v_reg,o_13_sv2v_reg,o_14_sv2v_reg,o_15_sv2v_reg;
  assign o[0] = o_0_sv2v_reg;
  assign o[1] = o_1_sv2v_reg;
  assign o[2] = o_2_sv2v_reg;
  assign o[3] = o_3_sv2v_reg;
  assign o[4] = o_4_sv2v_reg;
  assign o[5] = o_5_sv2v_reg;
  assign o[6] = o_6_sv2v_reg;
  assign o[7] = o_7_sv2v_reg;
  assign o[8] = o_8_sv2v_reg;
  assign o[9] = o_9_sv2v_reg;
  assign o[10] = o_10_sv2v_reg;
  assign o[11] = o_11_sv2v_reg;
  assign o[12] = o_12_sv2v_reg;
  assign o[13] = o_13_sv2v_reg;
  assign o[14] = o_14_sv2v_reg;
  assign o[15] = o_15_sv2v_reg;

  always @(posedge i1[0]) begin
    if(1'b1) begin
      o_0_sv2v_reg <= i0[0];
    end 
  end


  always @(posedge i1[1]) begin
    if(1'b1) begin
      o_1_sv2v_reg <= i0[1];
    end 
  end


  always @(posedge i1[2]) begin
    if(1'b1) begin
      o_2_sv2v_reg <= i0[2];
    end 
  end


  always @(posedge i1[3]) begin
    if(1'b1) begin
      o_3_sv2v_reg <= i0[3];
    end 
  end


  always @(posedge i1[4]) begin
    if(1'b1) begin
      o_4_sv2v_reg <= i0[4];
    end 
  end


  always @(posedge i1[5]) begin
    if(1'b1) begin
      o_5_sv2v_reg <= i0[5];
    end 
  end


  always @(posedge i1[6]) begin
    if(1'b1) begin
      o_6_sv2v_reg <= i0[6];
    end 
  end


  always @(posedge i1[7]) begin
    if(1'b1) begin
      o_7_sv2v_reg <= i0[7];
    end 
  end


  always @(posedge i1[8]) begin
    if(1'b1) begin
      o_8_sv2v_reg <= i0[8];
    end 
  end


  always @(posedge i1[9]) begin
    if(1'b1) begin
      o_9_sv2v_reg <= i0[9];
    end 
  end


  always @(posedge i1[10]) begin
    if(1'b1) begin
      o_10_sv2v_reg <= i0[10];
    end 
  end


  always @(posedge i1[11]) begin
    if(1'b1) begin
      o_11_sv2v_reg <= i0[11];
    end 
  end


  always @(posedge i1[12]) begin
    if(1'b1) begin
      o_12_sv2v_reg <= i0[12];
    end 
  end


  always @(posedge i1[13]) begin
    if(1'b1) begin
      o_13_sv2v_reg <= i0[13];
    end 
  end


  always @(posedge i1[14]) begin
    if(1'b1) begin
      o_14_sv2v_reg <= i0[14];
    end 
  end


  always @(posedge i1[15]) begin
    if(1'b1) begin
      o_15_sv2v_reg <= i0[15];
    end 
  end


endmodule

