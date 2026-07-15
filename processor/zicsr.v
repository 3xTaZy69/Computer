/* 

    zicsr.v
    July 15th, 2026

    register file for zicsr extension.
    no instruction processing!


*/

module zicsr (
    input wire rst, clk, write,
    input wire [31:0] wdata,
    input wire [11:0] addr,
    output wire [31:0] rdata
);
    //         0x300    0x301  0x304 0x305  0x340     0x341  0x342   0x343  0x344
    reg [31:0] mstatus, misa,  mie,  mtvec, mscratch, mepc,  mcause, mtval, mip;

    // reset
    always @(posedge clk) begin
        // reset
        if (rst) begin

            mstatus <= 32'b0;
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

    // async(not backrooms reference) register reading swithing on address
    always @(*) begin

        case (addr)

            12'h300: rdata = mstatus;
            // misa is read only
            12'h301: rdata = misa;
            12'h304: rdata = mie;
            12'h305: rdata = mtvec;
            12'h340: rdata = mscratch;
            12'h341: rdata = mepc;
            12'h342: rdata = mcause;
            12'h343: rdata = mtval;
            12'h344: rdata = mip;

        endcase

    end

endmodule
