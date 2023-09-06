package foo; // verilog_lint: waive package-filename
    typedef struct {
        int ld;
    } fie_t;

    typedef struct {
        int \fie.ld ; // verilog_lint: waive struct-union-name-style
        fie_t fie;
    } \st:r.uct_t ;

    typedef struct {
        int i;
    } uct_t ;
endpackage

module \top (output int o1, output int o2); // verilog_lint: waive module-filename
    import foo::*;

    foo::\st:r.uct_t  \o.b.j = '{1111, 2222};
    foo::uct_t  uct_obj = '{9999};
    initial begin
        \o.b.j .\fie.ld = 3333;
        \o.b.j .fie.ld = uct_obj.i;
    end

    assign o1 = \o.b.j .\fie.ld ;
    assign o2 = \o.b.j .\fie .ld ;
endmodule
