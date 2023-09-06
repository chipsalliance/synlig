module top(output int o);
   typedef enum {a = 1,
                 b = 2} my_enum;
   my_enum e;
   assign o = e.first();
endmodule
