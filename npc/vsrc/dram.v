`timescale 1ns / 1ps
module ysyx_25010009_dram#(
	parameter XLEN = 32
)(
	input clk,
	input rst,
	input							awvalid,
	input							arvalid,
	input	 [		 3:0] mask ,
	input	 [		 1:0] size ,
	input  [XLEN-1:0] raddr,
	output [XLEN-1:0] rdata, 
	input  [XLEN-1:0] waddr,
	output [XLEN-1:0] wdata 
);

wire [31:0] len = size == 2'b00 ? 32'd1 :
									size == 2'b01 ? 32'd2 :	
									size == 2'b10 ? 32'd4 :	
									size == 2'b11 ? 32'd8 : 32'd0;	
wire [XLEN-1:0] wire_wdata = wdata & {{8{mask[3]}}, {8{mask[2]}}, {8{mask[1]}}, {8{mask[0]}}};

wire [XLEN-1:0] byte_waddr = waddr >> 2;
wire [XLEN-1:0] byte_raddr = raddr >> 2;

//reg [31:0] rf [0:255];
//		
////always @(posedge clk or posedge rst) begin
//always @(posedge clk ) begin
//		if (awvalid) begin
//			rf[byte_waddr] <= rf[byte_waddr] | wire_wdata;
//		end
//end
//
//assign rdata = rf[byte_raddr];

`ifdef VERILATOR
import "DPI-C" function int unsigned dpi_vaddr_read(int unsigned addr, int len, int ren);

reg [XLEN-1:0] wire_rdata;

always @(*) begin
	wire_rdata = dpi_vaddr_read(raddr, len, {31'b0, arvalid});
end

assign rdata = wire_rdata;

import "DPI-C" function void dpi_vaddr_write(int unsigned addr, int len, int unsigned wdata, int wen);

always @(posedge clk) begin
		dpi_vaddr_write(waddr, len, wire_wdata, {31'b0, awvalid});
end
`endif

endmodule
