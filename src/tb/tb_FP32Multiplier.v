// Testbench for FPUMultiplier
// `timescale 1ns / 1ps
module test_FP32Multiplier;

    // Test input and output signals
    reg [31:0] operand_a, operand_b;
    wire exception_flag, overflow_flag, underflow_flag;
    wire [31:0] result;
    // wire [47:0] product;

    // Instantiate the FPUMultiplier module
    FP32Multiplier uut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .exception_flag(exception_flag),
        .overflow_flag(overflow_flag),
        .underflow_flag(underflow_flag),
        .result(result)
    );

    // Function to convert 32-bit IEEE 754 floating point to real
    function real bits_to_float;
        input [31:0] in;
        reg [31:0] temp;
        begin
            temp = in;
            bits_to_float = $bitstoshortreal(temp);
        end
    endfunction

    // Test vector generation
    initial begin

        // Test case 0: Multiplication of two arbitrary positive numbers
        operand_a = 32'h40000000;  // 2.0 in IEEE 754
        operand_b = 32'h40000000;  // 2.0 in IEEE 754
        #10;
        $display("Test 0: %f * %f = %f, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: 4.0", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);

        // Test case 1: Multiplication of two arbitrary positive numbers
        operand_a = 32'h41200000;  // 10.0 in IEEE 754
        operand_b = 32'h40A00000;  // 5.0 in IEEE 754
        #10;
        $display("Test 1: %f * %f = %f, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: 50.0", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);

        // Test case 2: Multiplication of positive and negative numbers with decimals
        operand_a = 32'hC2480000;  // -50.0 in IEEE 754
        operand_b = 32'h3F4CCCCD;  // 0.8 in IEEE 754
        #10;
        $display("Test 2: %f * %f = %f, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: -40.0", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);

        // Test case 3: Multiplication of two negative numbers with decimals
        operand_a = 32'hBF99999A;  // -1.2 in IEEE 754
        operand_b = 32'hBF19999A;  // -0.6 in IEEE 754
        #10;
        $display("Test 3: %f * %f = %f, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: 0.72", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);

        // Test case 4: Multiplication of very small numbers
        operand_a = 32'h33D6BF95;  // 1e-7 in IEEE 754
        operand_b = 32'h3B83126F;  // 4e-3 in IEEE 754
        #10;
        $display("Test 4: %e * %e = %e, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: 4e-10", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);

        // Test case 5: Multiplication of very large numbers
        operand_a = 32'h7E967699;  // ~1e38 in IEEE 754
        operand_b = 32'h49F423FA;  // 500000.0 in IEEE 754
        #10;
        $display("Test 5: %e * %e = %e, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: Overflow", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);
        // Test case 6: Multiplication resulting in underflow
        operand_a = 32'h00800001;  // Smallest normal positive number slightly above subnormal
        operand_b = 32'h00800001;  // Same as above
        #10;
        $display("Test 6: %e * %e = %e, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: Underflow", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);

        // Test case 7: Multiplication of numbers in scientific notation
        operand_a = 32'h3EAAAAAB;  // 0.33333334 in IEEE 754
        operand_b = 32'h3F4CCCCD;  // 0.8 in IEEE 754
        #10;
        $display("Test 7: %f * %f = %f, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: 0.26666668", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);

        // Test case 8: Multiplication of irrational numbers approximations
        operand_a = 32'h40490FDB;  // π (3.1415927) in IEEE 754
        operand_b = 32'h402DF864;  // e (2.7182817) in IEEE 754
        #10;
        $display("Test 8: %f * %f = %f, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: 8.539734", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);

        // Test case 9: Multiplication with a very large and very small number
        operand_a = 32'h7F7FFFFF;  // Maximum normal positive number
        operand_b = 32'h00800000;  // Smallest normal positive number
        #10;
        $display("Test 9: %e * %e = %e, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: Significant Number", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);

        // Test case 10: Multiplication resulting in NaN (0 * Infinity)
        operand_a = 32'h00000000;  // 0.0 in IEEE 754
        operand_b = 32'h7F800000;  // Infinity in IEEE 754
        #10;
        $display("Test 10: %f * %f = %f, exception_flag = %b, overflow_flag = %b, underflow_flag = %b, Expected: NaN", bits_to_float(operand_a), bits_to_float(operand_b), bits_to_float(result), exception_flag, overflow_flag, underflow_flag);
        // $display("product: %b", product);

        // End of test
        $finish;
    end

//for vcs+verdi co-simulation
// `ifdef FSDB
// initial begin
// 	$fsdbDumpfile("tb_counter.fsdb");
// 	$fsdbDumpvars;
// end
// `endif

endmodule
