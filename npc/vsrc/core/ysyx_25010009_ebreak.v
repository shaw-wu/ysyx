module ysyx_25010009_ebreak(
	input clk      ,
	input ebreak   ,
	input [31:0] a0
);

`ifdef VERILATOR
//import "DPI-C" function void is_ebreak(int unsigned ebreak, int unsigned pc, int unsigned snpc, int unsigned dnpc, int unsigned inst, int unsigned rd, int unsigned rs1, int unsigned jal, int unsigned jalr);
import "DPI-C" function void is_ebreak(int unsigned ebreak, int unsigned a0);

always @(posedge clk)
	is_ebreak({31'b0, ebreak}, a0);
`endif

endmodule
