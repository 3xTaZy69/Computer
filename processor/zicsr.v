/* 

    July 15th, 2026

*/

module zicsr (
    input wire rst, clk
);

    reg [31:0] mstatus, misa, mie, mtvec, mscratch, mepc, mcause, mtval, mip;

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

endmodule
