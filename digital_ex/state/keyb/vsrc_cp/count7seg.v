`timescale 1ns / 1ps
module count7seg(
	input clk,
	input [7:0] count,
	output reg [6:0] hex0,
	output reg [6:0] hex1
);

reg [7:0] count_1,count_0;
always @(*) begin
	count_0 = count % 8'd10;
	count_1 = count / 8'd10;
end
decode i1 (
	.clk(clk),
	.x(count_1[3:0]),
	.en(1),
	.y(hex1)
);
decode i2 (
	.clk(clk),
	.x(count_0[3:0]),
	.en(1),
	.y(hex0)
);
endmodule
