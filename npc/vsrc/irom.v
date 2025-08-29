`timescale 1ns / 1ps
module ysyx_25010009_irom #(
	parameter XLEN = 32
)(
	input  [XLEN-1:0] addr,
	output [XLEN-1:0] rdata
);

import "DPI-C" function uint32_t read_irom(uint32_t addr);

always @(*) begin
	rdata = read_irom(addr);
end

endmodule
