/* 

    July 13th, 2026

*/

module divider (
    input logic [31:0] a, b,
    output logic [31:0] result, rem,
    input logic clk, rst, start, divu,
    output logic done, divbyzero
);
    typedef enum logic [2:0] {IDLE, RUN, DONE} state_t;

    state_t state;

    logic [31:0] a_abs, b_abs;
    logic doneg;


    always_comb begin
        if (a[31] && !divu)
            a_abs = ~a + 1;
        else
            a_abs = a;

        if (b[31] && !divu)
            b_abs = ~b + 1;
        else
            b_abs = b;

        if (a[31] ^ b[31] && !divu)
            doneg = 1;
        else
            doneg = 0;
    end

    logic [4:0] count;
    logic [63:0] remres;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            done <= 1'b0;
            count <= 5'b0;
            remres <= 64'b0;
        end
        case (state)
            IDLE: begin
                done <= 1'b0;
                if (start) begin

                    if (!b) begin
                        state <= DONE;
                    end else if (a == 32'h80000000 && b == 32'hffffffff && !divu) begin 
                        state <= DONE;
                    end else if (divu && b[31]) begin
                        state <= DONE;
                    end else begin
                        state <= RUN;
                    end
                end
                
                remres <= {32'b0, a_abs};
                count <= 0;

            end
            RUN: begin
                logic [63:0] shifted;
                logic [31:0] new_rem;
                logic new_qb;

                shifted = remres << 1;

                
                if (shifted[63] == 0) begin
                    new_rem = shifted[63:32] - b_abs;
                end else begin
                    new_rem = shifted[63:32] + b_abs;
                end
                
                if (count == 5'b11111)
                    state <= DONE;
                
                new_qb = new_rem[31] ? 1'b0 : 1'b1;
                count <= count + 1;
                remres <= {new_rem, shifted[31:1], new_qb};
                
            end
            DONE: begin
                state <= IDLE;
                done <= 1'b1;

                if (b == 32'b0) begin
                    result <= 32'hffffffff;
                    rem <= a;
                end else if (a == 32'h80000000 && b == 32'hffffffff && !divu) begin
                    result <= 32'h80000000;
                    rem <= 32'b0;
                end else if (divu && b[31]) begin 
                    if (a >= b) begin
                        result <= 32'b1;
                        rem <= a - b;
                    end else begin
                        result <= 32'b0;
                        rem <= a;
                    end
                end else begin
                    result <= doneg ? ~remres[31:0] + 1 : remres[31:0];
                    if (remres[63])
                        rem <= a[31] && !divu ? ~(remres[63:32] + b_abs) + 1 : (remres[63:32] + b_abs);
                    else
                        rem <= a[31] && !divu ? ~remres[63:32] + 1 : remres[63:32];
                end
                
            end
                
        default: begin end
        endcase
    end

    assign divbyzero = !b;


endmodule
