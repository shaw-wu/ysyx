module ysyx_25020009_idu #(
	ADDR_WIDTH   = 32, 
	DATA_WIDTH   = 32,
	RS_WIDTH     = 5 , 
	OPCODE_WIDTH = 7 , 
	OPSEL_WIDTH  = 4 ,
	OPMUX_WIDTH  = 4 
) (
	input clk,
	input rst
	//ifu
	input  [DATA_WIDTH -1:0] inst   ,
	input  [ADDR_WIDTH -1:0] pc			,
	input  [ADDR_WIDTH -1:0] snpc	  ,
	//exu
	output [ADDR_WIDTH -1:0] exu_snpc,
	output [ADDR_WIDTH -1:0] exu_pc	 ,
	output [DATA_WIDTH -1:0] src1		 ,
  output [DATA_WIDTH -1:0] src2		 ,
	output [RS_WIDTH   -1:0] rd      ,
	output [OPSEL_WIDTH-1:0] opsel	 ,
	output [DATA_WIDTH -1:0] csr	   ,
	output [DATA_WIDTH -1:0] mwdata  ,
	output									 memwr   ,
	output									 memre   ,
	output									 regwr   ,	
	output									 csrwr   ,	
	output									 is_csr	 ,
	output									 is_jmp	 ,
	//regfile
	output [RS_WIDTH   -1:0] rs1		,
	output [RS_WIDTH   -1:0] rs2		,
	input  [DATA_WIDTH -1:0] rf_src1,
  input  [DATA_WIDTH -1:0] rf_src2,
	//csrfile
	output [DATA_WIDTH -1:0] crs    ,
	input  [DATA_WIDTH -1:0] rf_csr    
);

localparam OPCODE_ST = 0;
localparam OPCODE_EN = 6;
localparam RD_ST     = 7;
localparam RD_EN     = 11;
localparam FUNCT3_ST = 12;
localparam FUNCT3_EN = 14;
localparam RS1_ST    = 15;
localparam RS1_EN    = 19;
localparam RS2_ST    = 20;
localparam RS2_EN    = 24;
localparam FUNCT7_ST = 25;
localparam FUNCT7_EN = 31;
localparam TYPE_WIDTH = 3 ;
localparam INST_BITS  = clog2(INST_NUM);

//decode
wire [INST_BITS-1:0] decode_inst;
assign decode_inst = ((opcode == 7'b0010011) && (func3 == 3'b000)) ? 6'd1 :
								     ((opcode == 7'b0110011) && (func3 == 3'b000)) ? 6'd2 :
										 6'd0;

wire [FUNCT3_WIDTH-1:0] funct3;
wire [FUNCT7_WIDTH-1:0] funct7;
wire [OPCODE_WIDTH-1:0] opcode;
assign funct3 = inst[FUNCT3_EN:FUNCT3_ST];
assign funct7 = inst[FUNCT7_EN:FUNCT7_ST];
assign opcode = inst[OPCODE_EN:OPCODE_ST];

//type
typedef enum [TYPE_WIDTH-1:0] {
	TYPE_R : 0,
	TYPE_I : 1,
	TYPE_S : 2,
	TYPE_B : 3,
	TYPE_U : 4,
	TYPE_J : 5
}	type_t;
type_t type;

assign type = (decode_inst == 6'd1) ? TYPE_I :
							(decode_inst == 6'd2) ? TYPE_R :
							TYPE_I;

//imm/zimm/shamt
wire [DATA_WIDTH  -1:0] imm  ;
wire [DATA_WIDTH  -1:0] shamt;
wire [DATA_WIDTH  -1:0] zimm ;
assign imm = (type == TYPE_I) ? {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20   ]       } :
						 (type == TYPE_S) ? {{21{inst[31]}}, inst[30:25], inst[11: 8], inst[ 7   ]       } :
						 (type == TYPE_B) ? {{20{inst[31]}}, inst[7    ], inst[30:25], inst[11: 8], 1'b0 } :
						 (type == TYPE_U) ? {inst[31:12]   , 12'b0                                       } :
						 (type == TYPE_J) ? {{12{inst[31]}}, inst[19:12], inst[20   ], inst[30:21], 1'b0 } :
							32'b0;
assign shamt = inst[RS2_EN:RS2_ST];
assign zimm  = inst[RS1_EN:RS1_ST]; 

//opmux/opsel
wire [OPMUX_WIDTH-1:0] opmux;
assign opmux = (decode_inst == 6'd1) ? 4'b0010 :
							 (decode_inst == 6'd2) ? 4'b0001 :
							 4'b0000;
assign opsel = ((decode_inst == 6'd1) && (decpde_inst == 6'd2)) ? 4'b0001 ://+
							 4'b0000;//+

//src1/src2
generate
	if (opmux == 4'b0001) begin : rs1_rs2
		assign src1 = rf_src1;
		assign src2 = rf_src2;
	end else if (opmux == 4'b0010) begin : rs1_imm
		assign src1 = rf_src1;
		assign src2 = imm;
	end else if (opmux == 4'b0011) begin : pc_4 
		assign src1 = pc;
		assign src2 = 32'd4;
	end else if (opmux == 4'b0100) begin : pc_imm 
		assign src1 = pc;
		assign src2 = imm;
	end else if (opmux == 4'b0101) begin : rs1_shamt 
		assign src1 = rf_src1;
		assign src2 = shamt;
	end else if (opmux == 4'b0110) begin : rs1_0 
		assign src1 = rf_src1;
		assign src2 = 32'd0;
	end else if (opmux == 4'b0111) begin : csr_0 
		assign src1 = rf_csr;
		assign src2 = 32'd0;
	end else if (opmux == 4'b1000) begin : csr_nrs1
		assign src1 = rf_csr;
		assign src2 = ~rf_src1;
	end else if (opmux == 4'b1001) begin : csr_nzimm
		assign src1 = rf_csr;
		assign src2 = ~zimm;
	end else if (opmux == 4'b1010) begin : csr_rs1 
		assign src1 = rf_csr;
		assign src2 = rf_src1;
	end else if (opmux == 4'b1011) begin : csr_zimm
		assign src1 = rf_csr;
		assign src2 = zimm;
	end else if (opmux == 4'b1100) begin : zimm_0 
		assign src1 = zimm;
		assign src2 = 32'd0;
	end else if (opmux == 4'b1101) begin : imm_0
		assign src1 = imm;
		assign src2 = 32'd0;
	end else begin : defult
		assign src1 = 32'd0;
	  assign src2 = 32'd0;
	end	
endgenerate

//other output signal
assign rs1 = inst[RS1_EN:RS1_ST];
assign rs2 = inst[RS2_EN:RS2_ST];
assign rd  = inst[RD_EN : RD_ST];
assign csr  = rf_csr	;
assign mwdata = rf_scr2;
assign memwr = (decode_inst == 6'b111111) ? 1 :
	             0; 
assign memre = (decode_inst == 6'b111110) ? 1 :
							 0; 
assign regwr = ((decode_inst == 6'd1) && (decode_isnt == 6'd2)) ? 1 : 
							 0; 
assign csrwr = (decode_inst == 6'b111100) ? 1 : 
	 						 0; 

assign exu_pc   = pc;
assign exu_snpc = snpc;

function integer clog2;
	input integer value;
	integer k;
	begin
		clog2 = 0;
		for(k = value - 1; k > 0; k = k >> 1)
			clog2 = clog2 + 1;
	end
endfunction
endmodule
