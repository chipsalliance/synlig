module top(output logic o);
   parameter int ThetaIndexX1 [3] = '{4, 1, 2};

   function automatic logic theta();
      logic [4:0][1:0] c = 10'h100;
      return c[ThetaIndexX1[0]][0];
   endfunction : theta

   assign o = theta();

   final begin
      assert(o == 1);
   end
endmodule
