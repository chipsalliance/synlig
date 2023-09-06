module top (input wire i, output reg o1, output reg o2);
  string s;
 initial begin
  $display("Simple display");
  $display("%d is One", 1);
  $display("String: %s", "foo");
  s = $sformatf("Value = %0d", 6);
  $display("Formatted string: %s", s);
 end
endmodule
