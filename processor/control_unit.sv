/* 
    
    control_unit.sv
    July 16th, 2026 - July 20th, 2026

    memory access: Von Neumanns architecture

    pipeline stages: IF - ID - EX - LW - WB

*/

import enums::*;


module control_unit (
    input logic clk, rst
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
    // configurable fork of standard clock for regfile
    logic _regfile_clk = clk;
    logic _regfile_write;
    // reset is also configurable for register file
    logic _regfile_rst = rst;
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

    
            

endmodule
