/*

    zicsr.v
    July 15th, 2026 -- July 21th, 2026

    register file for zicsr extension.
    no instruction processing!

*/

module zicsr (
    input wire rst, clk, write, mpcmcamstwe,
    input wire [31:0] wdata,
    input wire [95:0] mepcausestatusw,
    input wire [11:0] addr,
    output reg [31:0] rdata,
    output wire [31:0] mtvecv, mepcv, miev, mstatusv
);
    //         0x300    0x301  0x304 0x305  0x340     0x341  0x342   0x343  0x344
    reg [31:0] mstatus, misa,  mie,  mtvec, mscratch, mepc,  mcause, mtval, mip;

    // reset
    always @(posedge clk) begin
        // reset
        if (rst) begin

            mstatus <= 32'b0;
            // Riscv32IM
            misa <= 32'h40001100;
            mie <= 32'b0;
            mtvec <= 32'b0;
            mscratch <= 32'b0;
            mepc <= 32'b0;
            mcause <= 32'b0;
            mtval <= 32'b0;
            mip <= 32'b0;

        end
    end

    // register reading
    always @(*) begin

        case (addr)

            12'h300: rdata = mstatus;
            12'h301: rdata = misa;
            12'h304: rdata = mie;
            12'h305: rdata = mtvec;
            12'h340: rdata = mscratch;
            12'h341: rdata = mepc;
            12'h342: rdata = mcause;
            12'h343: rdata = mtval;
            12'h344: rdata = mip;
            default: rdata = 32'b0;

        endcase

    end

    // register write(using the same address)
    always @(posedge clk) begin
        if ( !rst && mpcmcamstwe ) begin
            mepc <= mepcausestatusw[95:64];
            mcause <= mepcausestatusw[63:32];
            mstatus <= mepcausestatusw[31:0];
        end else if (!rst && write ) begin

            // little copypaste from reset
            case (addr)

            12'h300: mstatus <= wdata;
            // misa is read only, skipped
            12'h304: mie <= wdata;
            12'h305: mtvec <= wdata;
            12'h340: mscratch <= wdata;
            12'h341: mepc <= wdata;
            12'h342: mcause <= wdata;
            12'h343: mtval <= wdata;
            12'h344: mip <= wdata;
            default: begin end

            endcase

        end

    end

    // additional mtvec reading output for faster interrupts
    assign mtvecv = mtvec;
    assign mepcv = mepc;
    assign miev = mie;
    assign mstatusv = mstatus;

endmodule
