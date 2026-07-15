package enums;
    typedef enum logic [5:0] { 
        ArithI,
        ArithR,
        Branch,
        Auipc,
        Lui,
        Load,
        Store,
        Jalr,
        Jal,
        
        // zicsr
        Csrr,
        Csrrw,
        Csrrs,
        Csrrc,
        Csrrwi,
        Csrrsi,
        Csrrci,

        // fence
        Fence,

        // system
        Ecall,
        Ebreak,
        Mret,
        Wfi,

        None
    } instr_t;
endpackage
