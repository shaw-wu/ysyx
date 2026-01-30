module ysyx_25010009_lsu #(
	parameter DATA_WIDTH  = 32, 
	parameter ADDR_WIDTH  = 32, 
	parameter RS_WIDTH    = 5 ,
	parameter CAR_WIDTH   = 12
)(
	input clk,
	input rst,
	//exu <> lsu
	input	exu_lsu_valid,
	output	exu_lsu_ready,
`ifdef VERILATOR
	input 				    ebreak,
	input [DATA_WIDTH -1:0] inst,
	input [ADDR_WIDTH -1:0] snpc,
	input [ADDR_WIDTH -1:0] dnpc,
	input [RS_WIDTH   -1:0] rs1	,
	input                   jal ,
	input                   jalr,
`endif
	input [ADDR_WIDTH -1:0] pc	  ,
	input [DATA_WIDTH -1:0] mwdata,
	input		memwr   ,
	input	 	memre   ,
	input	 	regwr   ,	
	input	    csr1wr  ,	
	input       csr2wr  ,	
	input [3:0] mem_mask,	
	input	    mem_sext,	
	input [DATA_WIDTH -1:0] paddr  ,
	input [RS_WIDTH   -1:0] gpr_rd ,
	input [DATA_WIDTH -1:0] gpr_res,
	input [CAR_WIDTH  -1:0] csr_rd1	,
	input [CAR_WIDTH  -1:0] csr_rd2	,
	input [DATA_WIDTH -1:0] csr_res1,
	input [DATA_WIDTH -1:0] csr_res2,   
	// lsu <> ram
    output wreq  ,
    output wready,
    input  wresp ,
    output rreq  ,
    output rready,
    input  rresp ,
	output [DATA_WIDTH -1:0] waddr ,
	output [DATA_WIDTH -1:0] wdata	,
	output [ADDR_WIDTH -1:0] raddr ,
	input  [DATA_WIDTH -1:0] rdata	,
	output [            3:0] ram_mask,
	output [            1:0] ram_size,
	// lsu <> wbu
	output lsu_wbu_valid,
	input  lsu_wbu_ready,
`ifdef VERILATOR
	output 					 wbu_ebreak,
	output [DATA_WIDTH -1:0] wbu_inst,
	output [ADDR_WIDTH -1:0] wbu_snpc,
	output [ADDR_WIDTH -1:0] wbu_dnpc,
	output [RS_WIDTH   -1:0] wbu_rs1 ,
	output wbu_jal ,
	output wbu_jalr,
`endif
	output [ADDR_WIDTH -1:0] wbu_pc,
	output	 				 wbu_regwr   ,	
	output	 				 wbu_csr1wr  ,	
	output	 				 wbu_csr2wr  ,	
	output [RS_WIDTH   -1:0] wbu_gpr_rd	 ,
	output [DATA_WIDTH -1:0] wbu_gpr_res ,
	output [CAR_WIDTH  -1:0] wbu_csr_rd1 ,
	output [CAR_WIDTH  -1:0] wbu_csr_rd2 ,
	output [DATA_WIDTH -1:0] wbu_csr_res1,
	output [DATA_WIDTH -1:0] wbu_csr_res2 
);

//Register
//exu <> lsu bundle
`ifdef VERILATOR
reg 				  reg_ebreak;
reg [DATA_WIDTH -1:0] reg_inst;
reg [ADDR_WIDTH -1:0] reg_snpc;
reg [ADDR_WIDTH -1:0] reg_dnpc;
reg [RS_WIDTH   -1:0] reg_rs1 ;
reg                   reg_jal ;
reg                   reg_jalr;
`endif
reg reg_memwr ;
reg reg_memre ;
reg reg_regwr ;	
reg reg_csr1wr;	
reg reg_csr2wr;	
reg [3:0] reg_mem_mask;	
reg       reg_mem_sext;	
reg [ADDR_WIDTH -1:0] reg_pc	;
reg [DATA_WIDTH -1:0] reg_mwdata;
reg [DATA_WIDTH -1:0] reg_paddr  ;
reg [RS_WIDTH   -1:0] reg_gpr_rd ;
reg [DATA_WIDTH -1:0] reg_gpr_res;
reg [CAR_WIDTH  -1:0] reg_csr_rd1;
reg [CAR_WIDTH  -1:0] reg_csr_rd2;
reg [DATA_WIDTH -1:0] reg_csr_res1;
reg [DATA_WIDTH -1:0] reg_csr_res2;   

