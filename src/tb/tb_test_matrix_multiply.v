// `timescale 1ns / 1ps
// test [N,16] x [16,N] matrix multiply using FP32Vector16Multiplier
module FP32Vector16Multiplier_tb;

    // Parameters
    localparam N = 4; // Matrix dimension (adjust as needed)

    // Clock Generation
    reg clk;
    initial clk = 0;
    always #5 clk = ~clk; // Generates a clock with a period of 10ns (100MHz)

    // Matrix Definitions
    reg [31:0] matrixA [0:N-1][0:15]; // Matrix A: [N][16]
    reg [31:0] matrixB [0:15][0:N-1]; // Matrix B: [16][N]
    reg [31:0] matrixC [0:N-1][0:N-1]; // Result Matrix C: [N][N]

    // Multiplier Inputs and Output
    reg [31:0] vectorA [0:15];
    reg [31:0] vectorB [0:15];
    wire [31:0] result;

    // Instantiate the FP32Vector16Multiplier
    FP32Vector16Multiplier uut (
        .clk(clk),
        .vectorA(vectorA),
        .vectorB(vectorB),
        .result(result)
    );

    // Control Variables
    integer i, j, k;
    real expected;
    real tmp;
    integer file_rd; 

    // Initialize Matrices
    initial begin

        //********************************* Matrix Task 1 *************************************//
        $display("================= MATRIX TASK 1 =================\n");
        // Initialize Matrix A with specific floating-point values
        for (i = 0; i < N; i = i + 1) begin
            for (k = 0; k < 16; k = k + 1) begin
                // Example initialization
                matrixA[i][k] = $shortrealtobits((i + 1.0) + (k * 0.1));
            end
        end
        $display("===== Matrix A =====");
        for (i = 0; i < N; i = i + 1) begin
            for (k = 0; k < 16; k = k + 1) begin
                $write("%f ", $bitstoshortreal(matrixA[i][k]));
            end
            $write("\n");
        end
        $display("=================\n");

        // Initialize Matrix B with specific floating-point values
        for (k = 0; k < 16; k = k + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                // Example initialization
                matrixB[k][j] = $shortrealtobits(((j + 1.0) * 2.0) + (k * 0.48) - 9.96);
            end
        end
        $display("===== Matrix B =====");
        for (i = 0; i < 16; i = i + 1) begin
            for (k = 0; k < N; k = k + 1) begin
                $write("%f ", $bitstoshortreal(matrixB[i][k]));
            end
            $write("\n");
        end
        $display("=================\n");

        // Initialize Result Matrix C to zero
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                matrixC[i][j] = 32'd0;
            end
        end

        // Wait for global reset if any
        #100;

        // Start Matrix Multiplication
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                // Load vectorA with the i-th row of Matrix A
                for (k = 0; k < 16; k = k + 1) begin
                    vectorA[k] = matrixA[i][k];
                end

                // Load vectorB with the j-th column of Matrix B
                for (k = 0; k < 16; k = k + 1) begin
                    vectorB[k] = matrixB[k][j];
                end

                // Apply inputs on the next clock edge
                @(posedge clk);

                // Wait for pipeline latency (assuming 5 clock cycles)
                // Adjust '5' based on the actual pipeline depth of FP32Vector16Multiplier
                repeat(5) @(posedge clk);

                // Capture the result
                matrixC[i][j] = result;
            end
        end
        // print result
        $display("===== Matrix C =====");
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                $write("%h (%f) ",matrixC[i][j], $bitstoshortreal(matrixC[i][j]));
            end
            $write("\n");
        end
        $display("=================\n");
        
        #100

        //********************************* Matrix Task 2 *************************************//
        $display("================= MATRIX TASK 2 =================\n");
        file_rd = $fopen("./data/data.txt","r");
        // Initialize Matrix A with read-in floating-point values
        for (i = 0; i < N; i = i + 1) begin
            for (k = 0; k < 16; k = k + 1) begin
                $fscanf(file_rd, "%f", tmp);
                matrixA[i][k] = $shortrealtobits(tmp); 
            end
        end
        $display("===== Matrix A =====");
        for (i = 0; i < N; i = i + 1) begin
            for (k = 0; k < 16; k = k + 1) begin
                $write("%f ", $bitstoshortreal(matrixA[i][k]));
            end
            $write("\n");
        end
        $display("=================\n");

        // Initialize Matrix B with read-in floating-point values
        for (k = 0; k < 16; k = k + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                $fscanf(file_rd, "%f", tmp);
                matrixB[k][j] = $shortrealtobits(tmp);             
            end
        end
        $display("===== Matrix B =====");
        for (i = 0; i < 16; i = i + 1) begin
            for (k = 0; k < N; k = k + 1) begin
                $write("%f ", $bitstoshortreal(matrixB[i][k]));
            end
            $write("\n");
        end
        $display("=================\n");

        // Initialize Result Matrix C to zero
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                matrixC[i][j] = 32'd0;
            end
        end

        // Wait for global reset if any
        #100;
        @(posedge clk); // for re-load vector input

        // Start Matrix Multiplication
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                // Load vectorA with the i-th row of Matrix A
                for (k = 0; k < 16; k = k + 1) begin
                    vectorA[k] = matrixA[i][k];
                end

                // Load vectorB with the j-th column of Matrix B
                for (k = 0; k < 16; k = k + 1) begin
                    vectorB[k] = matrixB[k][j];
                end

                // Apply inputs on the next clock edge
                @(posedge clk);

                // Wait for pipeline latency (assuming 5 clock cycles)
                // Adjust '5' based on the actual pipeline depth of FP32Vector16Multiplier
                repeat(5) @(posedge clk);

                // Capture the result
                matrixC[i][j] = result;
            end
        end
        // print result
        $display("===== Matrix C =====");
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                $write("%h (%f) ",matrixC[i][j], $bitstoshortreal(matrixC[i][j]));
            end
            $write("\n");
        end
        $display("=================\n");

        // End Simulation
        $finish;
    end

endmodule
