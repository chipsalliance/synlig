package flash_phy_pkg;
   parameter int DataWidth       = 64;
   parameter int GfMultCycles  = 2;
endpackage // flash_phy_pkg

module top(output logic o);
   import flash_phy_pkg::*;
   localparam int Loops = DataWidth / GfMultCycles;
   localparam int CntWidth = 1;

   int x = 1;

  if(1) begin : gen_decomposed
    assign o = x == (Loops - 31);
  end
endmodule
