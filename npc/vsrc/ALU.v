module ysyx_25010009_ALU #(XLEN = 32, AR_LEN = 4) (
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
assign lt   = $signed(x1) < $signed(x2);
assign ltu  = x1 < x2;
assign ge   = $signed(x1) >= $signed(x2);
assign geu  = x1 >= x2;

ysyx_25010009_MuxKeyWithDefault #(1, AR_LEN, XLEN) i0 (
	.out(res),
	.key(code),
	.default_out({XLEN{1'b0}}),
	.lut({4'b0000, add,
				4'b0001, sub,
				4'b0010, mul,
				4'b0011, div,
				4'b0100, remu,
				4'b0101, and_,
				4'b0110, or_,
				4'b0111, xor_,
				4'b1000, sll,
				4'b1001, srl,
				4'b1010, sra,
				4'b1011, lt,
				4'b1100, ltu,
				4'b1101, ge,
				4'b1110, geu
			)
);

endmodule
