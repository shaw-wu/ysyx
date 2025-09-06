module ysyx_25010009_lsu #(
	parameter DATA_WIDTH  = 32, 
	parameter ADDR_WIDTH  = 32, 
	parameter RS_WIDTH    = 5  
)(
	input clk,
	input rst,
	//exu <> lsu
`ifdef VERILATOR
	input 									 ebreak,
	input [DATA_WIDTH -1:0] a0		 ,
`endif
	input [ADDR_WIDTH -1:0] pc		 ,
	input [DATA_WIDTH -1:0] mwdata,
	input	 								 memwr ,
	input	 								 memre ,
	input	 								 regwr ,	
	input [DATA_WIDTH -1:0] paddr  ,
	input [RS_WIDTH   -1:0] gpr_rd	,
	input [DATA_WIDTH -1:0] gpr_res,
	// lsu <> ram
	output									 awvalid,
	output									 arvalid,
	output [ADDR_WIDTH -1:0] araddr,
	input  [DATA_WIDTH -1:0] rdata,
	output [DATA_WIDTH -1:0] awaddr,
	output [DATA_WIDTH -1:0] wdata,
	// lsu <> wbu
`ifdef VERILATOR
	output 									 wbu_ebreak,
	output [DATA_WIDTH -1:0] wbu_a0		 ,
`endif
	output [ADDR_WIDTH -1:0] wbu_pc		 ,
	output	 								 wbu_regwr ,	
	output [RS_WIDTH   -1:0] wbu_gpr_rd	,
	output [DATA_WIDTH -1:0] wbu_gpr_res
);

assign awvalid = memwr;
assign arvalid = memre;
assign araddr = paddr;
assign awaddr = paddr;
assign wdata = mwdata;

assign wbu_ebreak = ebreak;
assign wbu_a0 = a0;
assign wbu_pc = pc;
assign wbu_regwr = regwr;
assign wbu_gpr_rd = gpr_rd;
assign wbu_gpr_res = memre ? rdata : gpr_res;

endmodule
