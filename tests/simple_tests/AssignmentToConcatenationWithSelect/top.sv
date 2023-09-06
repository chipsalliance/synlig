module top(output int o);
   initial begin
      o = 0;
      {o[1:0], o[2]} = 3'b111;
   end
endmodule // top
