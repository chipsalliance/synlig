module top(output [3:0] b);
    typedef struct packed {
        logic first;
        logic second;
        logic third;
        logic fourth;
    } struct_t;

    struct_t c;

    assign c = '{third: 0, default: '1};

    assign b = c;

    // Based on example in IEEE 37.57
    // ABC is not stored properly in UHDM
    //struct packed{
    //    int A;
    //    struct packed{
    //        reg B;
    //        int C;
    //    } BC1, BC2;
    //} ABC = '{BC1: '{1'b1, 1}, A: 0, BC2: '{default: 0}};

endmodule
