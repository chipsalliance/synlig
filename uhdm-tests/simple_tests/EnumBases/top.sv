module top(output int o);
    parameter int PARAM = 4;

    typedef int type32;
    typedef bit[89:0] type90;
    typedef bit type1;

    // implicit int; 32 bit
    typedef enum { IMPL_INT_0_ITEM_0 = 0,    IMPL_INT_0_ITEM_1 = 1    } impl_int_0_e;
    typedef enum { IMPL_INT_1_ITEM_0 = 2'd0, IMPL_INT_1_ITEM_1 = 2'd1 } impl_int_1_e;

    // explicit int; 32 bit
    typedef enum int { INT_0_ITEM_0 = 0, INT_0_ITEM_1 = 1 } int_0_e;

    // logic; 1 bit
    typedef enum logic { LOGIC_0_ITEM_0 = 0,    LOGIC_0_ITEM_1 = 1    } logic_0_e;
    typedef enum logic { LOGIC_1_ITEM_0 = 1'd0, LOGIC_1_ITEM_1 = 1'd1 } logic_1_e;

    // logic[89:0]; 90 bits
    typedef enum logic[89:0] { LOGIC90_0_ITEM_0 = 0,     LOGIC90_0_ITEM_1 = 1     } logic90_0_e;
    typedef enum logic[89:0] { LOGIC90_1_ITEM_0 = 90'd0, LOGIC90_1_ITEM_1 = 90'd1 } logic90_1_e;

    // bit; 1 bit
    typedef enum bit { BIT_0_ITEM_0 = 0,    BIT_0_ITEM_1 = 1    } bit_0_e;
    typedef enum bit { BIT_1_ITEM_0 = 1'd0, BIT_1_ITEM_1 = 1'd1 } bit_1_e;

    // bit[89:0]; 90 bits
    typedef enum bit[89:0] { BIT90_0_ITEM_0 = 0,     BIT90_0_ITEM_1 = 1     } bit90_0_e;
    typedef enum bit[89:0] { BIT90_1_ITEM_0 = 90'd0, BIT90_1_ITEM_1 = 90'd1 } bit90_1_e;

    // Parametrized ranges

    // logic[89:0]; 90 bits
    typedef enum logic[85 + PARAM:0] {
        LOGIC90P_0_ITEM_0 = 0,
        LOGIC90P_0_ITEM_1 = 1
    } logic90p_0_e;
    typedef enum logic[85 + PARAM:0] {
        LOGIC90P_1_ITEM_0 = 90'd0,
        LOGIC90P_1_ITEM_1 = 90'd1
    } logic90p_1_e;

    // bit[89:0]; 90 bits
    typedef enum bit[85 + PARAM:0] { BIT90P_0_ITEM_0 = 0,     BIT90P_0_ITEM_1 = 1     } bit90p_0_e;
    typedef enum bit[85 + PARAM:0] { BIT90P_1_ITEM_0 = 90'd0, BIT90P_1_ITEM_1 = 90'd1 } bit90p_1_e;

    // Parametrized ranges with use of $bits

    // logic[89:0]; 90 bits
    typedef enum logic[$bits(PARAM) - 32 + 85 + PARAM:0] {
        LOGIC90PB_0_ITEM_0 = 0,
        LOGIC90PB_0_ITEM_1 = 1
    } logic90pb_0_e;
    typedef enum logic[$bits(PARAM) - 32 + 85 + PARAM:0] {
        LOGIC90PB_1_ITEM_0 = 90'd0,
        LOGIC90PB_1_ITEM_1 = 90'd1
    } logic90pb_1_e;

    // bit[89:0]; 90 bits
    typedef enum bit[$bits(PARAM) - 32 + 85 + PARAM:0] {
        BIT90PB_0_ITEM_0 = 0,
        BIT90PB_0_ITEM_1 = 1
    } bit90pb_0_e;
    typedef enum bit[$bits(PARAM) - 32 + 85 + PARAM:0] {
        BIT90PB_1_ITEM_0 = 90'd0,
        BIT90PB_1_ITEM_1 = 90'd1
    } bit90pb_1_e;

    // Using packed enums for bit-size equality checks.

    typedef union packed {
        type1     t;
        logic_0_e logic_0_m;
        logic_1_e logic_1_m;
        bit_0_e   bit_0_m;
        bit_1_e   bit_1_m;
    } union_1_bit_t;

    typedef union packed {
        type32        t;
        impl_int_0_e  impl_int_0_m;
        impl_int_1_e  impl_int_1_m;
        int_0_e       int_0_m;
    } union_32_bit_t;

    typedef union packed {
        type90       t;
        logic90_0_e   logic90_0_m;
        logic90_1_e   logic90_1_m;
        bit90_0_e     bit90_0_m;
        bit90_1_e     bit90_1_m;
        logic90p_0_e  logic90p_0_m;
        logic90p_1_e  logic90p_1_m;
        bit90p_0_e    bit90p_0_m;
        bit90p_1_e    bit90p_1_m;
        logic90pb_0_e logic90pb_0_m;
        logic90pb_1_e logic90pb_1_m;
        bit90pb_0_e   bit90pb_0_m;
        bit90pb_1_e   bit90pb_1_m;
    } union_90_bit_t;
endmodule
