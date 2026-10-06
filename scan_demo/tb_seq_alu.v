`timescale 1ns/1ps

module tb_seq_alu;

    reg clk;
    reg rst;
    reg [1:0] a, b;
    reg sel;
    wire [1:0] y;

    seq_alu dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        a = 2'b00;
        b = 2'b00;
        sel = 0;

        #12;
        rst = 0; // release reset

        // Test AND mode (sel = 0)
        a = 2'b11; b = 2'b10; sel = 0;
        #10;
        $display("[AND mode] a=%b, b=%b, sel=%b => y=%b (Expected 10)", a, b, sel, y);

        // Test OR mode (sel = 1)
        a = 2'b01; b = 2'b10; sel = 1;
        #10;
        $display("[OR mode]  a=%b, b=%b, sel=%b => y=%b (Expected 11)", a, b, sel, y);

        // Reset check
        rst = 1;
        #10;
        $display("[Reset]    rst=%b => y=%b (Expected 00)", rst, y);

        $finish;
    end

endmodule
