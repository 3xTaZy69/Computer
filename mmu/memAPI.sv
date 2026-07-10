module memAPI (
    input logic clk, write,
    input logic [2:0] f3,
    input logic [31:0] wdata, addr,
    output logic [31:0] rdata 
);
    /*
    logic wdata8, addr8, rdata8, mclk;
    logic [2:0] state;

    memc m (
        .clk (mclk),
        .write (write),
        .wdata (wdata8),
        .addr (addr8),
        .rdata (rdata8)
    );

    initial begin
        wdata8 = 0;
        addr8 = 0;
        rdata8 = 0;
        state = 0;
        mclk = 0;
    end


    always_ff @(posedge clk) begin
        if (state == 0) begin
            
        end
    end
    */

    
endmodule
