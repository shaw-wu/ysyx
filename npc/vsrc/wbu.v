module ysyx_25010009_wbu #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 32,
	parameter RS_WIDTH   = 5 ,
	parameter CAR_WIDTH  = 12 
)(
	input clk,
	input rst,
	input										 lsu_wbu_valid,
	output									 lsu_wbu_ready,
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
	input	 								   csr1wr,	
	input	 								   csr2wr,	
	input [RS_WIDTH   -1:0] rd		 ,
	input [DATA_WIDTH -1:0] gpr_res,  
	input [CAR_WIDTH  -1:0] csr_rd1	,
	input [CAR_WIDTH  -1:0] csr_rd2	,
	input [DATA_WIDTH -1:0] csr_res1,
	input [DATA_WIDTH -1:0] csr_res2,   
	// wbu <> rf
	output [CAR_WIDTH  -1:0] rf_csr_rd1	,
	output [CAR_WIDTH  -1:0] rf_csr_rd2	,
	output [DATA_WIDTH -1:0] rf_csr_res1,
	output [DATA_WIDTH -1:0] rf_csr_res2,   
	output									 rf_csr_wen1,
	output									 rf_csr_wen2,
	output [RS_WIDTH   -1:0] rf_gpr_rd	,
	output [DATA_WIDTH -1:0] rf_gpr_wdata,
	output									 rf_gpr_wen  ,
	output									 speec
);

assign rf_gpr_wen   = regwr && lsu_wbu_valid;
assign rf_gpr_rd    = rd;
assign rf_gpr_wdata = gpr_res;
assign rf_csr_wen1 = csr1wr && lsu_wbu_valid;
assign rf_csr_wen2 = csr2wr && lsu_wbu_valid;
assign rf_csr_rd1  = csr_rd1;
assign rf_csr_rd2  = csr_rd2;
assign rf_csr_res1 = csr_res1;
assign rf_csr_res2 = csr_res2;

assign lsu_wbu_ready = 1;

`ifdef VERILATOR
ebreak EBREAK(clk, ebreak, pc, snpc, dnpc, inst, rd, rs1, jal, jalr, speec);

export "DPI-C" task read_pc;
task automatic read_pc(output int unsigned rdata); 
begin
	rdata = pc;
end
endtask
`endif

//reg reg_speec;
//
//always @(posedge clk or posedge rst) begin
//	if(rst) reg_speec <= 0;
//	else begin
//		if(lsu_wbu_valid) reg_speec <= 1;
//	end
//end

assign speec = lsu_wbu_valid;

endmodule
	
