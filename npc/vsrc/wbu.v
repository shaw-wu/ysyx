module ysyx_25010009_wbu #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 32,
	parameter RS_WIDTH   = 5
)(
	input clk,
	input rst,
`ifdef VERILATOR
	input										 ebreak,
	input [DATA_WIDTH  -1:0] inst  ,
	input [ADDR_WIDTH  -1:0] snpc	 ,
	input [ADDR_WIDTH  -1:0] dnpc	 ,
	input [RS_WIDTH    -1:0] rs1   ,
	input                    jal	 ,
	input										 jalr  ,
`endif
	input  [ADDR_WIDTH -1:0] pc		 ,
	// lsu <> wbu
	input	 								   regwr ,	
	input  [RS_WIDTH   -1:0] rd		 ,
	input  [DATA_WIDTH -1:0] gpr_res,  
	// wbu <> rf
	output [RS_WIDTH   -1:0] rf_rd	,
	output [DATA_WIDTH -1:0] rf_wdata,
	output									 rf_wen  ,
	output									 speec
);

assign rf_wen   = regwr;
assign rf_rd    = rd;
assign rf_wdata = gpr_res;

`ifdef VERILATOR
ebreak EBREAK(clk, ebreak, pc, snpc, dnpc, inst, rd, rs1, jal, jalr);

export "DPI-C" task read_pc;
task automatic read_pc(output int unsigned rdata); 
begin
	rdata = pc;
end
endtask
`endif

reg reg_speec;

always @(posedge clk or posedge rst) begin
	if(rst) reg_speec <= 0;
	else		reg_speec <= 1;
end

assign speec = reg_speec;

endmodule
	
