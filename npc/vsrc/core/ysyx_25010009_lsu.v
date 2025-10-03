module ysyx_25010009_lsu #(
	parameter DATA_WIDTH  = 32, 
	parameter ADDR_WIDTH  = 32, 
	parameter RS_WIDTH    = 5 ,
	parameter CAR_WIDTH   = 12
)(
	input clk,
	input rst,
	//exu <> lsu
//`ifdef VERILATOR
//	input 									ebreak ,
//	input [DATA_WIDTH -1:0] inst	 ,
//	input [ADDR_WIDTH -1:0] snpc	 ,
//	input [ADDR_WIDTH -1:0] dnpc	 ,
//	input [RS_WIDTH   -1:0] rs1		 ,
//	input										jal		 ,
//	input										jalr	 ,
//`endif
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
	output lsu_reqvalid,
	input  lsu_resvalid,
	output [1:0] lsu_size,
	output [ADDR_WIDTH -1:0] lsu_addr ,
	input  [DATA_WIDTH -1:0] lsu_rdata,
	output [DATA_WIDTH -1:0] lsu_wdata,
	output [            3:0] lsu_wmask,
	output									 lsu_wen	,
	output									 lsu_valid ,
	// lsu <> wbu
//`ifdef VERILATOR
//	output 									 wbu_ebreak,
//	output [DATA_WIDTH -1:0] wbu_inst	 ,
//	output [ADDR_WIDTH -1:0] wbu_snpc	 ,
//	output [ADDR_WIDTH -1:0] wbu_dnpc	 ,
//	output [RS_WIDTH   -1:0] wbu_rs1	 ,
//	output									 wbu_jal	 ,
//	output									 wbu_jalr	 ,
//`endif
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

localparam UART_ST = 32'h1000_0000;
localparam UART_EN = 32'h1000_0fff;
localparam SPI_ST = 32'h1000_1000;
localparam SPI_EN = 32'h1000_1fff;
localparam FLASH_ST = 32'h3000_0000;
localparam FLASH_EN = 32'h3fff_ffff;
localparam SDRAM_ST = 32'h8000_0000;
localparam SDRAM_EN = 32'h81ff_ffff;

//wire aligned = (paddr >= FLASH_ST && paddr <= FLASH_EN) || 
//							 (paddr >= SDRAM_ST && paddr <= SDRAM_EN)   ;
//wire unaligned = (paddr >= UART_ST && paddr <= UART_EN) || 
//								 (paddr >= SPI_ST  && paddr <= SPI_EN )   ;

parameter IDLE = 1'b0;
parameter WAIT = 1'b1;

reg current_state, next_state;

always @(*) begin
	case(current_state)
		IDLE : begin
			if(lsu_reqvalid) next_state = WAIT;
			else						 next_state = IDLE;
		end
		WAIT : begin
			if(lsu_resvalid) next_state = IDLE;
			else						 next_state = WAIT;
		end
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
wire [7:0] byte_rdata;
wire [15:0] half_rdata;

assign byte_rdata =
										paddr[1:0] == 2'b00 ? lsu_rdata[7 : 0] :
										paddr[1:0] == 2'b01 ? lsu_rdata[15: 8] :
										paddr[1:0] == 2'b10 ? lsu_rdata[23:16] : lsu_rdata[31:24];
assign half_rdata = 
										paddr[1:0] == 2'b00 ? lsu_rdata[15: 0] :
										paddr[1:0] == 2'b01 ? lsu_rdata[23: 8] :
										paddr[1:0] == 2'b10 ? lsu_rdata[31:16] : 0;
assign ur_result = mem_mask == 4'b0001 ? {24'b0, byte_rdata} :
									 mem_mask == 4'b0011 ? {16'b0, half_rdata} :
									 mem_mask == 4'b1111 ?         lsu_rdata   : 32'b0;
assign sr_result = mem_mask == 4'b0001 ? {{24{byte_rdata[7 ]}}, byte_rdata} :
									 mem_mask == 4'b0011 ? {{16{half_rdata[15]}}, half_rdata[15:0]} :
									 mem_mask == 4'b1111 ? lsu_rdata : 32'b0;
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
assign lsu_addr = paddr;
assign lsu_wdata = mem_mask == 4'b0001 ? byte_wdata :
									 mem_mask == 4'b0011 ? half_wdata :
									 mem_mask == 4'b1111 ? mwdata			: 0;	 
//assign lsu_wdata = mwdata;
assign lsu_wmask = mem_mask == 4'b0001 ? byte_mask :
									 mem_mask == 4'b0011 ? half_mask :
									 mem_mask == 4'b1111 ? mem_mask	 : 0;
assign lsu_size  = memre							 ? 2'b10 :
									 mem_mask == 4'b0001 ? 2'b00 :
									 mem_mask == 4'b0011 ? 2'b01 :
									 mem_mask == 4'b1111 ? 2'b10 : 2'b00;
assign lsu_wen = memwr;
assign lsu_reqvalid = exu_valid && (memre || memwr);

//`ifdef VERILATOR
//assign wbu_ebreak = ebreak;
//assign wbu_inst = inst;
//assign wbu_snpc = snpc;
//assign wbu_dnpc = dnpc;
//assign wbu_rs1  = rs1	;
//assign wbu_jal	= jal ;
//assign wbu_jalr	= jalr;
//`endif
assign lsu_valid = (current_state == WAIT && lsu_resvalid) || (!memre && !memwr && exu_valid);
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
