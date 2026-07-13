/* 

    July 13th, 2026

*/

import enums::*;

module alu (
    input logic [31:0] a, b,
    input logic [6:0] f7,
    input logic [2:0] f3,
    input instr_t instr,
    output logic [31:0] result,
    output logic neg, zero, over, carry, stall, divbyzero
);  

    logic [32:0] sres = a - b;
    assign neg = sres[31];
    assign carry = sres[32];
    assign zero = !sres;
    assign over = (a[31] ^ b[31]) && (a[31] ^ sres[31]);


    


    // TOO MUCH NESTED CASES
    always_comb begin
        case (instr)
            ArithR: begin
                case (f7)
                    // I extenstion
                    7'b0: begin
                        case (f3)
                            3'b000: result = a + b; // add
                            3'b001: result = a << b[4:0]; // sll
                            3'b010: result = $signed(a) < $signed(b); // slt
                            3'b011: result = a < b; // sltu
                            3'b100: result = a ^ b; // xor
                            3'b101: result = a >> b[4:0]; // srl
                            3'b110: result = a | b; // or
                            3'b111: result = a & b; // and
                        endcase
                    end
                    7'b0100000: begin
                        case (f3)
                            3'b000: result = a - b; // sub
                            3'b101: result = $signed(a) >>> b[4:0]; // sra
                            default: result = 0;
                        endcase
                    end
                    // M extension
                    7'b0000001: begin
                        case (f3)
                            3'b000: result = a * b; // mul

                        endcase
                    end
                endcase
            end
        endcase
    end

endmodule
