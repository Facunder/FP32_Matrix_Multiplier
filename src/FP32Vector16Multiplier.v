module FP32Vector16Multiplier(
    input clk,
    input [31:0] vectorA [15:0],
    input [31:0] vectorB [15:0],
    output reg [31:0] result
);

    // Stage 1: Radix-4 Booth Multiplier * 16
    wire [31:0] products [15:0];
    wire [15:0] tmp_exception_flag, tmp_overflow_flag, tmp_underflow_flag;
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : mult_stage
            FP32Multiplier mult_inst (
                .operand_a(vectorA[i]),
                .operand_b(vectorB[i]),
                .exception_flag(tmp_exception_flag[i]),
                .overflow_flag(tmp_overflow_flag[i]),
                .underflow_flag(tmp_underflow_flag[i]),
                .result(products[i])
            );
        end
    endgenerate

    // Pipeline: Stage1 -> Stage2
    reg [31:0] products_reg [15:0];
    always @(posedge clk) begin
        products_reg[0] <= products[0];
        products_reg[1] <= products[1];
        products_reg[2] <= products[2];
        products_reg[3] <= products[3];
        products_reg[4] <= products[4];
        products_reg[5] <= products[5];
        products_reg[6] <= products[6];
        products_reg[7] <= products[7];
        products_reg[8] <= products[8];
        products_reg[9] <= products[9];
        products_reg[10] <= products[10];
        products_reg[11] <= products[11];
        products_reg[12] <= products[12];
        products_reg[13] <= products[13];
        products_reg[14] <= products[14];
        products_reg[15] <= products[15];
    end

    // Stage 2: Add 16 products -> 8 partial sum
    wire [31:0] sums_stage2 [7:0];

    generate
        for (i = 0; i < 8; i = i + 1) begin : add_stage2
            FP32Adder adder_inst (
                .a(products_reg[2*i]),
                .b(products_reg[2*i+1]),
                .sum(sums_stage2[i])
            );
        end
    endgenerate

    // Pipeline: Stage2 -> Stage3
    reg [31:0] sums_stage2_reg [7:0];
    always @(posedge clk) begin
        sums_stage2_reg[0] <= sums_stage2[0];
        sums_stage2_reg[1] <= sums_stage2[1];
        sums_stage2_reg[2] <= sums_stage2[2];
        sums_stage2_reg[3] <= sums_stage2[3];
        sums_stage2_reg[4] <= sums_stage2[4];
        sums_stage2_reg[5] <= sums_stage2[5];
        sums_stage2_reg[6] <= sums_stage2[6];
        sums_stage2_reg[7] <= sums_stage2[7];
    end

    // Stage 3: Add 8 partial sum -> 4 partial sum
    wire [31:0] sums_stage3 [3:0];

    generate
        for (i = 0; i < 4; i = i + 1) begin : add_stage3
            FP32Adder adder_inst (
                .a(sums_stage2_reg[2*i]),
                .b(sums_stage2_reg[2*i+1]),
                .sum(sums_stage3[i])
            );
        end
    endgenerate

    // Pipeline: Stage3 -> Stage4
    reg [31:0] sums_stage3_reg [3:0];
    always @(posedge clk) begin
        sums_stage3_reg[0] <= sums_stage3[0];
        sums_stage3_reg[1] <= sums_stage3[1];
        sums_stage3_reg[2] <= sums_stage3[2];
        sums_stage3_reg[3] <= sums_stage3[3];
    end

    // Stage 4: Add 4 partial sum -> 2 partial sum
    wire [31:0] sums_stage4 [1:0];

    generate
        for (i = 0; i < 2; i = i + 1) begin : add_stage4
            FP32Adder adder_inst (
                .a(sums_stage3_reg[2*i]),
                .b(sums_stage3_reg[2*i+1]),
                .sum(sums_stage4[i])
            );
        end
    endgenerate

    // Pipeline: Stage4 -> Stage5
    reg [31:0] sums_stage4_reg [1:0];
    always @(posedge clk) begin
        sums_stage4_reg[0] <= sums_stage4[0];
        sums_stage4_reg[1] <= sums_stage4[1];
    end

    // Stage 5: 2 partial sum -> final sum
    wire [31:0] final_sum;

    FP32Adder final_adder_inst (
        .a(sums_stage4_reg[0]),
        .b(sums_stage4_reg[1]),
        .sum(final_sum)
    );

    // store final result
    always @(posedge clk) begin
        result <= final_sum;
    end

endmodule
