package custom;
    typedef enum logic {
        FIRST  = 1,
        SECOND = 0
    } enum1;
    typedef struct packed {
        logic [1:0] field;
    } struct1;
endpackage

module top (
    input logic simple_logic_net,
    input logic [2:0] packed_logic_net,
    input logic unpacked_logic_net [3:0],
    input logic [4:0] [5:0] packed_array_logic_net,
    input logic [6:0] unpacked_array_logic_net [7:0],
    input custom::enum1 enum_net_output,
    input custom::struct1 struct_net_input,
    input integer integer_net_input,
    input time time_net_input
);

  // empty module

endmodule
