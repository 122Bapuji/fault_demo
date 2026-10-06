module tb;

reg A, B, SEL;
wire Y;

tiny_alu dut (
    .A(A),
    .B(B),
    .SEL(SEL),
    .Y(Y)
);

initial begin

    $display("A B SEL | Y");

    A=0; B=0; SEL=0; #1;
    $display("%b %b  %b  | %b", A,B,SEL,Y);

    A=0; B=1; SEL=0; #1;
    $display("%b %b  %b  | %b", A,B,SEL,Y);

    A=1; B=0; SEL=0; #1;
    $display("%b %b  %b  | %b", A,B,SEL,Y);

    A=1; B=1; SEL=0; #1;
    $display("%b %b  %b  | %b", A,B,SEL,Y);

    A=0; B=0; SEL=1; #1;
    $display("%b %b  %b  | %b", A,B,SEL,Y);

    A=0; B=1; SEL=1; #1;
    $display("%b %b  %b  | %b", A,B,SEL,Y);

    A=1; B=0; SEL=1; #1;
    $display("%b %b  %b  | %b", A,B,SEL,Y);

    A=1; B=1; SEL=1; #1;
    $display("%b %b  %b  | %b", A,B,SEL,Y);

    $finish;

end

endmodule
