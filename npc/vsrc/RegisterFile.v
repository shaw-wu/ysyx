`timescale 1ns / 1ps
module ysyx_25010009_RegisterFile #(
	parameter ADDR_WIDTH = 5, 
	parameter DATA_WIDTH = 32
)(
	input clk,
	input rst,
	input [DATA_WIDTH-1:0] wdata,
	input [ADDR_WIDTH-1:0] waddr,
	output [DATA_WIDTH-1:0] rdata,
	input [ADDR_WIDTH-1:0] raddr,
	input wen
);

reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];

always @(posedge clk) begin
	if (wen) rf[waddr] <= wdata;
end

assign rdata = rf[raddr];

always @(*) begin
	rf[0] = {DATA_WDITH{0}};
end

endmodule
