module ysyx_25010009_idu #(
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32,
	parameter RS_WIDTH     = 5 , 
	parameter OPCODE_WIDTH = 7 , 
	parameter OPSEL_WIDTH  = 4 ,
	parameter OPMUX_WIDTH  = 4 ,
	parameter PCMUX_WIDTH  = 2 
) (
	input clk,
	input rst,
	//ifu
	input  [DATA_WIDTH -1:0] inst   ,
	input  [ADDR_WIDTH -1:0] pc			,
	input  [ADDR_WIDTH -1:0] snpc	  ,
	input  [ADDR_WIDTH -1:0] dnpc	  ,
	//exu
	output [ADDR_WIDTH -1:0] exu_snpc,
	output [ADDR_WIDTH -1:0] exu_dnpc,
	output [ADDR_WIDTH -1:0] exu_pc	 ,
  output [DATA_WIDTH -1:0] exu_imm ,
	output [DATA_WIDTH -1:0] src1		 ,
  output [DATA_WIDTH -1:0] src2		 ,
	output [RS_WIDTH   -1:0] rd      ,
	output [OPSEL_WIDTH-1:0] opsel	 ,
	output [DATA_WIDTH -1:0] mwdata  ,
	output									 memwr   ,
	output									 memre   ,
	output									 regwr   ,	
	output									 is_jalr ,
	output									 is_jal  ,
	output									 is_bxx  ,
	//regfile
	output [RS_WIDTH   -1:0] rs1		,
	output [RS_WIDTH   -1:0] rs2		,
	input  [DATA_WIDTH -1:0] rf_src1,
  input  [DATA_WIDTH -1:0] rf_src2
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
assign decode_inst =  (opcode == 7'b0110111)                        ? 6'd1  : //lui
								      (opcode == 7'b0010111)                        ? 6'd2  : //auipc
								      (opcode == 7'b1101111)                        ? 6'd3  : //jal
								     ((opcode == 7'b1100111) && (funct3 == 3'b000)) ? 6'd4  : //jalr
								     ((opcode == 7'b1100011) && (funct3 == 3'b000)) ? 6'd5  : //beq
								     ((opcode == 7'b1100011) && (funct3 == 3'b001)) ? 6'd6  : //bne
								     ((opcode == 7'b1100011) && (funct3 == 3'b100)) ? 6'd7  : //blt
								     ((opcode == 7'b1100011) && (funct3 == 3'b101)) ? 6'd8  : //bge
								     ((opcode == 7'b1100011) && (funct3 == 3'b110)) ? 6'd9  : //bltu
								     ((opcode == 7'b1100011) && (funct3 == 3'b111)) ? 6'd10 : //bgeu
								     ((opcode == 7'b0000011) && (funct3 == 3'b000)) ? 6'd11 : //lb
								     ((opcode == 7'b0000011) && (funct3 == 3'b001)) ? 6'd12 : //lh
								     ((opcode == 7'b0000011) && (funct3 == 3'b010)) ? 6'd13 : //lw
								     ((opcode == 7'b0000011) && (funct3 == 3'b100)) ? 6'd14 : //lbu
								     ((opcode == 7'b0000011) && (funct3 == 3'b101)) ? 6'd15 : //lhu
								     ((opcode == 7'b0100011) && (funct3 == 3'b000)) ? 6'd16 : //sb
								     ((opcode == 7'b0100011) && (funct3 == 3'b001)) ? 6'd17 : //sh
								     ((opcode == 7'b0100011) && (funct3 == 3'b010)) ? 6'd18 : //sw
								     ((opcode == 7'b0010011) && (funct3 == 3'b000)) ? 6'd19 : //addi
								     ((opcode == 7'b0010011) && (funct3 == 3'b010)) ? 6'd20 : //slti
								     ((opcode == 7'b0010011) && (funct3 == 3'b011)) ? 6'd21 : //sltiu
								     ((opcode == 7'b0010011) && (funct3 == 3'b100)) ? 6'd22 : //xori
								     ((opcode == 7'b0010011) && (funct3 == 3'b110)) ? 6'd24 : //ori
								     ((opcode == 7'b0010011) && (funct3 == 3'b111)) ? 6'd24 : //andi
								     ((opcode == 7'b0010011) && (funct3 == 3'b001) && (funct7 == 7'b0000000)) ? 6'd25 : //slli
								     ((opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0000000)) ? 6'd26 : //srli
								     ((opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0100000)) ? 6'd27 : //srai
								     ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000)) ? 6'd28 : //add
								     ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000)) ? 6'd29 : //sub
								     ((opcode == 7'b0110011) && (funct3 == 3'b001) && (funct7 == 7'b0000000)) ? 6'd30 : //sll
								     ((opcode == 7'b0110011) && (funct3 == 3'b010) && (funct7 == 7'b0000000)) ? 6'd31 : //slt
								     ((opcode == 7'b0110011) && (funct3 == 3'b011) && (funct7 == 7'b0000000)) ? 6'd32 : //sltu
								     ((opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0000000)) ? 6'd33 : //xor
								     ((opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000000)) ? 6'd34 : //srl
								     ((opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0100000)) ? 6'd35 : //sra
								     ((opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0000000)) ? 6'd36 : //or
								     ((opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0000000)) ? 6'd37 : //and
										 6'd0;

wire [FUNCT3_WIDTH-1:0] funct3;
wire [FUNCT7_WIDTH-1:0] funct7;
wire [OPCODE_WIDTH-1:0] opcode;
assign funct3 = inst[FUNCT3_EN:FUNCT3_ST];
assign funct7 = inst[FUNCT7_EN:FUNCT7_ST];
assign opcode = inst[OPCODE_EN:OPCODE_ST];

//type
localparam TYPE_R = 0;
localparam TYPE_I = 1;
localparam TYPE_S = 2;
localparam TYPE_B = 3;
localparam TYPE_U = 4;
localparam TYPE_J = 5;
wire [TYPE_WIDTH-1:0] Type;

assign Type =  ((decode_inst >= 6'd28) && (decode_inst <= 37))     ? TYPE_R :
							(((decode_inst >= 6'd19) && (decode_inst <= 27)) ||
							 ((decode_inst >= 6'd11) && (decode_inst <= 15)) ||
							   decode_inst == 6'd4                             ) ? TYPE_I :
							 ((decode_inst >= 6'd16) && (decode_inst <= 18))     ? TYPE_S :
							 ((decode_inst >= 6'd5 ) && (decode_inst <= 10))     ? TYPE_B :
							 ((decode_inst == 6'd1 ) || (decode_inst == 2 ))     ? TYPE_U :
							   decode_inst == 6'd3                               ? TYPE_J : TYPE_R;

//imm/shamt
wire [DATA_WIDTH  -1:0] imm  ;
wire [DATA_WIDTH  -1:0] shamt;
assign imm = (Type == TYPE_I) ? {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20   ]       } :
						 (Type == TYPE_S) ? {{21{inst[31]}}, inst[30:25], inst[11: 8], inst[ 7   ]       } :
						 (Type == TYPE_B) ? {{20{inst[31]}}, inst[7    ], inst[30:25], inst[11: 8], 1'b0 } :
						 (Type == TYPE_U) ? {inst[31:12]   , 12'b0                                       } :
						 (Type == TYPE_J) ? {{12{inst[31]}}, inst[19:12], inst[20   ], inst[30:21], 1'b0 } :
							32'b0;
assign shamt = inst[RS2_EN:RS2_ST];

//opmux/opsel
wire [OPMUX_WIDTH-1:0] opmux;
assign opmux = (((decode_inst >= 6'd5 ) && (decode_inst <= 6'd10)) || 
						    ((decode_inst >= 6'd28) && (decode_inst <= 6'd37))   ) ? 4'b0001 : //rs1_rs2
							  ((decode_inst >= 6'd11) && (decode_inst <= 6'd24))     ? 4'b0010 : //rs1_imm
							   (decode_inst == 6'd2 )																 ? 4'b0011 : //pc_imm
							  ((decode_inst >= 6'd25) && (decode_inst <= 6'd27))     ? 4'b0100 : //rs1_shamt
							   (decode_inst == 6'd1 )																 ? 4'b0101 : //imm_0
									4'b0000; //rs1_rs2
assign opsel = ((decode_inst == 6'd1 ) && (decode_inst == 6'd2 ) && 
								(decode_inst == 6'd3 ) && (decode_inst == 6'd4 ) && 
								(decode_inst == 6'd11) && (decode_inst == 6'd12) && 
								(decode_inst == 6'd13) && (decode_inst == 6'd14) && 
								(decode_inst == 6'd15) && (decode_inst == 6'd16) && 
								(decode_inst == 6'd17) && (decode_inst == 6'd18) && 
								(decode_inst == 6'd19) && (decode_inst == 6'd28)   ) ? 4'b0001 : //+
							  (decode_inst == 6'd29)															 ? 4'b0010 : //-
							 ((decode_inst == 6'd24) && (decode_inst == 6'd37))    ? 4'b0011 : //&
							 ((decode_inst == 6'd23) && (decode_inst == 6'd36))    ? 4'b0100 : //|
							 ((decode_inst == 6'd22) && (decode_inst == 6'd33))    ? 4'b0101 : //^
							 ((decode_inst == 6'd25) && (decode_inst == 6'd30))    ? 4'b0110 : //<<
							 ((decode_inst == 6'd26) && (decode_inst == 6'd34))    ? 4'b0111 : //>>u
							 ((decode_inst == 6'd27) && (decode_inst == 6'd35))    ? 4'b1000 : //>>s
							  (decode_inst == 6'd5 )															 ? 4'b1001 : //==
							  (decode_inst == 6'd6 )															 ? 4'b1010 : //!=
							 ((decode_inst == 6'd7 ) && (decode_inst == 6'd20) && 
								(decode_inst == 6'd31)                             ) ? 4'b1011 : //<
							  (decode_inst == 6'd8 )															 ? 4'b1100 : //>=
							 ((decode_inst == 6'd9 ) && (decode_inst == 6'd21) && 
							  (decode_inst == 6'd32)														 ) ? 4'b1101 : //<u
							  (decode_inst == 6'd10)															 ? 4'b1110 : //>=u
							   4'b0000;//+

//src1/src2
generate
	if (opmux == 4'b0001) begin : rs1_rs2
		assign src1 = rf_src1;
		assign src2 = rf_src2;
	end else if (opmux == 4'b0010) begin : rs1_imm
		assign src1 = rf_src1;
		assign src2 = imm;
	end else if (opmux == 4'b0011) begin : pc_imm 
		assign src1 = pc;
		assign src2 = imm;
	end else if (opmux == 4'b0100) begin : rs1_shamt 
		assign src1 = rf_src1;
		assign src2 = shamt;
	end else if (opmux == 4'b0101) begin : imm_0
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
assign is_jalr  = (decode_inst == 6'd4);
assign is_jal   = (decode_inst == 6'd3);
assign is_bxx   = ((decode_inst >= 6'd5 ) && (decode_inst <= 6'd10));
assign mwdata = rf_scr2;
assign memwr = ((decode_inst >= 16) && (decode_inst <= 18)) ? 1 : 0;
assign memwr = ((decode_inst >= 11) && (decode_inst <= 15)) ? 1 : 0;
assign regwr = ((decode_inst == 6'd1) && (decode_isnt == 6'd2)) ? 1 : 
							 0; 

assign exu_pc   = pc;
assign exu_snpc = snpc;
assign exu_dnpc = dnpc;
assign exu_imm  = imm ;

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
