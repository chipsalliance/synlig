module top
(
    input [3:0] in,
    output out_1, out_2, out_3, out_4, out_5, out_6, out_7, out_8, out_9, out_10,
           out_11, out_12, out_13, out_14, out_15, out_16, out_17, out_18
);
    assign out_1 =  in[0] & in[1];
    assign out_2 =  in[0] | in[1];
    assign out_3 =  in[0] ~& in[1];
    assign out_4 =  in[0] ~| in[1];
    assign out_5 =  in[0] ^ in[1];
    assign out_6 =  in[0] ~^ in[1];
    assign out_7 =  in[0] ^~ in[1];
    assign out_8 =  ~in[0];
    assign out_9 =  in[0];
    assign out_10 =  &in[0];
    assign out_11 =  |in[0];
    assign out_12 =  ~&in[0];
    assign out_13 =  ~|in[0];
    assign out_14 =  ^in[0];
    assign out_15 =  ~^in[0];
    assign out_16 =  ^~in[0];
    assign out_17 =  in[0:1] && in [2:3];
    assign out_18 =  in[0:1] || in [2:3];

endmodule