wire resp = wresp || rresp;
///*----------------- dram state machine ---------------------*/
//
//parameter DRAM_IDLE  = 3'b000;
//parameter DRAM_WORKW = 3'b001;
//parameter DRAM_WORKR = 3'b010;
//parameter DRAM_WAITW = 3'b011;
//parameter DRAM_WAITR = 3'b110;
//parameter DRAM_DONE  = 3'b111;
//
//reg [2:0] dram_current_state, dram_next_state;
//
//always @(*) begin
//	case(dram_current_state)
//		DRAM_IDLE :
//			if     (awvalid) dram_next_state = DRAM_WAITW;
//			else if(arvalid) dram_next_state = DRAM_WAITR;
//			else			 dram_next_state = DRAM_IDLE;
//		DRAM_WORKW :
//			dram_next_state = DRAM_WAITW;	
//		DRAM_WORKR :
//			dram_next_state = DRAM_WAITR;	
//		DRAM_WAITW : 
//			if	   (bvalid && awvalid) dram_next_state = DRAM_WORKW;
//			else if(bvalid && arvalid) dram_next_state = DRAM_WORKR;
//			else if(bvalid			 ) dram_next_state = DRAM_IDLE;
//			else											 dram_next_state = DRAM_WAITW;
//		DRAM_WAITR : 
//			if	   (rvalid && awvalid) dram_next_state = DRAM_WORKW;
//			else if(rvalid && arvalid) dram_next_state = DRAM_WORKR;
//			else if(rvalid			 ) dram_next_state = DRAM_IDLE;
//			else					   dram_next_state = DRAM_WAITR;
//		default : dram_next_state = DRAM_IDLE;
//	endcase
//end
//
//always @(posedge clk or posedge rst) begin
//	if(rst) dram_current_state <= DRAM_IDLE;
//	else    dram_current_state <= dram_next_state;
//end
//
///*----------------------------------------------------------*/

/*----------------- state machine ------------------*/

parameter IDLE = 2'b00;
parameter WAIT = 2'b01;
parameter WORK = 2'b11;

reg [1:0] current_state, next_state;

always @(*) begin
	case(current_state)
		IDLE : begin
			if      (exu_lsu_valid && (memwr || memre)) next_state = WORK;
			else if (exu_lsu_valid                    ) next_state = WAIT;
			else                                        next_state = IDLE;
		end
		WAIT : begin
			if		(lsu_wbu_ready &&  exu_lsu_valid && (memre || memwr)) next_state = WORK;
			else if (lsu_wbu_ready && !exu_lsu_valid                   	) next_state = IDLE;
			else														  next_state = WAIT;
		end
		WORK : begin
			if      (resp && lsu_wbu_ready &&  exu_lsu_valid && (memre || memwr)) next_state = WORK;
			else if (resp && lsu_wbu_ready && !exu_lsu_valid                    ) next_state = IDLE;
			else if (resp                                                       ) next_state = WAIT;
			else                                                                  next_state = WORK;
		end
		default : next_state = IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= IDLE;
	end begin
		current_state <= next_state;
        if(exu_lsu_valid && exu_lsu_ready) begin
            `ifdef VERILATOR
            reg_ebreak   <= ebreak  ;
            reg_inst     <= inst    ;
            reg_snpc     <= snpc    ;
            reg_dnpc     <= dnpc    ;
            reg_rs1      <= rs1     ;
            reg_jal      <= jal     ;
            reg_jalr     <= jalr    ;
            `endif
            reg_memwr    <= memwr   ;
            reg_memre    <= memre   ;
            reg_regwr    <= regwr   ;	
            reg_csr1wr   <= csr1wr  ;	
            reg_csr2wr   <= csr2wr  ;	
            reg_mem_mask <= mem_mask;	
            reg_mem_sext <= mem_sext;	
            reg_pc	     <= pc	    ;
            reg_mwdata   <= mwdata  ;
            reg_paddr    <= paddr   ;
            reg_gpr_rd   <= gpr_rd  ;
            reg_gpr_res  <= gpr_res ;
            reg_csr_rd1  <= csr_rd1 ;
            reg_csr_rd2  <= csr_rd2 ;
            reg_csr_res1 <= csr_res1;
            reg_csr_res2 <= csr_res2;   
        end

	end
end

/*--------------------------------------------------*/

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

assign byte_rdata = reg_paddr[1:0] == 2'b00 ? rdata[7 : 0] :
					reg_paddr[1:0] == 2'b01 ? rdata[15: 8] :
					reg_paddr[1:0] == 2'b10 ? rdata[23:16] : rdata[31:24];
