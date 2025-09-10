`timescale 1ns / 1ps
module ysyx_25010009_dram#(
	parameter XLEN = 32
)(
	input clk,
	input rst,
	input							awvalid,
	input							arvalid,
	input	 [		 3:0] mask ,
	input  [XLEN-1:0] raddr,
	output [XLEN-1:0] rdata, 
	input  [XLEN-1:0] waddr,
	output [XLEN-1:0] wdata 
);

wire [31:0] len = mask == 4'b0001 ? 32'd1 :
									mask == 4'b0011 ? 32'd2 :
									mask == 4'b1111 ? 32'd4 : 32'd0;

import "DPI-C" function int unsigned dpi_vaddr_read(int unsigned addr, int len, int ren);

reg [XLEN-1:0] wire_rdata;

always @(*) begin
	wire_rdata = dpi_vaddr_read(raddr, len, {31'b0, arvalid});
end

assign rdata = wire_rdata;

import "DPI-C" function void dpi_vaddr_write(int unsigned addr, int len, int unsigned wdata, int wen);

always @(posedge clk or posedge rst) begin
		dpi_vaddr_write(waddr, len, wdata, {31'b0, awvalid});
end

endmodule
