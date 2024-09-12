module count7seg(
	input clk,
	input [4:0] count,
	output reg [6:0] hex0,
	output reg [6:0] hex1
);

decode i1 (
	.clk(clk),
	.x({3'b000,count[4]}),
	.en(1),
	.y(hex0)
);
decode i2 (
	.clk(clk),
	.x(count[3:0]),
	.en(1),
	.y(hex1)
);
endmodule
