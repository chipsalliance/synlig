module dut(output logic [4:0] a);
   parameter logic [4:0] A;
   assign a = A;
endmodule // dut

module top(output logic [4:0] o);
   typedef struct packed {
      logic [1:0] a;
      logic [2:0] b;
   } struct_1;

   typedef struct packed {
      logic [2:0] a;
      logic [1:0] b;
   } struct_2;
      
   parameter struct_1 X = '{a: '1, b: '0};
   parameter struct_2 Y = '{a: '1, b: '0};

   dut #(.A(X)) u_dut(.a(o));
endmodule
