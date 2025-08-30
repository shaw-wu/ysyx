`timescale 1ns / 1ps
module ysyx_25010009_irom #(
	parameter XLEN = 32
)(
	input  [XLEN-1:0] addr,
	output [XLEN-1:0] inst 
);

import "DPI-C" function int read_irom(int addr);

reg [XLEN-1:0] rdata;
always @(*) begin
	rdata = read_irom(addr);
end

assign inst = rdata;

endmodule
