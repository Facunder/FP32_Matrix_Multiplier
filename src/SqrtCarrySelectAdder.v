// SqrtCarrySelectAdder data width flexible
module SqrtCarrySelectAdder #(parameter WIDTH = 16) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input cin,
    output reg [WIDTH-1:0] sum,
    output cout
);

    // Calculate the block size
    localparam BLOCK_SIZE = $clog2(WIDTH);
    localparam NUM_BLOCKS = (WIDTH + BLOCK_SIZE - 1) / BLOCK_SIZE;

    wire [BLOCK_SIZE-1:0] sum_blocks [NUM_BLOCKS-1 : 0];// Partial sum results for each block
    wire [1:0] carry [NUM_BLOCKS : 0];

    assign carry[0] = {1'b0, cin};

    // Generate adder blocks
    genvar i;
    generate
        for (i = 0; i < NUM_BLOCKS; i = i + 1) begin : blocks
            localparam int START = i * BLOCK_SIZE;
            localparam int END_WIDTH = (i+1) * BLOCK_SIZE - 1;
            // Handle potential bit width overflow for the last block
            localparam int CURRENT_WIDTH = (END_WIDTH < WIDTH) ? BLOCK_SIZE : WIDTH - START;

            wire [CURRENT_WIDTH-1:0] partial_sum0, partial_sum1;
            wire carry_out0, carry_out1;

            // Two possible sum results and carry outs
            BlockAdder #(.WIDTH(CURRENT_WIDTH)) block_adder_u1 (
                .a(a[START +: CURRENT_WIDTH]),
                .b(b[START +: CURRENT_WIDTH]),
                .cin(carry[i][0]),
                .sum(partial_sum0),
                .cout(carry_out0)
            );

            BlockAdder #(.WIDTH(CURRENT_WIDTH)) block_adder_u2 (
                .a(a[START +: CURRENT_WIDTH]),
                .b(b[START +: CURRENT_WIDTH]),
                .cin(carry[i][1]),
                .sum(partial_sum1),
                .cout(carry_out1)
            );
            
            // Select the correct sum result and carry based on the carry of the previous block
            assign sum_blocks[i] = carry[i][1] ? partial_sum1 : partial_sum0;
            assign carry[i+1] = {1'b0, carry[i][1] ? carry_out1 : carry_out0};
        end
    endgenerate

    // Concatenating all block sums
    integer j;
    always @(*) begin
        sum = {BLOCK_SIZE{1'b0}}; // Initialize sum to zero
        for (j = NUM_BLOCKS-1; j >= 0; j = j - 1) begin
            sum = {sum[WIDTH-BLOCK_SIZE-1:0], sum_blocks[j]};
        end
    end

    assign cout = carry[NUM_BLOCKS][1]; // Final carry output
endmodule

// Parameterized Adder Module
module BlockAdder #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a,    // First operand
    input [WIDTH-1:0] b,    // Second operand
    input cin,              // Carry input
    output [WIDTH-1:0] sum, // Sum output
    output cout             // Carry output
);
    // Temporary variable for carry
    wire [WIDTH:0] carry;

    // Initialize carry input
    assign carry[0] = cin;

    // Compute sum and carry for each bit
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : bit_addition
            // Full adder logic: Si = Ai XOR Bi XOR Cin; Cout = Ai&Bi | Bi&Cin | Cin&Ai
            assign sum[i] = a[i] ^ b[i] ^ carry[i];
            assign carry[i+1] = (a[i] & b[i]) | (b[i] & carry[i]) | (carry[i] & a[i]);
        end
    endgenerate

    // Output the last carry
    assign cout = carry[WIDTH];
endmodule
