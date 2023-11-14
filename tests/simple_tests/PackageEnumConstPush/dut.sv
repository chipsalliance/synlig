package pkg;

    typedef enum logic {
        TEST_1,
        TEST_2
    } test_t;

    function test_t swap(test_t test);
        unique case (test)
            TEST_1: return TEST_2; // works with pkg::TEST_1
            TEST_2: return TEST_1; // works with pkg::TEST_2
        endcase
    endfunction

endpackage

module dut (
    input logic clk,
    input  pkg::test_t a,
    output pkg::test_t b
);
    always_comb b = pkg::swap(a);
endmodule
