module ysyx_25010009_idu #(
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32,
	parameter RS_WIDTH     = 5 , 
	parameter FUNCT3_WIDTH = 3 ,
	parameter FUNCT7_WIDTH = 7 ,
	parameter OPCODE_WIDTH = 7 , 
	parameter OPSEL_WIDTH  = 4 ,
	parameter OPMUX_WIDTH  = 4 ,
	parameter	INST_BITS    = 6 ,
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

//decode
wire lui   =  (opcode == 7'b0110111)                        ;
wire auipc =  (opcode == 7'b0010111)                        ;
wire jal	 =  (opcode == 7'b1101111)                        ;
wire jalr	 = ((opcode == 7'b1100111) && (funct3 == 3'b000)) ;
wire beq	 = ((opcode == 7'b1100011) && (funct3 == 3'b000)) ;
wire bne	 = ((opcode == 7'b1100011) && (funct3 == 3'b001)) ;
wire blt	 = ((opcode == 7'b1100011) && (funct3 == 3'b100)) ;
wire bge	 = ((opcode == 7'b1100011) && (funct3 == 3'b101)) ;
wire bltu	 = ((opcode == 7'b1100011) && (funct3 == 3'b110)) ;
wire bgeu	 = ((opcode == 7'b1100011) && (funct3 == 3'b111)) ;
wire lb		 = ((opcode == 7'b0000011) && (funct3 == 3'b000)) ;
wire lh		 = ((opcode == 7'b0000011) && (funct3 == 3'b001)) ;
wire lw		 = ((opcode == 7'b0000011) && (funct3 == 3'b010)) ;
wire lbu	 = ((opcode == 7'b0000011) && (funct3 == 3'b100)) ;
wire lhu	 = ((opcode == 7'b0000011) && (funct3 == 3'b101)) ;
wire sb		 = ((opcode == 7'b0100011) && (funct3 == 3'b000)) ;
wire sh		 = ((opcode == 7'b0100011) && (funct3 == 3'b001)) ;
wire sw		 = ((opcode == 7'b0100011) && (funct3 == 3'b010)) ;
wire addi	 = ((opcode == 7'b0010011) && (funct3 == 3'b000)) ;
wire slti	 = ((opcode == 7'b0010011) && (funct3 == 3'b010)) ;
wire sltiu = ((opcode == 7'b0010011) && (funct3 == 3'b011)) ;
wire xori	 = ((opcode == 7'b0010011) && (funct3 == 3'b100)) ;
wire ori	 = ((opcode == 7'b0010011) && (funct3 == 3'b110)) ;
wire andi	 = ((opcode == 7'b0010011) && (funct3 == 3'b111)) ;
wire slli  = ((opcode == 7'b0010011) && (funct3 == 3'b001) && (funct7 == 7'b0000000));
wire srli  = ((opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0000000));
wire srai	 = ((opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0100000));
wire add	 = ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000));
wire sub	 = ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000));
wire sll	 = ((opcode == 7'b0110011) && (funct3 == 3'b001) && (funct7 == 7'b0000000));
wire slt	 = ((opcode == 7'b0110011) && (funct3 == 3'b010) && (funct7 == 7'b0000000));
wire sltu	 = ((opcode == 7'b0110011) && (funct3 == 3'b011) && (funct7 == 7'b0000000));
wire xor_	 = ((opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0000000));
wire srl	 = ((opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000000));
wire sra	 = ((opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0100000));
wire or_	 = ((opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0000000));
wire and_	 = ((opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0000000));

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

assign Type =  sll || srl  || sra || add || sub || xor_ || or_ || and_ ||
							 slt || sltu   																										 ? TYPE_R :
							 slli  || srli  || srai || addi || xori || ori || andi || slti ||
							 sltiu || jalr  || lb   || lh   || lw		|| lbu || lhu							 ? TYPE_I : 
							 sb || sh || sw																										 ? TYPE_S :
							 beq || bne || blt || bge || bltu || bgeu													 ? TYPE_B :
							 lui || auipc																											 ? TYPE_U :
							 jal || jalr																											 ? TYPE_J : TYPE_R;

//imm/shamt
wire [DATA_WIDTH  -1:0] imm  ;
wire [DATA_WIDTH  -1:0] shamt;
assign imm = (Type == TYPE_I) ? {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20   ]       } :
						 (Type == TYPE_S) ? {{21{inst[31]}}, inst[30:25], inst[11: 8], inst[ 7   ]       } :
						 (Type == TYPE_B) ? {{20{inst[31]}}, inst[7    ], inst[30:25], inst[11: 8], 1'b0 } :
						 (Type == TYPE_U) ? {inst[31:12]   , 12'b0                                       } :
						 (Type == TYPE_J) ? {{12{inst[31]}}, inst[19:12], inst[20   ], inst[30:21], 1'b0 } :
							32'b0;
assign shamt = {{(DATA_WIDTH-RS_WIDTH){1'b0}}, inst[RS2_EN:RS2_ST]};

//opmux/opsel
wire [OPMUX_WIDTH-1:0] opmux;
assign opmux = sll || srl  || sra || add || sub || xor_ || or_  || and_ ||
							 slt || sltu ||	beq || bne || blt || bge  || bltu || bgeu		 ? 4'b0001 : //rs1_rs2
							 addi || xori || ori || andi || slti || sltiu || lb || lh ||
							 lw		|| lbu  || lhu || sb   || sh	 || sw									 ? 4'b0010 : //rs1_imm
							 auipc																											 ? 4'b0011 : //pc_imm
							 slli || srli || srai																				 ? 4'b0100 : //rs1_shamt
							 lui																												 ? 4'b0101 : //imm_0
							 4'b0000; //rs1_rs2
assign opsel = add || addi || lui || auipc ||
							 lb  || lh	 || lw	|| lbu	 ||
							 lhu || sb	 || sh	|| sw			  ? 4'b0001 : //+
							 sub												    ? 4'b0010 : //-
							 and_ || andi								    ? 4'b0011 : //&
							 or_	|| ori								    ? 4'b0100 : //|
							 xor_	|| xori								    ? 4'b0101 : //^
							 sll || slli								    ? 4'b0110 : //<<
							 srl || srli								    ? 4'b0111 : //>>u
							 sra || srai                    ? 4'b1000 : //>>s
							 beq												    ? 4'b1001 : //==
							 bne												    ? 4'b1010 : //!=
							 slt || slti || blt					    ? 4'b1011 : //<
							 bge												    ? 4'b1100 : //>=
							 sltu || sltiu || bltu			    ? 4'b1101 : //<u
							 bgeu												    ? 4'b1110 : //>=u
							 4'b0000;//+

//src1/src2
reg [DATA_WIDTH -1:0] wire_src1;
reg [DATA_WIDTH -1:0] wire_src2;

always @(*) begin
	case(opmux) 
		4'b0001 : begin 
			wire_src1 = rf_src1;
			wire_src2 = rf_src2;
		end
		4'b0010 : begin
			wire_src1 = rf_src1;
			wire_src2 = imm;
		end 
		4'b0011 : begin 
			wire_src1 = pc;
			wire_src2 = imm;
		end
		4'b0100 : begin 
			wire_src1 = rf_src1;
			wire_src2 = shamt;
		end 
		4'b0101 : begin
			wire_src1 = imm;
			wire_src2 = 32'd0;
		end 
		default : begin
			wire_src1 = 32'd0;
	  	wire_src2 = 32'd0;
		end
	endcase
end

assign src1 = wire_src1;
assign src2 = wire_src2;

//other output signal
assign rs1 = inst[RS1_EN:RS1_ST];
assign rs2 = inst[RS2_EN:RS2_ST];
assign rd  = inst[RD_EN : RD_ST];
assign is_jalr  = jalr;
assign is_jal   = jal;
assign is_bxx   = beq || bne || blt || bge || bltu || bgeu;
assign mwdata = rf_src2;
assign memwr = sb || sh || sw;
assign memre = lb || lh || lw || lbu || lhu;
assign regwr = sll  || slli || srl || srli || sra  || srai || add || addi || sub  || lui   || auipc ||
							 xor_ || xori	|| or_ || ori  || and_ || andi || slt || slti || sltu || sltiu || lb		||
							 lh		|| lw		|| lbu || lhu																															;

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
