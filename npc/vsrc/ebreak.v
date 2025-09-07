module ebreak(
	input clk      ,
	input ebreak   ,
	input [31:0] a0,
	input [31:0] pc,
	input [31:0] snpc,
	input [31:0] dnpc,
	input [31:0] inst,
	input [4 :0] rd	 ,
	input [4 :0] rs1 ,
	input        jal ,
	input        jalr
);

import "DPI-C" function void is_ebreak(int unsigned ebreak, int unsigned a0, int unsigned pc, int unsigned snpc, int unsigned dnpc, int unsigned inst, int unsigned rd, int unsigned rs1, int unsigned jal, int unsigned jalr);

always @(posedge clk)
	is_ebreak({31'b0, ebreak}, a0, pc, snpc, dnpc, inst, {27'b0, rd}, {27'b0, rs1}, {31'b0, jal}, {31'b0, jalr});

endmodule
