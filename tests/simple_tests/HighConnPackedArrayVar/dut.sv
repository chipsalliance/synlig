package prim_pad_wrapper_pkg;
  typedef enum logic [2:0] {
    BidirStd = 3'h0
  } pad_type_e;
  typedef logic [7:0] pad_pok_t;
endpackage : prim_pad_wrapper_pkg

module prim_pad_wrapper
  import prim_pad_wrapper_pkg::*; (input pad_pok_t pok_i, output pad_pok_t pok_o);
  assign pok_o = pok_i;
endmodule : prim_pad_wrapper

module dut
  import prim_pad_wrapper_pkg::*; 
  #(parameter logic [0:0][1:0] DioPadBank = '0) 
  (input logic clk,
   input pad_pok_t [3:0] pad_pok_i, 
   output pad_pok_t [3:0] pad_pok_o);
  
  prim_pad_wrapper u_dio_pad (
    .pok_i      ( pad_pok_i[DioPadBank[0]]   ),
    .pok_o      ( pad_pok_o[DioPadBank[0]]   )
  );
endmodule : dut
