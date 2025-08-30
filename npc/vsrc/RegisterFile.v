`timescale 1ns / 1ps
module ysyx_25010009_RegisterFile #(
	parameter ADDR_WIDTH = 5, 
	parameter DATA_WIDTH = 32
)(
	input clk,
	input rst,
	input [DATA_WIDTH-1:0] wdata,
	input [ADDR_WIDTH-1:0] waddr,
	input [ADDR_WIDTH-1:0] raddr1,
	input [ADDR_WIDTH-1:0] raddr2,
	output [DATA_WIDTH-1:0] rdata1,
	output [DATA_WIDTH-1:0] rdata2,
	input wen
);

reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];

always @(posedge clk) begin
	if (wen) rf[waddr] <= wdata;
end

assign rdata1 = rf[raddr1];
assign rdata2 = rf[raddr2];

always @(*) begin
	rf[0] = {DATA_WIDTH{1'b0}};
end

endmodule
