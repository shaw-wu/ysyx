module ebreak(
	input clk      ,
	input ebreak   ,
	input [31:0] a0,
	input [31:0] pc
);

import "DPI-C" function void is_ebreak(int ebreak, int a0, int pc);

always @(posedge clk)
	is_ebreak({31'b0, ebreak}, a0, pc);

endmodule
