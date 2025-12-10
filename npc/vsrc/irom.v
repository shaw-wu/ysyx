`timescale 1ns / 1ps
module ysyx_25010009_irom #(
	parameter XLEN = 32
)(
	input							rst ,
	input  [XLEN-1:0] addr,
	output [XLEN-1:0] inst 
);

//reg [31:0] rf [0:255];
//
//wire [31:0] byte_addr = addr >> 2;
//
//assign inst = rf[byte_addr];

`ifdef VERILATOR
import "DPI-C" function int unsigned vaddr_ifetch(int unsigned addr, int len, int ren);

reg [XLEN-1:0] wire_rdata;

always @(*) begin
	wire_rdata = vaddr_ifetch(addr, 4, {31'b0, !rst});
end

assign inst = wire_rdata;
`endif

endmodule
