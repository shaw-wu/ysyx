`timescale 1ns / 1ps
module ysyx_25010009_counter#(
	parameter WIDTH = 32
)(
	input clk,
	input rst,
	input en,
	output [WIDTH-1:0] cnt
);

reg [WIDTH-1:0] reg_cnt;

always@(posedge clk or posedge rst) begin
	if(rst) reg_cnt <= 0;
	else if(en) reg_cnt <= reg_cnt + 1;
end

assign cnt = reg_cnt;

endmodule
