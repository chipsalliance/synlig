package my_pkg;

  typedef enum int {
    Get0 = 0,
    Get1 = 1,
    Get2 = 2,
    Get3 = 3,
    GetDefault = 100
  } get_e;

endpackage

module top
import my_pkg::*;
#(
    parameter get_e GetWhat = Get0
) (
    output int out
);

  if (GetWhat inside {Get0, GetDefault}) begin : gen_zero
    assign out = 0;
  end else if (GetWhat == Get1) begin : gen_one
    assign out = 1;
  end else if (GetWhat == Get2) begin : gen_two
    assign out = 2;
  end else if (GetWhat == Get3) begin : gen_three
    assign out = 3;
  end else begin : gen_invalid
    assign out = 255;
  end

endmodule
