/*

    July 13th, 2026 -- July 15th, 2026

*/

import enums::*;

module alu (
    input logic [31:0] a, b,
    input logic [6:0] f7,
    input logic [2:0] f3,
    input logic rst, clk,
    input instr_t instr,
    output logic [31:0] result,
    output logic neg, zero, over, carry, stall, divbyzero
);

    logic [32:0] sres;
    assign sres = {1'b0, a} - {1'b0, b};
    assign neg = sres[31];
    assign carry = sres[32];
    assign zero = !sres;
    assign over = (a[31] ^ b[31]) && (a[31] ^ sres[31]);

    logic [31:0] _div_result, _div_rem;
    logic _div_done, _div_start, _div_divu, _div_divbyzero_uncheked;
    divider _div (
        .a(a),
        .b(b),
        .result(_div_result),
        .rem(_div_rem),
        .clk(clk),
        .rst(rst),
        .start(_div_start),
        .done(_div_done),
        .divbyzero(_div_divbyzero_uncheked),
        .divu(_div_divu)
    );

    assign divbyzero = _div_divbyzero_uncheked && (instr == ArithR) && (f7 == 7'b1) && (f3 >= 3'b100 && f3 <= 3'b111);

    // M extension helpers
    logic [63:0] mulhss, mulhsu, mulhuu;
    assign mulhss = $signed({{32{a[31]}}, a}) * $signed({{32{b[31]}}, b});
    assign mulhsu = $signed({{32{a[31]}}, a}) * $signed({32'b0, b});
    assign mulhuu = $unsigned({32'b0, a}) * $unsigned({32'b0, b});


    // TOO MUCH NESTED CASES
    always_comb begin
        // default values
        stall = 1'b0;
        result = 32'b0;
        _div_start = 1'b0;
        _div_divu = 1'b0;

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
                            // hope that it will be fast as clock
                            3'b000: result = $signed(a) * $signed(b); // mul
                            3'b001: result = mulhss[63:32]; // mulh
                            3'b010: result = mulhsu[63:32]; // mulhsu
                            3'b011: result = mulhuu[63:32]; // mulhu
                            3'b100: begin // div
                                stall = !_div_done;
                                result = _div_result;
                                _div_start = 1 && !_div_done;
                                _div_divu = 1'b0;
                            end
                            3'b101: begin // divu
                                stall = !_div_done;
                                result = _div_result;
                                _div_start = 1 && !_div_done;
                                _div_divu = 1'b1;
                            end
                            3'b110: begin // rem
                                stall = !_div_done;
                                result = _div_rem;
                                _div_start = 1 && !_div_done;
                                _div_divu = 1'b0;
                            end
                            3'b111: begin // remu
                                stall = !_div_done;
                                result = _div_rem;
                                _div_start = 1 && !_div_done;
                                _div_divu = 1'b1;
                            end

                        endcase
                    end
                endcase
            end
        ArithI: begin
            case (f3)
                3'b000: result = a + b; // addi
                3'b001: result = a << b[4:0]; // slli
                3'b010: result = $signed(a) < $signed(b); // slti
                3'b011: result = $unsigned(a) < $unsigned(b); // sltiu
                3'b100: result = a ^ b; // xori
                3'b101: begin
                    if (b[11:5] == 7'b0)
                        result = a >> b[4:0]; // srli
                    else
                        result = $signed(a) >>> b[4:0]; // srai
                end
                3'b110: result = a | b; // ori
                3'b111: result = a & b; // andi
            endcase
        end
        Load,
        Store,
        Auipc,
        Jal: result = a + b;
        Lui: result = b;
        Jalr: result = (a + b) & ~32'b1;
        default: result = 32'b0;
        endcase
    end

endmodule
