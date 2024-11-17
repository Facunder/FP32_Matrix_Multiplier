// compress three pp_(2) to sum and carry
// ps: carry is 1-bit front than sum 
module compressor32 #(parameter DATA_WIDTH = 8)
(
  input  [DATA_WIDTH - 1 : 0]  in1,
  input  [DATA_WIDTH - 1 : 0]  in2,
  input  [DATA_WIDTH - 1 : 0]  in3,
  output [DATA_WIDTH - 1 : 0]  sum, 
  output [DATA_WIDTH - 1 : 0]  carry
);
    generate
        genvar i;
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : bit_csa_unit
            assign sum[i] = in1[i] ^ in2[i] ^ in3[i];
            assign carry[i] = in1[i] & in2[i] | in2[i] & in3[i] | in3[i] &in1[i];
        end
    endgenerate
endmodule

// wallace tree compress using 3:2 CSA compressor
module WallaceTree (
    input  [25:0] pp0, // i.e. partial product
    input  [25:0] pp1,
    input  [25:0] pp2,
    input  [25:0] pp3,
    input  [25:0] pp4,
    input  [25:0] pp5,
    input  [25:0] pp6,
    input  [25:0] pp7,
    input  [25:0] pp8,
    input  [25:0] pp9,
    input  [25:0] pp10,
    input  [25:0] pp11,
    input  [25:0] pp12,
    output [51:0] final_sum,
    output [51:0] final_carry
);

    wire [29:0] l1_u1_sum, l1_u2_sum, l1_u3_sum, l1_u4_sum;
    wire [29:0] l1_u1_carry, l1_u2_carry, l1_u3_carry, l1_u4_carry;

    wire [35:0] l2_u1_sum, l2_u2_sum;
    wire [35:0] l2_u1_carry, l2_u2_carry;
    wire [31:0] l2_u3_sum, l2_u3_carry;

    wire [42:0] l3_u1_sum, l3_u2_sum;
    wire [42:0] l3_u1_carry, l3_u2_carry;

    wire [50:0] l4_u1_sum, l4_u1_carry;

    wire [51:0] l5_u1_sum, l5_u1_carry;
    
    // Stage 1: 13 -> 9 (12 + 1 -> 8 + 1)
    // length = 26 + 4
    compressor32 #(.DATA_WIDTH(30)) cp32_l1_u1(
        .in1({{4{pp0[25]}}, pp0}),
        .in2({{2{pp1[25]}}, pp1, 2'b0}), 
        .in3({pp2, 4'b0}), 
        .sum(l1_u1_sum), 
        .carry(l1_u1_carry)
    ); 
    compressor32 #(.DATA_WIDTH(30)) cp32_l1_u2(
        .in1({{4{pp3[25]}}, pp3}),
        .in2({{2{pp4[25]}}, pp4, 2'b0}), 
        .in3({pp5, 4'b0}), 
        .sum(l1_u2_sum), 
        .carry(l1_u2_carry)
    ); 
    compressor32 #(.DATA_WIDTH(30)) cp32_l1_u3(
        .in1({{4{pp6[25]}}, pp6}),
        .in2({{2{pp7[25]}}, pp7, 2'b0}), 
        .in3({pp8, 4'b0}), 
        .sum(l1_u3_sum), 
        .carry(l1_u3_carry)
    ); 
    compressor32 #(.DATA_WIDTH(30)) cp32_l1_u4(
        .in1({{4{pp9[25]}}, pp9}),
        .in2({{2{pp10[25]}}, pp10, 2'b0}), 
        .in3({pp11, 4'b0}), 
        .sum(l1_u4_sum), 
        .carry(l1_u4_carry)
    );

    // Stage 2: 9 -> 6
    // // length = 30 + 6
    compressor32 #(.DATA_WIDTH(36)) cp32_l2_u1(
        .in1({{6{l1_u1_sum[29]}}, l1_u1_sum}),
        .in2({{5{l1_u1_carry[29]}}, l1_u1_carry, 1'b0}), 
        .in3({l1_u2_sum, 6'b0}), 
        .sum(l2_u1_sum), 
        .carry(l2_u1_carry)
    ); 
    compressor32 #(.DATA_WIDTH(36)) cp32_l2_u2(
        .in1({{6{l1_u2_carry[29]}}, l1_u2_carry}),
        .in2({{1{l1_u3_sum[29]}}, l1_u3_sum, 5'b0}), 
        .in3({l1_u3_carry, 6'b0}), 
        .sum(l2_u2_sum), 
        .carry(l2_u2_carry)
    ); 
    compressor32 #(.DATA_WIDTH(32)) cp32_l2_u3( //length = 26 + 6
        .in1({{2{l1_u4_sum[29]}}, l1_u4_sum}),
        .in2({{1{l1_u4_carry[29]}}, l1_u4_carry, 1'b0}), 
        .in3({pp12, 6'b0}), 
        .sum(l2_u3_sum), 
        .carry(l2_u3_carry)
    ); 

    // Stage 3: 6 -> 4
    // length = 36 + 7
    compressor32 #(.DATA_WIDTH(43)) cp32_l3_u1( 
        .in1({{7{l2_u1_sum[35]}}, l2_u1_sum}),
        .in2({{6{l2_u1_carry[35]}}, l2_u1_carry, 1'b0}), 
        .in3({l2_u2_sum, 7'b0}), 
        .sum(l3_u1_sum), 
        .carry(l3_u1_carry)
    ); 
    compressor32 #(.DATA_WIDTH(43)) cp32_l3_u2( 
        .in1({{7{l2_u2_carry[35]}}, l2_u2_carry}),
        .in2({l2_u3_sum[31], l2_u3_sum, 10'b0}), 
        .in3({l2_u3_carry, 11'b0}), 
        .sum(l3_u2_sum), 
        .carry(l3_u2_carry)
    );

    // Stage 4: 4->3
    // length = 43 + 8
    compressor32 #(.DATA_WIDTH(51)) cp32_l4_u1( 
        .in1({{8{l3_u1_sum[42]}}, l3_u1_sum}),
        .in2({{7{l3_u1_carry[42]}}, l3_u1_carry, 1'b0}), 
        .in3({l3_u2_sum, 8'b0}), 
        .sum(l4_u1_sum), 
        .carry(l4_u1_carry)
    );

    // Stage 5: 3->2
    // length = 51 + 1
    compressor32 #(.DATA_WIDTH(52)) cp32_l5_u1( 
        .in1({l4_u1_sum[50], l4_u1_sum}),
        .in2({l4_u1_carry, 1'b0}), 
        .in3({l3_u2_carry, 9'b0}), 
        .sum(l5_u1_sum), 
        .carry(l5_u1_carry)
    );

    assign final_sum = l5_u1_sum;
    assign final_carry = {l5_u1_carry[50:0], 1'b0};

endmodule
