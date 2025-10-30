module ebreak(
	input clk      ,
	input ebreak   ,
	input [31:0] pc,
	input [31:0] snpc,
	input [31:0] dnpc,
	input [31:0] inst,
	input [4 :0] rd	 ,
	input [4 :0] rs1 ,
	input        jal ,
	input        jalr,
	input speec
);

import "DPI-C" function void is_ebreak(int unsigned ebreak, int unsigned pc, int unsigned snpc, int unsigned dnpc, int unsigned inst, int unsigned rd, int unsigned rs1, int unsigned jal, int unsigned jalr, int unsigned speec);

always @(posedge clk)
	is_ebreak({31'b0, ebreak}, pc, snpc, dnpc, inst, {27'b0, rd}, {27'b0, rs1}, {31'b0, jal}, {31'b0, jalr}, {31'b0, speec});

endmodule
