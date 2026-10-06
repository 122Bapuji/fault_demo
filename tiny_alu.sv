module tiny_alu (
    input  A,
    input  B,
    input  SEL,
    output Y
);

wire and_out;
wire or_out;

assign and_out = A & B;
assign or_out  = A | B;

assign Y = SEL ? or_out : and_out;

endmodule

