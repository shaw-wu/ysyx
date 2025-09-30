module ysyx_25010009_lsu #(
	parameter DATA_WIDTH  = 32, 
	parameter ADDR_WIDTH  = 32, 
	parameter RS_WIDTH    = 5 ,
	parameter CAR_WIDTH   = 12
)(
	input clk,
	input rst,
	//exu <> lsu
`ifdef VERILATOR
	input 									ebreak ,
	input [DATA_WIDTH -1:0] inst	 ,
	input [ADDR_WIDTH -1:0] snpc	 ,
	input [ADDR_WIDTH -1:0] dnpc	 ,
	input [RS_WIDTH   -1:0] rs1		 ,
	input										jal		 ,
	input										jalr	 ,
`endif
  input										exu_valid,
	input [ADDR_WIDTH -1:0] pc		 ,
	input [DATA_WIDTH -1:0] mwdata ,
	input										memwr  ,
	input	 								 	memre  ,
	input	 								 	regwr  ,	
	input	 								 	csr1wr ,	
	input	 								 	csr2wr ,	
	input	[						 3:0] mem_mask,	
	input	                  mem_sext,	
	input [DATA_WIDTH -1:0] paddr  ,
	input [RS_WIDTH   -1:0] gpr_rd ,
	input [DATA_WIDTH -1:0] gpr_res,
	input [CAR_WIDTH  -1:0] csr_rd1	,
	input [CAR_WIDTH  -1:0] csr_rd2	,
	input [DATA_WIDTH -1:0] csr_res1,
	input [DATA_WIDTH -1:0] csr_res2,   
	// lsu <> ram
	//output									 awvalid,
	//output									 arvalid,
	output [ADDR_WIDTH -1:0] lsu_addr ,
	input  [DATA_WIDTH -1:0] lsu_rdata,
	output [DATA_WIDTH -1:0] lsu_wdata,
	output [            3:0] lsu_wmask,
	output									 lsu_wen	,
	// lsu <> wbu
`ifdef VERILATOR
	output									 lsu_valid ,
	output 									 wbu_ebreak,
	output [DATA_WIDTH -1:0] wbu_inst	 ,
	output [ADDR_WIDTH -1:0] wbu_snpc	 ,
	output [ADDR_WIDTH -1:0] wbu_dnpc	 ,
	output [RS_WIDTH   -1:0] wbu_rs1	 ,
	output									 wbu_jal	 ,
	output									 wbu_jalr	 ,
`endif
	output [ADDR_WIDTH -1:0] wbu_pc		 ,
	output	 								 wbu_regwr ,	
	output	 								 wbu_csr1wr,	
	output	 								 wbu_csr2wr,	
	output [RS_WIDTH   -1:0] wbu_gpr_rd	,
	output [DATA_WIDTH -1:0] wbu_gpr_res,
	output [CAR_WIDTH  -1:0] wbu_csr_rd1 ,
	output [CAR_WIDTH  -1:0] wbu_csr_rd2 ,
	output [DATA_WIDTH -1:0] wbu_csr_res1,
	output [DATA_WIDTH -1:0] wbu_csr_res2 
);

parameter IDLE = 1'b0;
parameter WORK = 1'b1;

reg current_state, next_state;

always @(*) begin
	case(current_state)
		IDLE : if(exu_valid) next_state = WORK;
		WORK :							 next_state = IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= IDLE;
	end else begin
		current_state <= next_state;
	end
end

wire [DATA_WIDTH-1:0] ur_result;
wire [DATA_WIDTH-1:0] sr_result;
wire [DATA_WIDTH-1:0] re_result;
assign ur_result = mem_mask == 4'b0001 ? {24'b0, lsu_rdata[7 :0]} :
									 mem_mask == 4'b0011 ? {16'b0, lsu_rdata[15:0]} :
									 mem_mask == 4'b1111 ?         lsu_rdata        : 32'b0;
assign sr_result = mem_mask == 4'b0001 ? {{24{lsu_rdata[7 ]}}, lsu_rdata[7 :0]} :
									 mem_mask == 4'b0011 ? {{16{lsu_rdata[15]}}, lsu_rdata[15:0]} :
									 mem_mask == 4'b1111 ? lsu_rdata : 32'b0;
assign re_result = mem_sext ? sr_result : ur_result;

//assign awvalid = memwr;
//assign arvalid = memre;
assign lsu_addr = paddr;
assign lsu_wdata = mwdata;
assign lsu_wmask = mem_mask;

`ifdef VERILATOR
assign wbu_ebreak = ebreak;
assign wbu_inst = inst;
assign wbu_snpc = snpc;
assign wbu_dnpc = dnpc;
assign wbu_rs1  = rs1	;
assign wbu_jal	= jal ;
assign wbu_jalr	= jalr;
`endif
assign lsu_valid = current_state == WORK ;
assign wbu_pc = pc;
assign wbu_regwr = regwr;
assign wbu_csr1wr = csr1wr;
assign wbu_csr2wr = csr2wr;
assign wbu_gpr_rd = gpr_rd;
assign wbu_gpr_res = memre ? re_result : gpr_res;
assign wbu_csr_rd1 = csr_rd1;
assign wbu_csr_rd2 = csr_rd2;
assign wbu_csr_res1 = csr_res1;
assign wbu_csr_res2 = csr_res2;

endmodule
