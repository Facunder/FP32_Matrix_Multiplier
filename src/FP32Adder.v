// IEEE 754 FP32 Adder
module FP32Adder(
    input  [31:0] a,   // Input operand A
    input  [31:0] b,   // Input operand B
    output [31:0] sum  // Sum output
);

// Unpack inputs
wire sign_a;
wire [7:0] exp_a;
wire [23:0] frac_a;
wire sign_b;
wire [7:0] exp_b;
wire [23:0] frac_b;

assign sign_a = a[31];
assign exp_a  = a[30:23];
assign frac_a = (exp_a == 0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
assign sign_b = b[31];
assign exp_b  = b[30:23];
assign frac_b = (exp_b == 0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};

// Exponent difference
wire [7:0] exp_diff;
wire [7:0] exp_max;
wire [23:0] frac_a_shifted;
wire [23:0] frac_b_shifted;

assign exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
assign exp_max  = (exp_a > exp_b) ? exp_a : exp_b;

// Shift fractions to align exponents
assign frac_a_shifted = (exp_a == exp_max) ? frac_a : (frac_a >> exp_diff);
assign frac_b_shifted = (exp_b == exp_max) ? frac_b : (frac_b >> exp_diff);

// Add or subtract fractions
wire [24:0] frac_sum;
wire result_sign;

assign result_sign = (frac_a_shifted >= frac_b_shifted) ? sign_a : sign_b;
assign frac_sum = (sign_a == sign_b) ? 
                  ({1'b0, frac_a_shifted} + {1'b0, frac_b_shifted}) :
                  ((frac_a_shifted >= frac_b_shifted) ? 
                   ({1'b0, frac_a_shifted} - {1'b0, frac_b_shifted}) :
                   ({1'b0, frac_b_shifted} - {1'b0, frac_a_shifted}));

// Normalize result
reg [7:0] exp_result;
reg [23:0] frac_result;
reg [4:0] shift;

always @(*) begin
    if (frac_sum[24]) begin
        frac_result = frac_sum[24:1];
        exp_result  = exp_max + 1;
    end else begin
        frac_result = frac_sum[23:0];
        exp_result  = exp_max;
        if (frac_result != 0) begin
            for (shift = 0; shift < 23; shift = shift + 1) begin
                if (frac_result[23] == 0 && exp_result > 0) begin
                    frac_result = frac_result << 1;
                    exp_result  = exp_result - 1;
                end else begin
                    break;
                end
            end
        end else begin
            exp_result = 0;
        end
    end
end

// Pack result
assign sum = (frac_result == 0) ? 32'b0 : {result_sign, exp_result, frac_result[22:0]};

endmodule
