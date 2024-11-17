// `timescale 1ns / 1ps
module FP32_Vector_Multiplier_tb;

    reg clk;
    reg [31:0] vectorA [0:15];
    reg [31:0] vectorB [0:15];
    wire [31:0] result;

    // instance
    FP32Vector16Multiplier uut (
        .clk(clk),
        .vectorA(vectorA),
        .vectorB(vectorB),
        .result(result)
    );

    // gen clk
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns per cycle
    end

    // test
    initial begin
        integer i;

        // init
        #10;

        //***************************** test 1 *********************************//
        $display("TEST VECTOR MULTIPLY: TASK 1");
        // initialize vectorA and vectorB
        for (i = 0; i < 16; i = i + 1) begin
            vectorA[i] = $shortrealtobits(1.0 + i);  // 1.0, 2.0, ..., 16.0
            vectorB[15 - i] = $shortrealtobits(0.5 + i);      // 15.5, 14.5, 13.5, ..., 0.5
        end

        // wait for result
        #100;

        // print input
        $display("Vector A: ");
        for (i = 0; i < 16; i = i + 1) begin
            $display("%h (%f)", vectorA[i], $bitstoshortreal(vectorA[i]));
        end
        $display("Vector B: ");
        for (i = 0; i < 16; i = i + 1) begin
            $display("%h (%f)", vectorB[i], $bitstoshortreal(vectorB[i]));
        end
        // print result
        $display("Result in FP32: %h(%f)", result, $bitstoshortreal(result));

        //***************************** test 2 *********************************//
        $display("TEST VECTOR MULTIPLY: TASK 2");
        // initialize vectorA and vectorB
        for (i = 0; i < 16; i = i + 1) begin
            vectorA[i] = $shortrealtobits(4.0 - i);  // 1.0, 2.0, ..., 16.0
            vectorB[i] = $shortrealtobits(i - 9.96);      // 15.5, 14.5, 13.5, ..., 0.5
        end

        // wait for result
        #100;

        // print input
        $display("Vector A: ");
        for (i = 0; i < 16; i = i + 1) begin
            $display("%h (%f)", vectorA[i], $bitstoshortreal(vectorA[i]));
        end
        $display("Vector B: ");
        for (i = 0; i < 16; i = i + 1) begin
            $display("%h (%f)", vectorB[i], $bitstoshortreal(vectorB[i]));
        end
        // print result
        $display("Result in FP32: %h(%f)", result, $bitstoshortreal(result));

        // finish
        $finish;
    end   

endmodule
