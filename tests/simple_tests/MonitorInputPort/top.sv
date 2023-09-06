module top(input int a);
   initial begin
      $monitor("Input port has value %d", a);
   end
endmodule
