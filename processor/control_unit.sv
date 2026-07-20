
/*

    control_unit.sv
    July 16th, 2026 - July 20th, 2026

    memory access: Von Neumanns architecture

    pipeline stages: IF - ID - EX - MEM - WB


*/

import enums::*;


module control_unit (
    input logic clk, rst, mtip
);

    // decoder module
    logic [31:0] _decoder_data, _decoder_imm;
    logic [4:0] _decoder_rs1, _decoder_rs2, _decoder_rd;
    logic [2:0] _decoder_f3;
    logic [6:0] _decoder_f7, _decoder_opcode;
    instr_t _decoder_instr;



    decoder _decoder (
        .data(_decoder_data),
        .imm(_decoder_imm),
        .instr(_decoder_instr),
        .rs1(_decoder_rs1),
        .rs2(_decoder_rs2),
        .rd(_decoder_rd),
        .f3(_decoder_f3),
        .f7(_decoder_f7),
        .opcode(_decoder_opcode)
    );


    // register file module
    logic [31:0] _regfile_wdata, _regfile_rdata1, _regfile_rdata2;
    logic _regfile_write, _regfile_clk, _regfile_rst;
    // configurable fork of standard clock for regfile
    assign _regfile_clk = clk;
    // reset is also configurable for register filer
    assign _regfile_rst = rst;
    logic [4:0] _regfile_rs1, _regfile_rs2, _regfile_rd;

    regfile _regfile (
        .wdata(_regfile_wdata),
        .clk(_regfile_clk),
        .write(_regfile_write),
        .rst(_regfile_rst),
        .rdata1(_regfile_rdata1),
        .rdata2(_regfile_rdata2),
        .rs1(_regfile_rs1),
        .rs2(_regfile_rs2),
        .rd(_regfile_rd)
    );


    // zicsr module
    logic _zicsr_write, _zicsr_clk, _zicsr_rst;
    logic [31:0] _zicsr_wdata, _zicsr_rdata, _zicsr_mtvecv, _zicsr_mepcv;
    logic [11:0] _zicsr_addr;
    // configurable clk and rst for zicsr module
    assign _zicsr_clk = clk;
    assign _zicsr_rst = rst;

    zicsr _zicsr (
        .rst(_zicsr_rst),
        .clk(_zicsr_clk),
        .write(_zicsr_write),
        .wdata(_zicsr_wdata),
        .addr(_zicsr_addr),
        .rdata(_zicsr_rdata),
        .mtvecv(_zicsr_mtvecv),
        .mepcv(_zicsr_mepcv)
    );


    // alu module
    logic [31:0] _alu_a, _alu_b, _alu_result;
    logic [6:0] _alu_f7;
    logic [2:0] _alu_f3;
    // important pins
    logic _alu_rst, _alu_clk, _alu_stall;
    instr_t _alu_instr;
    // _alu_divbyzero as _alu_dbz
    logic _alu_zero, _alu_neg, _alu_over, _alu_carry, _alu_dbz;
    // configurable rst and clock for alu(its divider)
    assign _alu_clk = clk;
    assign _alu_rst = rst;

    alu _alu (
        .a(_alu_a),
        .b(_alu_b),
        .f7(_alu_f7),
        .f3(_alu_f3),
        .rst(_alu_rst),
        .clk(_alu_clk),
        .instr(_alu_instr),
        .result(_alu_result),
        .neg(_alu_neg),
        .zero(_alu_zero),
        .over(_alu_over),
        .carry(_alu_carry),
        .divbyzero(_alu_dbz)
    );


    // memory module(simulation only for now)
    logic _mem_clk, _mem_write, _mem_load;
    logic [2:0] _mem_f3;
    logic [31:0] _mem_wdata, _mem_addr, _mem_rdata;
    // configurable clk(no rst)
    assign _mem_clk = clk;

    memAPI _mem (
        .clk(_mem_clk),
        .write(_mem_write),
        .load(_mem_load),
        .f3(_mem_f3),
        .wdata(_mem_wdata),
        .addr(_mem_addr),
        .rdata(_mem_rdata)
    );


    // pipeline and utilites

    logic do_branch;
    initial do_branch = 0;

    always_comb begin
        case (_alu_f3)
            // beq
            3'b000: do_branch = _alu_zero;
            // bne
            3'b001: do_branch = ~_alu_zero;
            // blt
            3'b100: do_branch = _alu_neg ^ _alu_over;
            // bge
            3'b101: do_branch = _alu_neg & _alu_over;
            // bltu
            3'b110: do_branch = ~_alu_carry;
            // bgeu
            3'b111: do_branch = _alu_carry;
        endcase
    end

    typedef enum logic [2:0] { IF, ID, EX, MEM, WB } cfsm;

    cfsm state;
    logic stall;

    logic [31:0] pc, pc_next;
    // optimization
    logic [31:0] p4;
    assign p4 = pc + 4;

    logic do_rwrite;

    assign _regfile_rs1 = _decoder_rs1;
    assign _regfile_rs2 = _decoder_rs2;

    logic msip;

    // test FSM
    always_ff @(posedge clk) begin
        if ( rst ) begin
            state <= IF;
            stall <= 0;
            _decoder_data <= 0;
            pc <= 0;
            pc_next <= 0;
            do_branch <= 0;
            do_rwrite <= 0;

            // load instruction
            _mem_load <= 1;
            _mem_f3 <= 3'b010;
            _mem_addr <= 0;
        end else if ( !stall ) begin
            case (state)
                IF: begin
                    state <= ID;

                    pc <= pc_next;

                    // help for IF to get its instruction
                    _mem_load <= 1;
                    // pc_next because pc will only be updated after IF
                    _mem_addr <= pc_next;
                    _mem_f3 <= 3'b010;

                end
                ID: begin
                    state <= EX;

                    _decoder_data <= _mem_rdata;
                    _mem_load <= 0;
                end
                EX: begin
                    state <= MEM;

                    case ( _decoder_instr )
                        ArithI: begin
                            _alu_a <= _regfile_rdata1;
                            _alu_b <= _decoder_imm;
                        end
                        ArithR, Branch: begin
                            _alu_a <= _regfile_rdata1;
                            _alu_b <= _regfile_rdata2;
                        end
                        Auipc, Load, Store, Jal, Jalr: begin
                            _alu_a <= pc;
                            _alu_b <= _decoder_imm;
                        end
                        Lui: begin
                            _alu_a <= 0;
                            // _alu_result is _alu_b
                            _alu_b <= _decoder_imm;
                        end
                        // zim - rs1
                        Csrrw, Csrrs, Csrrc, Csrrwi, Csrrsi, Csrrci: begin
                            _alu_a <= 0;
                            _alu_b <= 0;
                            _zicsr_addr <= _decoder_imm[11:0];
                        end
                        Fence: begin
                            _alu_a <= 0;
                            _alu_b <= 0;
                        end
                        Ecall, Ebreak: begin
                            _alu_a <= 0;
                            _alu_b <= 0;
                        end
                        Mret: begin
                            _alu_a <= 0;
                            _alu_b <= 0;
                        end
                        Wfi: begin
                            _alu_a <= 0;
                            _alu_b <= 0;
                        end
                    endcase

                end
                MEM:begin
                    state <= WB;


                end
                WB: begin
                    state <= IF;

                    case ( _decoder_instr )
                        Branch: pc_next <= do_branch ? pc + _decoder_imm : p4;
                        Jal, Jalr: pc_next <= _alu_result;
                        Mret: pc_next <= _zicsr_mepcv;
                        default: pc_next <= p4;
                    endcase
                end
            endcase
        end
    end


endmodule
