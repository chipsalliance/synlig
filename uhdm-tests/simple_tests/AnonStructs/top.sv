module top(output [3:0] b);
    struct packed {
        logic first;
        logic second;
        logic third;
        logic fourth;
    } a;

    assign a = '{
        first: 0,
        second: 1,
        third: 0,
        fourth: 1
    };

    assign b = a;

endmodule
