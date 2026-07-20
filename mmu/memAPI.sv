/*

    July 13th, 2026

    Temporary simulation-only memory controller

*/

module memAPI (
    input logic clk, write, load,
    input logic [2:0] f3,
    input logic [31:0] wdata, addr,
    output logic [31:0] rdata
);

    logic [7:0] mem [4095:0];

    initial begin
        mem[0] <= 8'h13;
        mem[1] <= 0;
        mem[2] <= 0;
        mem[3] <= 0;

        mem[4] <= 8'h13;
        mem[5] <= 0;
        mem[6] <= 8'h08;
        mem[7] <= 0;
    end

    always_ff @(posedge clk) begin
        if (write) begin
            case (f3)
                3'b000: begin
                    mem[addr] <= wdata[7:0];
                end
                3'b001: begin
                    mem[addr] <= wdata[7:0];
                    mem[addr+1] <= wdata[15:8];
                end
                3'b010: begin
                    mem[addr] <= wdata[7:0];
                    mem[addr+1] <= wdata[15:8];
                    mem[addr+2] <= wdata[23:16];
                    mem[addr+3] <= wdata[31:24];
                end
            endcase
        end

        if (load) begin
            case (f3)
                3'b000: begin
                    logic [7:0] data;
                    data = mem[addr];
                    rdata <= {{24{data[7]}}, data};
                end
                3'b001: begin
                    logic [15:0] data;
                    data = {mem[addr+1], mem[addr]};
                    rdata <= {{16{data[15]}}, data};
                end
                3'b010: begin
                    rdata <= {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                end
                3'b100: begin
                    rdata <= {24'b0, mem[addr]};
                end
                3'b101: begin
                    rdata <= {16'b0, mem[addr+1], mem[addr]};
                end
            endcase
        end
    end
endmodule
