module top(output int o);
   parameter int MuBi4Width = 4;
   typedef enum  logic [MuBi4Width-1:0] {
      MuBi4Hi = 4'h5,
      MuBi4Lo = 4'hA
   } mubi4_e;

   function automatic mubi4_e mubi4_hi_value();
      return MuBi4Hi;
   endfunction : mubi4_hi_value

   assign o = int'(mubi4_hi_value());
endmodule
