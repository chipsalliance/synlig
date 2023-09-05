// Source:
// https://github.com/alainmarcel/Surelog/tree/master/tests/OneNetModPort

//program TESTBENCH  (ConnectTB.tb intf);
//  initial begin
////    $monitor("@%0dns observe = %0d",$time,intf.observe);
//    intf.drive = 0;
//    #100 intf.drive = 1;
//  end
//endprogram


interface ConnectTB;
  logic drive;
  logic observe;
  modport dut (
    input drive,
    output observe
  );
  modport tb (
    output drive,
    input observe
  );
endinterface

module DUT (ConnectTB.dut intf);
  SUB sub1(.inp(intf.drive), .out(intf.observe));
endmodule

module SUB (input wire inp, output reg out);
  assign out = inp;
endmodule

module top(input wire a, output reg b);
  ConnectTB conntb();
  assign conntb.drive = a;
  assign b = conntb.observe;
  DUT dut(conntb);
//  TESTBENCH tb(conntb);
endmodule
