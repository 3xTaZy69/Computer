module regfile (
    input wire [31:0] wdata, 
    input wire clk, write,
    output wire [31:0] rdata1, rdata2,
    input wire [4:0] rs1, rs2, rd
);
    reg [31:0] registers [31:0];

    initial begin
        for (integer i = 0; i <= 31; i = i + 1)
            registers[i] = 0;
    end

    always @(posedge clk) begin
        if (write && rd != 0)
            registers[rd] <= wdata;
    end

    assign rdata1 = (rs1 == 0) ? 0 : registers[rs1];
    assign rdata2 = (rs2 == 0) ? 0 : registers[rs2];
endmodule
