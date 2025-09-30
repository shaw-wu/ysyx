`timescale 1ns / 1ps
module ysyx_25010009_dram#(
	parameter XLEN = 32
)(
	input clk,
	input rst,
	//input							awvalid,
	//input							arvalid,
	input	 [		 3:0] wmask,
	input  [XLEN-1:0] addr ,
	output [XLEN-1:0] rdata, 
	input  [XLEN-1:0] wdata,
	input							wen
);

import "DPI-C" function int unsigned dpi_vaddr_read(int unsigned addr, int len, int ren);
import "DPI-C" function void dpi_vaddr_write(int unsigned addr, int len, int unsigned wdata, int wen);

wire [31:0] len = wmask == 4'b0001 ? 32'd1 :
									wmask == 4'b0011 ? 32'd2 :
									wmask == 4'b1111 ? 32'd4 : 32'd0;

reg [XLEN-1:0] reg_rdata;

always @(posedge clk or posedge rst) begin
	if(wen) begin
		dpi_vaddr_write(addr, len, wdata, {31'b0, wen});
	end else begin
		reg_rdata <= dpi_vaddr_read(addr, len, {31'b0, !wen});
	end
end

assign rdata = reg_rdata;

endmodule
