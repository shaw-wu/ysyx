module ysyx_25010009_exu #(XLEN = 32, IMM_LEN = 32, RS_LEN = 5, OP_LEN = 7, TYPE_LEN = 3) (
	input clk.
	input rst,
	input [IMM_LEN-1:0] imm,
	input [RS_LEN-1:0] rd,
	input [RS_LEN-1:0] rs1,
	input [RS_LEN-1:0] rs2,
	input [2:0] funct3,
	input en
);

endmodule
