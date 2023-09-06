class foo;
  bit [3:0] addr;
  function void set (bit [3:0] addr);
  begin : body
    this.addr = addr;
  end : body
  endfunction
endclass

module top(a, o);
input a;
output o;

wire [3:0] a;
reg [3:0] o;

assign o = a;
  foo bar;
  foo baz;
initial begin
  bar = new();
  baz = new();
  bar.set(4);
  $display(bar.addr);  // expected: 4
  $display(baz.addr);  // expected: 0
end

endmodule
