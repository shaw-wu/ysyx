module ysyx_25010009_lsu #(
	parameter DATA_WIDTH  = 32, 
	parameter ADDR_WIDTH  = 32, 
	parameter RS_WIDTH    = 5 ,
	parameter CAR_WIDTH   = 12
)(
	input clk,
	input rst,
	//exu <> lsu
	input										exu_lsu_valid,
	output									exu_lsu_ready,
`ifdef VERILATOR
	input 									ebreak ,
	input [DATA_WIDTH -1:0] inst	 ,
	input [ADDR_WIDTH -1:0] snpc	 ,
	input [ADDR_WIDTH -1:0] dnpc	 ,
	input [RS_WIDTH   -1:0] rs1		 ,
	input										jal		 ,
	input										jalr	 ,
`endif
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
	output									 awvalid,
	output									 arvalid,
	output [ADDR_WIDTH -1:0] araddr ,
	input  [DATA_WIDTH -1:0] rdata	,
	output [DATA_WIDTH -1:0] awaddr ,
	output [DATA_WIDTH -1:0] wdata	,
	output [            3:0] ram_mask,
	output [            1:0] ram_size,
	// lsu <> wbu
	output									 lsu_wbu_valid,
	input										 lsu_wbu_ready,
`ifdef VERILATOR
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


parameter IDLE = 2'b00;
parameter WAIT    = 2'b01;
parameter WORK    = 2'b11;

reg [1:0] current_state, next_state;

always @(*) begin
	case(current_state)
		IDLE : begin
			if		 (exu_lsu_valid && !memre) next_state = IDLE;
			else if(exu_lsu_valid &&  memre) next_state = WAIT;
			else														 next_state = IDLE;
		end
		WAIT    : begin
			if		  (lsu_wbu_ready &&  exu_lsu_valid && !memre) next_state = IDLE;
			else if (lsu_wbu_ready &&  exu_lsu_valid &&  memre) next_state = WORK;
			else if (lsu_wbu_ready && !exu_lsu_valid					) next_state = IDLE;
			else																							  next_state = WAIT;
		end
		WORK : begin
			next_state = WAIT;
		end
		default : next_state = IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= IDLE;
	end begin
		current_state <= next_state;
	end
end

wire [DATA_WIDTH-1:0] ur_result;
wire [DATA_WIDTH-1:0] sr_result;
wire [DATA_WIDTH-1:0] re_result;

wire [7:0] byte_rdata;
wire [15:0] half_rdata;

//assign ur_result = mem_mask == 4'b0001 ? {24'b0, rdata[7 :0]} :
//									 mem_mask == 4'b0011 ? {16'b0, rdata[15:0]} :
//									 mem_mask == 4'b1111 ?         rdata        : 32'b0;
//assign sr_result = mem_mask == 4'b0001 ? {{24{rdata[7 ]}}, rdata[7 :0]} :
//									 mem_mask == 4'b0011 ? {{16{rdata[15]}}, rdata[15:0]} :
//									 mem_mask == 4'b1111 ?                   rdata        : 32'b0;
//assign re_result = mem_sext ? sr_result : ur_result;

assign byte_rdata =
										paddr[1:0] == 2'b00 ? rdata[7 : 0] :
										paddr[1:0] == 2'b01 ? rdata[15: 8] :
										paddr[1:0] == 2'b10 ? rdata[23:16] : rdata[31:24];
assign half_rdata = 
										paddr[1:0] == 2'b00 ? rdata[15: 0] :
										paddr[1:0] == 2'b01 ? rdata[23: 8] :
										paddr[1:0] == 2'b10 ? rdata[31:16] : 0;
assign ur_result = mem_mask == 4'b0001 ? {24'b0, byte_rdata} :
									 mem_mask == 4'b0011 ? {16'b0, half_rdata} :
									 mem_mask == 4'b1111 ?              rdata  : 32'b0;
assign sr_result = mem_mask == 4'b0001 ? {{24{byte_rdata[7 ]}}, byte_rdata} :
									 mem_mask == 4'b0011 ? {{16{half_rdata[15]}}, half_rdata[15:0]} :
									 mem_mask == 4'b1111 ? rdata : 32'b0;
assign re_result = mem_sext ? sr_result : ur_result;

wire [31:0] byte_wdata;
wire [31:0] half_wdata;

assign byte_wdata = paddr[1:0] == 2'b00 ? {24'b0, mwdata[7 : 0]		  	} :
										paddr[1:0] == 2'b01 ? {16'b0, mwdata[7 : 0],  8'b0} :
										paddr[1:0] == 2'b10 ? { 8'b0, mwdata[7 : 0], 16'b0} : {mwdata[7 : 0], 24'b0}; 
assign half_wdata = paddr[1:0] == 2'b00 ? {16'b0, mwdata[15: 0]		  	} :
										paddr[1:0] == 2'b01 ? { 8'b0, mwdata[15: 0],  8'b0} :
										paddr[1:0] == 2'b10 ? {       mwdata[15: 0], 16'b0} : 0; 

wire [3:0] byte_mask;
wire [3:0] half_mask;
assign byte_mask = 
									 paddr[1:0] == 2'b00 ? 4'b0001 :
									 paddr[1:0] == 2'b01 ? 4'b0010 :
									 paddr[1:0] == 2'b10 ? 4'b0100 : 4'b1000; 
assign half_mask = 
									 paddr[1:0] == 2'b00 ? 4'b0011 :
									 paddr[1:0] == 2'b10 ? 4'b1100 : 0; 

//assign lsu_addr = aligned ? paddr & 32'hfffffffc : paddr;
//assign lsu_wdata = mwdata;
//assign lsu_size  = memre							 ? 2'b10 :
//									 mem_mask == 4'b0001 ? 2'b00 :
//									 mem_mask == 4'b0011 ? 2'b01 :
//									 mem_mask == 4'b1111 ? 2'b10 : 2'b00;
//assign lsu_wen = memwr;

assign awvalid = (current_state == IDLE && memwr && exu_lsu_valid);
assign arvalid = (current_state == IDLE && memre && exu_lsu_valid) || current_state == WORK;
assign araddr = paddr;
assign awaddr = paddr;
//assign wdata = mwdata;
assign wdata = mem_mask == 4'b0001 ? byte_wdata :
							 mem_mask == 4'b0011 ? half_wdata :
							 mem_mask == 4'b1111 ? mwdata			: 0;	 
//assign ram_mask = mem_mask;
assign ram_mask = mem_mask == 4'b0001 ? byte_mask :
									mem_mask == 4'b0011 ? half_mask :
									mem_mask == 4'b1111 ? mem_mask	 : 0;
assign ram_size = mem_mask == 4'b0001 ? 0 :
									mem_mask == 4'b0011 ? 1 :
									mem_mask == 4'b1111 ? 2 : 0;

assign lsu_wbu_valid = current_state == WAIT || (current_state == IDLE && exu_lsu_valid && !memre);	
assign exu_lsu_ready = current_state == IDLE || current_state == WORK;

`ifdef VERILATOR
assign wbu_ebreak = ebreak;
assign wbu_inst = inst;
assign wbu_snpc = snpc;
assign wbu_dnpc = dnpc;
assign wbu_rs1  = rs1	;
assign wbu_jal	= jal ;
assign wbu_jalr	= jalr;
`endif
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
