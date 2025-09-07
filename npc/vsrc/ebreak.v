module ebreak(
	input clk      ,
	input ebreak   ,
	input [31:0] a0,
	input [31:0] pc,
	input [31:0] snpc,
	input [31:0] inst
);

import "DPI-C" function void is_ebreak(int unsigned ebreak, int unsigned a0, int unsigned pc, int unsigned snpc, int unsigned inst);

always @(posedge clk)
	is_ebreak({31'b0, ebreak}, a0, pc, snpc, inst);

endmodule
