import enums::*;

module decoder (
    input logic [31:0] data,
    output logic [31:0] imm,
    output instr_t instr,
    output logic [4:0] rs1, rs2, rd,
    output logic [2:0] f3,
    output logic [6:0] f7, opcode
);

    always_comb begin
        opcode = data[6:0];
        rd = data[11:7];
        f3 = data[14:12];
        rs1 = data[19:15];
        rs2 = data[24:20];
        f7 = data[31:25];

        case (data[6:0])
            7'b0010011: begin
                instr = ArithI;
                imm = {{20{data[31]}}, data[31:20]};
            end
            7'b0110011: begin
                instr = ArithR;
                imm = 32'b0;
            end
            7'b1100011: begin
                instr = Branch;
                imm = {{19{data[31]}}, data[31], data[7], data[30:25], data[24:21], 1'b0};
            end
            7'b0010111: begin
                instr = Auipc;
                imm = {data[31:12], 12'b0};
            end
            7'b0110111: begin
                instr = Lui;
                imm = {data[31:12], 12'b0};
            end
            7'b0000011: begin
                instr = Load;
                imm = {{20{data[31]}}, data[31:20]};
            end
            7'b0100011: begin
                instr = Store;
                imm = {{20{data[31]}}, data[31:25], data[11:7]};
            end
            7'b1100111: begin
                instr = Jalr;
                imm = {{20{data[31]}}, data[31:20]};
            end
            7'b1101111: begin
                instr = Jal;
                imm = {{11{data[31]}}, data[31], data[19:12], data[20], data[30:21], 1'b0};
            end
            7'b1110011: begin
                imm = {20'b0, data[31:20]};
                case (f3)
                    3'b000:
                        case (data[31:20])
                            12'h000:
                                instr = Ecall;
                            12'h001:
                                instr = Ebreak;
                            12'h302:
                                instr = Mret;
                            12'h105:
                                instr = Wfi;
                            default:
                                instr = None;
                        endcase
                    3'b001:
                        instr = Csrrw;
                    3'b010:
                        instr = Csrrs;
                    3'b011:
                        instr = Csrrc;
                    3'b101:
                        instr = Csrrwi;
                    3'b110:
                        instr = Csrrsi;
                    3'b111:
                        instr = Csrrci;
                    default:
                        instr = None;
                endcase
            end
            7'b0001111: begin
                instr = Fence;
                imm = {20'b0, data[31:28], data[27:24], data[23:20]};
            end
            default: begin
                instr = None;
                imm = 32'b0;
            end
        endcase
    end

endmodule
