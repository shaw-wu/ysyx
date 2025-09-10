`timescale 1ns / 1ps
module ysyx_25010009_irom #(
	parameter XLEN = 32
)(
	input							rst ,
	input  [XLEN-1:0] addr,
	output [XLEN-1:0] inst 
);

import "DPI-C" function int unsigned dpi_vaddr_read(int unsigned addr, int len, int ren);

reg [XLEN-1:0] wire_rdata;

always @(*) begin
	wire_rdata = dpi_vaddr_read(addr, 4, {31'b0, !rst});
end

assign inst = wire_rdata;

//import "DPI-C" function int read_irom(int addr);
//
//reg [XLEN-1:0] rdata;
//always @(*) begin
//	rdata = read_irom(addr);
//end
//
//assign inst = rdata;

endmodule
