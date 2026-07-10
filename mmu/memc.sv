module memc #(
    parameter LEN = 4096
) (
    input logic clk, write,
    input logic [7:0] wdata, 
    input logic [31:0] addr,
    output logic [7:0] rdata
);
    logic [7:0] ram [0:LEN-1];

    always_ff @(posedge clk) begin
        if (write)
            ram[addr[$clog2(LEN)-1:0]] <= wdata;

        rdata <= ram[addr[$clog2(LEN)-1:0]];
    end
endmodule
