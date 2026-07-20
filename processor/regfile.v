module regfile (
    input wire [31:0] wdata, 
    input wire clk, write, rst,
    output wire [31:0] rdata1, rdata2,
    input wire [4:0] rs1, rs2, rd
);
    reg [31:0] registers [31:0];

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (write && rd != 5'b0) begin
            registers[rd] = wdata;
        end
    end

    assign rdata1 = (rs1 == 0) ? 0 : (rs1 == rd) ? wdata : registers[rs1];
    assign rdata2 = (rs2 == 0) ? 0 : (rs1 == rd) ? wdata : registers[rs2];
endmodule