assign half_rdata = reg_paddr[1:0] == 2'b00 ? rdata[15: 0] :
					reg_paddr[1:0] == 2'b01 ? rdata[23: 8] :
					reg_paddr[1:0] == 2'b10 ? rdata[31:16] : 0;
assign ur_result = reg_mem_mask == 4'b0001 ? {24'b0, byte_rdata} :
				   reg_mem_mask == 4'b0011 ? {16'b0, half_rdata} :
				   reg_mem_mask == 4'b1111 ?              rdata  : 32'b0;
assign sr_result = reg_mem_mask == 4'b0001 ? {{24{byte_rdata[7 ]}}, byte_rdata} :
				   reg_mem_mask == 4'b0011 ? {{16{half_rdata[15]}}, half_rdata[15:0]} :
				   reg_mem_mask == 4'b1111 ? rdata : 32'b0;
assign re_result = reg_mem_sext ? sr_result : ur_result;

wire [31:0] byte_wdata;
wire [31:0] half_wdata;

assign byte_wdata = reg_paddr[1:0] == 2'b00 ? {24'b0, reg_mwdata[7 : 0]		  } :
				    reg_paddr[1:0] == 2'b01 ? {16'b0, reg_mwdata[7 : 0],  8'b0} :
				    reg_paddr[1:0] == 2'b10 ? { 8'b0, reg_mwdata[7 : 0], 16'b0} : {reg_mwdata[7 : 0], 24'b0}; 
assign half_wdata = reg_paddr[1:0] == 2'b00 ? {16'b0, reg_mwdata[15: 0]		  } :
				    reg_paddr[1:0] == 2'b01 ? { 8'b0, reg_mwdata[15: 0],  8'b0} :
				    reg_paddr[1:0] == 2'b10 ? {       reg_mwdata[15: 0], 16'b0} : 0; 

wire [3:0] byte_mask;
wire [3:0] half_mask;
assign byte_mask = reg_paddr[1:0] == 2'b00 ? 4'b0001 :
				   reg_paddr[1:0] == 2'b01 ? 4'b0010 :
				   reg_paddr[1:0] == 2'b10 ? 4'b0100 : 4'b1000; 
assign half_mask = reg_paddr[1:0] == 2'b00 ? 4'b0011 :
				   reg_paddr[1:0] == 2'b10 ? 4'b1100 : 0; 

assign wreq   = (current_state == WORK && reg_memwr);
assign wready = (current_state == WORK && reg_memwr);
assign rreq   = (current_state == WORK && reg_memre);
assign rready = (current_state == WORK && reg_memre);
assign raddr = reg_paddr;
assign waddr = reg_paddr;
//assign wdata = mwdata;
assign wdata = reg_mem_mask == 4'b0001 ? byte_wdata :
			   reg_mem_mask == 4'b0011 ? half_wdata :
			   reg_mem_mask == 4'b1111 ? reg_mwdata	: 0;	 
//assign ram_mask = mem_mask;
assign ram_mask = reg_mem_mask == 4'b0001 ? byte_mask    :
				  reg_mem_mask == 4'b0011 ? half_mask    :
				  reg_mem_mask == 4'b1111 ? reg_mem_mask : 0;
assign ram_size = reg_mem_mask == 4'b0001 ? 0 :
				  reg_mem_mask == 4'b0011 ? 1 :
				  reg_mem_mask == 4'b1111 ? 2 : 0;

assign lsu_wbu_valid = current_state == WAIT || (current_state == WORK && resp);	
assign exu_lsu_ready = current_state == IDLE || (current_state == WAIT && lsu_wbu_ready) || (current_state == WORK && lsu_wbu_ready && resp);

`ifdef VERILATOR
assign wbu_ebreak = reg_ebreak;
assign wbu_inst = reg_inst;
assign wbu_snpc = reg_snpc;
assign wbu_dnpc = reg_dnpc;
assign wbu_rs1  = reg_rs1	;
assign wbu_jal	= reg_jal ;
assign wbu_jalr	= reg_jalr;
`endif
assign wbu_pc = reg_pc;
assign wbu_regwr = reg_regwr;
assign wbu_csr1wr = reg_csr1wr;
assign wbu_csr2wr = reg_csr2wr;
assign wbu_gpr_rd = reg_gpr_rd;
assign wbu_gpr_res = reg_memre ? re_result : reg_gpr_res;
assign wbu_csr_rd1 = reg_csr_rd1;
assign wbu_csr_rd2 = reg_csr_rd2;
assign wbu_csr_res1 = reg_csr_res1;
assign wbu_csr_res2 = reg_csr_res2;

endmodule
