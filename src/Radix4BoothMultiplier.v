// two unsigned binary variables multiply
// extend unsigned binary to signed binary
// thus can use signed radix-4 booth method
module Radix4BoothMultiplier(
    input [23 : 0] A,
    input [23 : 0] B,
    output [47 : 0] product
);

wire [26 : 0] extend_B = {2'b0, B, 1'b0}; // extend sign bit for Booth_13
wire [24 : 0] extend_A = {1'b0, A}; // trans to signed
wire [25 : 0] partial_sum [12 : 0]; // 12 + 1(2^24 * b_23 * A)
wire [51 : 0] final_sum;
wire [51 : 0] final_carry;
wire tmp_cout;

// Radix-4 Booth Encode, generate partial sum
generate 
        genvar i;
        for (i = 0; i < 13; i = i + 1) begin : Booth_Encoders
            Radix4BoothEncoder #(.length(25)) booth_encoder (
                .A(extend_A),
                .partial_B(extend_B[2 * i + 2 : 2 * i]),
                .P_reg(partial_sum[i])
            );
        end
endgenerate

// Wallace Tree Compress
WallaceTree wallace_tree(
    .pp0(partial_sum[0]),
    .pp1(partial_sum[1]),   
    .pp2(partial_sum[2]),
    .pp3(partial_sum[3]),
    .pp4(partial_sum[4]),
    .pp5(partial_sum[5]),
    .pp6(partial_sum[6]),
    .pp7(partial_sum[7]),
    .pp8(partial_sum[8]),
    .pp9(partial_sum[9]), 
    .pp10(partial_sum[10]),
    .pp11(partial_sum[11]),
    .pp12(partial_sum[12]),
    .final_sum(final_sum),
    .final_carry(final_carry)
);

// final add and truncation
// bit redundancy for sign-bit extension
// assign product = final_sum + final_carry; 
SqrtCarrySelectAdder #(.WIDTH(48)) sqrt_carry_select_adder(
    .a(final_sum[47:0]),
    .b(final_carry[47:0]),
    .cin(1'b0),
    .sum(product),
    .cout(tmp_cout)
);

endmodule