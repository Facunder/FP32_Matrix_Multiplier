// `timescale 1ns / 1ps
module test_fp32_adder;
    reg [31:0]  a, b;
    wire [31:0] sum;
    FP32Adder uut (.a(a), .b(b), .sum(sum));

    initial begin

        // normal
        a = 32'h40400000; 
        b = 32'h40700000; 
        #10;
        $display("%f + %f = %h (%f)", $bitstoshortreal(a), $bitstoshortreal(b), sum, $bitstoshortreal(sum));

        // positive and negative
        a = 32'h40400000; 
        b = 32'hc0700000; 
        #10;
        $display("%f + %f = %h (%f)",  $bitstoshortreal(a), $bitstoshortreal(b), sum, $bitstoshortreal(sum));

        // zero value
        a = 32'h00000000; 
        b = 32'h40700000; 
        #10;
        $display("%f + %f = %h (%f)",  $bitstoshortreal(a), $bitstoshortreal(b), sum, $bitstoshortreal(sum));

        // inf
        a = 32'h7f800000; // Inf
        b = 32'hbf800000; // -Inf
        #10;
        $display("%f + %f = %h (%f)",  $bitstoshortreal(a), $bitstoshortreal(b), sum, $bitstoshortreal(sum));

        // NaN
        a = 32'h7f800001; // NaN
        b = 32'h40700000; 
        #10;
        $display("%f + %f = %h (%f)",  $bitstoshortreal(a), $bitstoshortreal(b), sum, $bitstoshortreal(sum));

        // maximum
        a = 32'h7f7fffff; // Max Float
        b = 32'h00800000; // Smallest normal number
        #10;
        $display("%f + %f = %h (%f)",  $bitstoshortreal(a), $bitstoshortreal(b), sum, $bitstoshortreal(sum));

        // overflow
        a = 32'h7f7fffff; // Max Float
        b = 32'h7f7fffff; // Max Float
        #10;
        $display("%f + %f = %h (%f)",  $bitstoshortreal(a), $bitstoshortreal(b), sum, $bitstoshortreal(sum));

        $finish;
    end
endmodule
