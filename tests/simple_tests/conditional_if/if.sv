/*
:name: if
:description: A module testing if statement
:tags: 12.4
*/
module top ();
    wire a = 0;
    reg b = 0;
    always_latch @* begin
        if(a) b = 1;
    end
endmodule
