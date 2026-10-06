module seq_alu (
    input            clk,
    input            rst,
    input      [1:0] a,
    input      [1:0] b,
    input            sel,
    output reg [1:0] y
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y <= 2'b00;
        end else begin
            if (sel)
                y <= a | b;  // OR operation
            else
                y <= a & b;  // AND operation
        end
    end

endmodule
