module top(output [3:0] b);
    typedef struct packed {
        logic first;
        logic second;
        logic third;
        logic fourth;
    } struct_t;

    struct_t a;

    assign a = '{
        first: 0,
        second: 1,
        third: 0,
        fourth: 1
    };

    assign b = '{
        1'd0,
        1'd1,
        1'd0,
        1'd1
    };
endmodule
