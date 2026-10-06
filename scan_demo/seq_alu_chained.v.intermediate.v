

module __UNIT__UNDER__FINANGLING__
(
  clk,
  rst,
  a,
  b,
  sel,
  y,
  sin,
  shift,
  sout,
  tck,
  test
);

  input sin;
  output sout;
  input shift;
  input tck;
  input test;
  wire __clk_source__;
  wire [1:0] _00_;
  wire _01_;
  wire _02_;
  wire _03_;
  wire _04_;
  wire _05_;
  wire _06_;
  input [1:0] a;
  input [1:0] b;
  input clk;
  input rst;
  input sel;
  output [1:0] y;

  NAND2X1
  _07_
  (
    .A(_05_),
    .B(_06_),
    .Y(_00_[1])
  );


  INVX1
  _08_
  (
    .A(rst),
    .Y(_02_)
  );


  INVX1
  _09_
  (
    .A(rst),
    .Y(_01_)
  );


  NAND2X1
  _10_
  (
    .A(sel),
    .B(b[0]),
    .Y(_03_)
  );


  OAI21X1
  _11_
  (
    .A(sel),
    .B(b[0]),
    .C(a[0]),
    .Y(_04_)
  );


  NAND2X1
  _12_
  (
    .A(_03_),
    .B(_04_),
    .Y(_00_[0])
  );


  NAND2X1
  _13_
  (
    .A(sel),
    .B(b[1]),
    .Y(_05_)
  );


  OAI21X1
  _14_
  (
    .A(sel),
    .B(b[1]),
    .C(a[1]),
    .Y(_06_)
  );


  DFFSR
  _15_
  (
    .CLK(__clk_source__),
    .D((shift)? sin : _00_[0]),
    .Q(y[0]),
    .R(_01_),
    .S(1'h1)
  );


  DFFSR
  _16_
  (
    .CLK(__clk_source__),
    .D((shift)? y[0] : _00_[1]),
    .Q(y[1]),
    .R(_02_),
    .S(1'h1)
  );

  assign sout = y[1];
  assign __clk_source__ = (test)? tck : clk;

endmodule



module BoundaryScanRegister_input
(
  din,
  dout,
  sin,
  sout,
  clock,
  reset,
  testing,
  shift
);

  input din;
  output dout;
  input sin;
  output sout;
  input clock;input reset;input testing;input shift;
  reg store;

  always @(posedge clock or posedge reset) begin
    if(reset) begin
      store <= 1'b0;
    end else begin
      store <= (shift)? sin : dout;
    end
  end

  assign sout = store;
  assign dout = (testing)? store : din;

endmodule



module BoundaryScanRegister_output
(
  din,
  dout,
  sin,
  sout,
  clock,
  reset,
  testing,
  shift
);

  input din;
  output dout;
  input sin;
  output sout;
  input clock;input reset;input testing;input shift;
  reg store;

  always @(posedge clock or posedge reset) begin
    if(reset) begin
      store <= 1'b0;
    end else begin
      store <= (shift)? sin : dout;
    end
  end

  assign sout = store;
  assign dout = din;

endmodule



module seq_alu
(
  clk,
  rst,
  a,
  b,
  sel,
  y,
  sin,
  shift,
  sout,
  tck,
  test
);

  wire __sin_0__;
  wire __sin_1__;
  wire __sin_2__;
  wire __sin_3__;
  wire __sin_4__;
  wire __sin_5__;
  wire __sin_6__;
  wire __sin_7__;
  wire __sin_8__;
  input sin;
  output sout;
  input rst;
  input shift;
  input tck;
  input test;
  input clk;
  assign __sin_0__ = sin;
  input [1:0] a;
  wire [1:0] a__dout;

  BoundaryScanRegister_input
  __BoundaryScanRegister_input_0__
  (
    .din(a[0]),
    .dout(a__dout[0]),
    .sin(__sin_0__),
    .sout(__sin_1__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );


  BoundaryScanRegister_input
  __BoundaryScanRegister_input_1__
  (
    .din(a[1]),
    .dout(a__dout[1]),
    .sin(__sin_1__),
    .sout(__sin_2__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  input [1:0] b;
  wire [1:0] b__dout;

  BoundaryScanRegister_input
  __BoundaryScanRegister_input_2__
  (
    .din(b[0]),
    .dout(b__dout[0]),
    .sin(__sin_2__),
    .sout(__sin_3__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );


  BoundaryScanRegister_input
  __BoundaryScanRegister_input_3__
  (
    .din(b[1]),
    .dout(b__dout[1]),
    .sin(__sin_3__),
    .sout(__sin_4__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  input sel;
  wire sel__dout;

  BoundaryScanRegister_input
  __BoundaryScanRegister_input_4__
  (
    .din(sel),
    .dout(sel__dout),
    .sin(__sin_4__),
    .sout(__sin_5__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  output [1:0] y;
  wire [1:0] y_din;

  BoundaryScanRegister_output
  __BoundaryScanRegister_output_5__
  (
    .din(y_din[0]),
    .dout(y[0]),
    .sin(__sin_6__),
    .sout(__sin_7__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );


  BoundaryScanRegister_output
  __BoundaryScanRegister_output_6__
  (
    .din(y_din[1]),
    .dout(y[1]),
    .sin(__sin_7__),
    .sout(__sin_8__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );


  __UNIT__UNDER__FINANGLING__
  __uuf__
  (
    .clk(clk),
    .rst(rst),
    .a(a__dout),
    .b(b__dout),
    .sel(sel__dout),
    .shift(shift),
    .tck(tck),
    .test(test),
    .sin(__sin_5__),
    .sout(__sin_6__),
    .y(y_din)
  );

  assign sout = __sin_8__;

endmodule


