module ysyx_25010009_wbu #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 32,
	parameter RS_WIDTH   = 5
)(
	input clk,
	input rst,
	input										 ebreak,
	input  [ADDR_WIDTH -1:0] pc		 ,
	input	 								   regwr ,	
	input  [RS_WIDTH   -1:0] rd		 ,
	input  [DATA_WIDTH -1:0] gpr_res,  
	output [RS_WIDTH   -1:0] rf_rd	,
	output [DATA_WIDTH -1:0] rf_wdata,
	output									 rf_wen  
);

assign rf_wen   = regwr;
assign rf_rd    = rd;
assign rf_wdata = gpr_res;

ebreak EBREAK(clk, ebreak);

endmodule
	
