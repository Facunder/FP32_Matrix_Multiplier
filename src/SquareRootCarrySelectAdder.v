module sqrt_csa_adder (
    input [47:0] A,  // Operand A
    input [47:0] B,  // Operand B
    output [47:0] sum,  // Sum of A and B
    output carry_out   // Final carry out
);
    wire [47:0] sum_part[0:4];  // Intermediate sum results
    wire [47:0] carry_part[0:4]; // Intermediate carry results
    
    // 1st stage of SQRT-CSA: Direct addition of first two operands
    half_adder ha0 (
        .a(A[0]),
        .b(B[0]),
        .sum(sum_part[0][0]),
        .carry(carry_part[0][0])
    );
    
    // Additional stages: Use Full Adders for multi-bit operations
    generate
        genvar i;
        for (i = 1; i < 47; i = i + 1) begin : full_adder_stage
            full_adder fa (
                .a(A[i]),
                .b(B[i]),
                .cin(carry_part[i-1]),
                .sum(sum_part[i]),
                .carry(carry_part[i])
            );
        end
    endgenerate
    
    // Final sum and carry output after all stages
    assign sum = sum_part[47];
    assign carry_out = carry_part[47];

endmodule
