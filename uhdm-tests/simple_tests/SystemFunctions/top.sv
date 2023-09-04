module top(input logic clk, output int o1, output int o2, output int o3);
   real r = 0;
   int i = 0;
   string s = "";
   int fd;

   logic[7:0] M[4][4];

   int mem1[16];
   int mem2[16];

    `define TEST(x) if (!(x)) $stop

    always @(posedge clk or negedge clk) begin
        if (clk) begin
            `TEST($rose(clk));
            `TEST($past(clk) == 0);
        end
        else begin
            `TEST($fell(clk));
            `TEST($past(clk) == 1);
        end
        `TEST($changed(clk));
        `TEST(!$stable(clk));
        o1 = $random;
        o2 = $urandom;
        o3 = $urandom_range(4, 8);
    end

    initial begin
        `TEST(mem1 == mem2);
        `TEST($asin($sin(0)) == 0);
        `TEST($acos($cos(0)) == 0);
        `TEST($atan($tan(0)) == 0);
        `TEST($asinh($sinh(0)) == 0);
        `TEST($acosh($cosh(0)) == 0);
        `TEST($atanh($tanh(0)) == 0);
        `TEST($atan2(0, 1) == 0);
        `TEST($exp(0) == 1);
        `TEST($ln(1) == 0);
        `TEST($log10(100) == 2);
        `TEST($pow(10, 2) == 100);
        `TEST($sqrt(16) == 4);
        `TEST($ceil(0.5) == 1);
        `TEST($floor(0.5) == 0);
        `TEST($hypot(3, 4) == 5);

        `TEST($clog2(31) == 5);
        `TEST($countones(31) == 5);
        `TEST($onehot(32));
        `TEST($onehot0(0));
        `TEST($countbits(8'b0011xxzz, '0, 'x) == 4);
        `TEST($rtoi(2.7) == 2);
        `TEST($itor(42) == 42.0);
        `TEST($unsigned(-1) == 4294967295);
        `TEST($signed(4294967295) == -1);
        `TEST(!$isunknown('1));
        `TEST($isunknown('x));
        `TEST($size(i) == 32);
        `TEST($typename(i) == "int");
        `TEST($bitstoreal($realtobits(6.28)) == 6.28);

        $display("zero = %0d", 0);
        $displayb("one = %0d", 1);
        $displayh("two = %0d", 2);
        $displayo("three = %0d", 3);
        $monitor("r=%0f, i=%0d, clk=%0d", r, i, clk);
        $strobe("r=%0f, i=%0d", r, i);
        $strobeb("r=%0f, i=%0d", r, i);
        $strobeh("r=%0f, i=%0d", r, i);
        $strobeo("r=%0f, i=%0d", r, i);
        $write("i=%0d\n", i);
        $writeb("i=%0d\n", i);
        $writeh("i=%0d\n", i);
        $writeo("i=%0d\n", i);

        $dumpfile("dump.vcd");
        $dumpall;
        $dumplimit(1024);
        $dumpflush;
        $dumpvars(clk, o);
        $dumpon;
        $dumpoff;

        fd = $fopen("file.txt", "r+");
        $fdisplay(fd, "zero = %0d", 0);
        $fdisplayb(fd, "one = %0d", 1);
        $fdisplayh(fd, "two = %0d", 2);
        $fdisplayo(fd, "three = %0d", 3);
        $fmonitor(fd, "r=%0f, i=%0d, clk=%0d", r, i, clk);
        $fstrobe(fd, "r=%0f, i=%0d", r, i);
        $fstrobeb(fd, "r=%0f, i=%0d", r, i);
        $fstrobeh(fd, "r=%0f, i=%0d", r, i);
        $fstrobeo(fd, "r=%0f, i=%0d", r, i);
        $fwrite(fd, "i=%0d\n", i);
        $fwriteb(fd, "i=%0d\n", i);
        $fwriteh(fd, "i=%0d\n", i);
        $fwriteo(fd, "i=%0d\n", i);
        $rewind(fd);
        $frewind(fd);
        $fseek(fd, 0, 0);
        $fread(i, fd);
        $feof(fd);
        $ferror(fd, s);
        $ungetc(0, fd);
        $fgetc(fd);
        $fgets(s, fd);
        $ftell(fd);
        $fclose(fd);

        `TEST($dimensions(M) == 3);
        `TEST($unpacked_dimensions(M) == 2);
        `TEST($high(M) == 3);
        `TEST($high(M, 1) == 3);
        `TEST($high(M, 3) == 7);
        `TEST($low(M) == 0);
        `TEST($low(M, 1) == 0);
        `TEST($low(M, 3) == 0);
        `TEST($right(M) == 3);
        `TEST($right(M, 1) == 3);
        `TEST($right(M, 3) == 0);
        `TEST($left(M) == 0);
        `TEST($left(M, 1) == 0);
        `TEST($left(M, 3) == 7);
        
        for (int i = 0; i < 16; i++)
            mem1[i] = $random;
        $writememb("memb.txt", mem1);
        $readmemb("memb.txt", mem2);
        `TEST(mem1 == mem2);
        $writememh("memh.txt", mem1);
        $readmemh("memh.txt", mem2);

        $timeformat(-1, 3, "ns", 0);
        `TEST($sformatf("Time is %0t", $time) == "Time is 0.000ns");
        $printtimescale;
        `TEST($time == 0);
        `TEST($realtime == 0.0);
        `TEST($stime == 0);

        $value$plusargs("%d plusarg", i);
        if (0) $stop;
        if (0) $exit;
        if (0) $finish;
        if (0) $error("Error!");
        if (0) $fatal("Fatal error!");
   end
endmodule
