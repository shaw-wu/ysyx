module ysyx_25010009_wbu #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 32,
	parameter RS_WIDTH   = 5 ,
	parameter CAR_WIDTH  = 12 
)(
	input clk,
	input rst,
`ifdef VERILATOR
	input										 ebreak,
	input		[DATA_WIDTH  -1:0] a0  ,
//	input [DATA_WIDTH  -1:0] inst  ,
//	input [ADDR_WIDTH  -1:0] snpc	 ,
//	input [ADDR_WIDTH  -1:0] dnpc	 ,
//	input [RS_WIDTH    -1:0] rs1   ,
//	input                    jal	 ,
//	input										 jalr  ,
`endif
	input										 lsu_valid,
	input  [ADDR_WIDTH -1:0] pc		 ,
	// lsu <> wbu
	//input	 								   wbu_valid,	
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

assign rf_gpr_wen   = lsu_valid && regwr;
assign rf_gpr_rd    = rd;
assign rf_gpr_wdata = gpr_res;
assign rf_csr_wen1 = lsu_valid && csr1wr;
assign rf_csr_wen2 = lsu_valid && csr2wr;
assign rf_csr_rd1  = csr_rd1;
assign rf_csr_rd2  = csr_rd2;
assign rf_csr_res1 = csr_res1;
assign rf_csr_res2 = csr_res2;

`ifdef VERILATOR
//ebreak EBREAK(clk, ebreak, pc, snpc, dnpc, inst, rd, rs1, jal, jalr);
ysyx_25010009_ebreak EBREAK(clk, ebreak, a0);

//export "DPI-C" task read_pc;
//task automatic read_pc(output int unsigned rdata); 
//begin
//	rdata = pc;
//end
//endtask
`endif

//reg reg_speec;
//always @(posedge clk or posedge rst) begin
//	if(rst) begin
//		reg_speec <= 0;
//	end else begin
//		reg_speec <= lsu_valid;
//	end
//end
//assign speec = reg_speec;
assign speec = lsu_valid;

//assign wbu_valid = lsu_valid;

endmodule
	
