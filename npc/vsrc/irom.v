`timescale 1ns / 1ps
module ysyx_25010009_irom #(
	parameter XLEN = 32
)(
	input							rst ,
	input  [XLEN-1:0] addr,
	output [XLEN-1:0] inst 
);

//reg [31:0] rf [0:255];
//always @(posedge clk or posedge rst) begin
//	if(rst) begin
//		integer i;
//		for(i = 0; i < 256; i=i+1) begin
//			rf[i] = {DATA_WIDTH{1'b0}};
//		end
//end
//assign inst = rf[addr >> 2];
`ifdef VERILATOR
import "DPI-C" function int unsigned vaddr_ifetch(int unsigned addr, int len, int ren);

reg [XLEN-1:0] wire_rdata;

always @(*) begin
	wire_rdata = vaddr_ifetch(addr, 4, {31'b0, !rst});
end

assign inst = wire_rdata;
`endif

//import "DPI-C" function int read_irom(int addr);
//
//reg [XLEN-1:0] rdata;
//always @(*) begin
//	rdata = read_irom(addr);
//end
//
//assign inst = rdata;

endmodule
