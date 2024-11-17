// Floating Point Unit Multiplier Module
// This module implements a floating point multiplier following IEEE 754 single-precision format (32-bit).
// It handles exceptions, overflow, underflow, and rounding.

module FP32Multiplier (
    input [31:0] operand_a,  // First input operand (32-bit float)
    input [31:0] operand_b,  // Second input operand (32-bit float)
    output exception_flag,   // Flag for invalid operation (e.g., NaN)
    output overflow_flag,    // Flag for overflow condition
    output underflow_flag,   // Flag for underflow condition
    output [31:0] result     // Output result (32-bit float)
);

// Internal wire declarations
wire sign_bit;              // Sign bit for the result
wire rounding_bit;          // Rounding bit for the mantissa
wire is_normalized;         // Flag to check if the result is normalized
wire is_zero;               // Flag to check if either operand is zero
wire [8:0] exponent_sum;    // Sum of the exponents of the operands
wire [8:0] final_exponent;  // Final exponent after adjustment
wire [22:0] mantissa_product; // Mantissa of the product
wire [23:0] extended_operand_a, extended_operand_b; // Extended operands with hidden bit
wire [47:0] product;        // Intermediate product of the operands
wire [47:0] normalized_product; // Normalized product after shifting

// XOR of the sign bits to get the sign of the result
assign sign_bit = operand_a[31] ^ operand_b[31]; 

// Set exception flag if any of the operands are NaN (exponent = 255)
assign exception_flag = (&operand_a[30:23]) | (&operand_b[30:23]);

// Check if either operand is zero (both exponent and fraction are zero)
assign is_zero = exception_flag ? 1'b0 : (operand_a[30:0] == 31'd0 || operand_b[30:0] == 31'd0) ? 1'b1 : 1'b0;

// Extend the operands and set the hidden bit
assign extended_operand_a = (|operand_a[30:23]) ? {1'b1, operand_a[22:0]} : {1'b0, operand_a[22:0]};
assign extended_operand_b = (|operand_b[30:23]) ? {1'b1, operand_b[22:0]} : {1'b0, operand_b[22:0]};

// Compute the product of the extended operands
// assign product = extended_operand_a * extended_operand_b; // for test
Radix4BoothMultiplier radix4_booth_multiplier(
    .A(extended_operand_a),
    .B(extended_operand_b),
    .product(product)
);

// Determine if rounding is needed based on the lower 23 bits of the product
assign rounding_bit = |normalized_product[22:0];

// Check if the product is normalized (i.e., the most significant bit is 1)
assign is_normalized = product[47] ? 1'b1 : 1'b0;

// Normalize the product by shifting if necessary
assign normalized_product = is_normalized ? product : product << 1;

// Extract the mantissa from the normalized product, rounding if needed
assign mantissa_product = normalized_product[46:24] + (normalized_product[23] & rounding_bit);

// Add the exponents of the operands and adjust for bias (127 for single precision)
assign exponent_sum = operand_a[30:23] + operand_b[30:23];
assign final_exponent = exponent_sum - 8'd127 + is_normalized;

// Set overflow flag if the exponent exceeds 255
assign overflow_flag = ((final_exponent[8] & !final_exponent[7]) & !is_zero) ? 1'b1 : 1'b0;

// Set underflow flag if the exponent is less than 0 (i.e. subnormal)
assign underflow_flag = ((final_exponent[8] & final_exponent[7]) & !is_zero) ? 1'b1 : 1'b0;

// Final output result calculation
assign result = exception_flag ? 32'd0 : is_zero ? {sign_bit, 31'd0} : overflow_flag ? {sign_bit, 8'hFF, 23'd0} : underflow_flag ? {sign_bit, 31'd0} : {sign_bit, final_exponent[7:0], mantissa_product};

// // Debugging Version: Bypass exception and zero checks
// assign result = {sign_bit, final_exponent[7:0], mantissa_product};

endmodule


