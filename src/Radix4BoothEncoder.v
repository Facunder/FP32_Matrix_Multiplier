module Radix4BoothEncoder (
    A,  // Multiplicand
    partial_B,  // Multiplier
    P_reg
);    
    parameter length = 24;
    input [length - 1 : 0] A;  // Multiplicand
    input [2:0] partial_B;  // Multiplier
    output reg [length : 0] P_reg;  // Product

    always @(*) begin
        case(partial_B)
            3'b000 : P_reg <= 0;
            3'b001 : P_reg <= { A[length - 1], A};
            3'b010 : P_reg <= { A[length - 1], A};
            3'b011 : P_reg <= A << 1;
            3'b100 : P_reg <= -(A<<1);
            3'b101 : P_reg <= -{A[length - 1], A};
            3'b110 : P_reg <= -{A[length - 1], A};
            3'b111 : P_reg <= 0;
            default : P_reg <= 0;
        endcase
    end
endmodule
