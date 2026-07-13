import enums::*;

module alu (
    input logic [31:0] a, b,
    input logic [6:0] f7,
    input logic [2:0] f3,
    input instr_t instr,
    output logic [31:0] result,
    output logic neg, over, carry, stall
);
    
endmodule