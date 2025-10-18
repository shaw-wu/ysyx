module ysyx_25010009_exu #(
	parameter DATA_WIDTH  = 32, 
	parameter ADDR_WIDTH  = 32, 
	parameter RS_WIDTH    = 5 , 
	parameter CAR_WIDTH   = 12,
	parameter OPSEL_WIDTH = 4 ,
	parameter OPMUX_WIDTH = 4
)(
	input clk,
	input rst,
	//idu
`ifdef VERILATOR
	input										 ebreak	,
	input  [DATA_WIDTH -1:0] inst		,
	input  [RS_WIDTH   -1:0] rs1		,
`endif
	input  [ADDR_WIDTH -1:0] dnpc   ,
	input  [ADDR_WIDTH -1:0] pc     ,
	input  [DATA_WIDTH -1:0] imm    ,
	input  [DATA_WIDTH -1:0] shamt  ,
	input  [DATA_WIDTH -1:0] src1	  ,
	input  [DATA_WIDTH -1:0] src2	  ,
	input  [DATA_WIDTH -1:0] csrs   ,
	input  [RS_WIDTH   -1:0] rd     ,
	input  [OPMUX_WIDTH-1:0] opmux	,
	input  [OPSEL_WIDTH-1:0] opsel  ,
	input  [DATA_WIDTH -1:0] mwdata ,
	input	 								   memwr  ,
	input	 								   memre  ,
	input	 								   regwr  ,	
	input									   csr1wr ,	
	input									   csr2wr ,	
	input  [CAR_WIDTH  -1:0] csr1rd	,
	input  [CAR_WIDTH  -1:0] csr2rd	,
	input	 [					  3:0] mem_mask,
	input	                   mem_sext,
	input										 is_jal ,
	input										 is_jalr,
	input										 is_bxx ,
	input										 is_ecall,
	input										 is_mret ,
	input										 is_csrrs,
	input										 is_csrrc,
	input										 is_csrrw,
	input [DATA_WIDTH-1 :0]  mepc ,
	input [DATA_WIDTH-1 :0]  mtvec,
	//ifu
  /*verilator lint_off UNUSED*/
	output								   isRAW_control,
	output [ADDR_WIDTH -1:0] exu_dnpc ,
	//lsu
`ifdef VERILATOR
	output 									 lsu_ebreak,
	output [DATA_WIDTH -1:0] lsu_inst	 ,
	output [ADDR_WIDTH -1:0] lsu_snpc	 ,
	output [RS_WIDTH   -1:0] lsu_rs1	 ,
	output									 lsu_jal   ,
	output									 lsu_jalr  ,
	output [ADDR_WIDTH -1:0] lsu_dnpc ,
`endif
	output [ADDR_WIDTH -1:0] lsu_pc		 ,
	output [DATA_WIDTH -1:0] lsu_mwdata,
	output	 								 lsu_memwr ,
	output	 								 lsu_memre ,
	output	 								 lsu_csr1wr,	
	output	 								 lsu_csr2wr,	
	output	 								 lsu_regwr ,	
	output [					  3:0] lsu_mask	 ,
	output                   lsu_sext  ,
	output [DATA_WIDTH -1:0] paddr     ,
	output [RS_WIDTH   -1:0] gpr_rd		 ,
	output [DATA_WIDTH -1:0] gpr_res   ,  
	output [CAR_WIDTH  -1:0] csr_rd1	 ,
	output [CAR_WIDTH  -1:0] csr_rd2	 ,
	output [DATA_WIDTH -1:0] csr_res1  ,
	output [DATA_WIDTH -1:0] csr_res2   
);

//ALU
wire [DATA_WIDTH-1:0] alu_result;
reg [DATA_WIDTH -1:0] ina;
reg [DATA_WIDTH -1:0] inb;

always @(*) begin
	case(opmux) 
		4'b0001 : begin 
			ina = src1;
			inb = src2;
		end
		4'b0010 : begin
			ina = src1;
			inb = imm;
		end 
		4'b0011 : begin 
			ina = pc;
			inb = imm;
		end
		4'b0100 : begin 
			ina = src1;
			inb = shamt;
		end 
		4'b0101 : begin
			ina = imm;
			inb = 32'd0;
		end 
		4'b0110 : begin
			ina = pc;
			inb = 32'd4;
		end 
		4'b0111 : begin
			ina = csrs;
			inb = 32'd0;
		end 
		default : begin
			ina = 32'd0;
	  	inb = 32'd0;
		end
	endcase
end

ysyx_25010009_ALU #(
	.DATA_WIDTH (DATA_WIDTH),
	.OPSEL_WIDTH(OPSEL_WIDTH)
) alu(
	.sel(opsel ),
	.ina(ina	 ),
	.inb(inb   ),
	.out(alu_result)
);

wire is_shiftl  = opsel == 4'b0110;
wire is_shiftru = opsel == 4'b0111;
wire is_shiftrs = opsel == 4'b1000;
wire [1:0] shift_sel = is_shiftl  ? 2'b01 :
											 is_shiftru ? 2'b11 :
											 is_shiftrs ? 2'b10 : 2'b00;
wire [DATA_WIDTH-1:0] shift_res;
ysyx_25010009_SHIFT SHIFT(
	.a		(ina			 ),
	.shamt(inb[4:0]  ),
	.sel	(shift_sel ),
	.out	(shift_res )
);
 
//pcadder
wire is_jmp;
wire [DATA_WIDTH-1:0] pcadder_a;
wire [DATA_WIDTH-1:0] pcadder_b;
wire [DATA_WIDTH-1:0] pcadder_result;
/*verilator lint_off UNUSED*/
wire cout;
ysyx_25010009_CLA pcadder(
	.a   (pcadder_a			),
	.b   (pcadder_b			),
	.cin (0							),
	.sum (pcadder_result),
	.cout(cout          )
);

assign is_jmp    = is_jal || is_jalr || (is_bxx && (alu_result == 32'd1));
assign pcadder_a = is_jalr ? src1 : pc   ;
assign pcadder_b = is_jmp  ? imm  : 32'd4;


assign exu_dnpc  = is_ecall ? mtvec : 
									 is_mret  ? mepc  : pcadder_result; 
assign isRAW_control = (exu_dnpc != dnpc); 

assign paddr   = alu_result;
assign gpr_res = shift_sel != 2'b00 ? shift_res : alu_result;
assign gpr_rd  = rd;
assign csr_rd1 = csr1rd;
assign csr_rd2 = csr2rd;
assign csr_res1= is_ecall ? pc    				 : 
								 is_csrrc ? csrs & (~src1) : 
								 is_csrrs ? csrs |   src1  : 
								 is_csrrw ?          src1  : 0;
assign csr_res2= is_ecall ? 32'hb	 : 0;

assign lsu_pc			= pc		;
assign lsu_mwdata = mwdata;
assign lsu_memwr	= memwr ;
assign lsu_memre  = memre ;
assign lsu_regwr  = regwr ;
assign lsu_csr1wr = csr1wr;
assign lsu_csr2wr = csr2wr;
assign lsu_mask   = mem_mask;
assign lsu_sext   = mem_sext;

`ifdef VERILATOR
assign lsu_ebreak = ebreak;
assign lsu_inst		= inst	;
assign lsu_snpc   = pc + 4;
assign lsu_dnpc   = exu_dnpc;
assign lsu_rs1		= rs1		;
assign lsu_jal		= is_jal ;
assign lsu_jalr		= is_jalr;
`endif

endmodule
