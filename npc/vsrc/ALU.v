module ysyx_25010009_ALU #(XLEN = 32, AR_LEN = 5) (
	input [AR_LEN-1:0] code,
	input [XLEN-1:0] x1,
	input [XLEN-1:0] x2,
	output [XLEN-1:0] res
);

wire [XLEN-1:0] add;
wire [XLEN-1:0] sub;
wire [XLEN-1:0] mul;
wire [XLEN-1:0] div;
wire [XLEN-1:0] remu;
wire [XLEN-1:0] and_;
wire [XLEN-1:0] or_;
wire [XLEN-1:0] xor_;
wire [XLEN-1:0] sll;
wire [XLEN-1:0] srl;
wire [XLEN-1:0] sra;
wire [XLEN-1:0] ltu;
wire [XLEN-1:0] geu;
wire [XLEN-1:0] eq;
wire [XLEN-1:0] ne;

assign add  = x1 + x2;
assign sub  = x1 - x2;
assign mul  = x1 * x2;
assign div  = x1 / x2;
assign remu = x1 % x2;
assign and_ = x1 & x2;
assign or_  = x1 | x2;
assign xor_ = x1 ^ x2;
assign sll  = x1 << x2[4:0] 
assign srl  = x1 >> x2[4:0];
assign sra  = $signed(x1) >>> x2[4:0];
assign ltu  = x1 < x2;
assign geu  = x1 >= x2;
assign ne   = x1 == x2;
assign eq   = x1 != x2;

ysyx_25010009_MuxKeyWithDefault #(1, AR_LEN, XLEN) i0 (
	.out(res),
	.key(code),
	.default_out({XLEN{1'b0}}),
	.lut({0'b00000, add,
				0'b00001, sub,
				0'b00010, mul,
				0'b00011, div,
				0'b00100, remu,
				0'b00101, and_,
				0'b00110, or_,
				0'b00111, xor_,
				0'b01000, sll,
				0'b01001, srl,
				0'b01010, sra,
				0'b01011, ltu,
				0'b01100, geu,
				0'b01101, eq,
				0'b01110, ne})
);

endmodule
