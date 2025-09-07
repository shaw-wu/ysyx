module ysyx_25010009_exu #(
	parameter DATA_WIDTH  = 32, 
	parameter ADDR_WIDTH  = 32, 
	parameter RS_WIDTH    = 5 , 
	parameter OPSEL_WIDTH = 4 ,
	parameter OPMUX_WIDTH = 4
)(
	input clk,
	input rst,
	//idu
`ifdef VERILATOR
	input										 ebreak	,
	input  [DATA_WIDTH -1:0] a0			,
	input  [DATA_WIDTH -1:0] inst		,
`endif
	input  [ADDR_WIDTH -1:0] dnpc   ,
	input  [ADDR_WIDTH -1:0] pc     ,
	input  [DATA_WIDTH -1:0] imm    ,
	input  [DATA_WIDTH -1:0] shamt  ,
	input  [DATA_WIDTH -1:0] src1	  ,
	input  [DATA_WIDTH -1:0] src2	  ,
	input  [RS_WIDTH   -1:0] rd     ,
	input  [OPMUX_WIDTH-1:0] opmux	,
	input  [OPSEL_WIDTH-1:0] opsel  ,
	input  [DATA_WIDTH -1:0] mwdata ,
	input	 								   memwr  ,
	input	 								   memre  ,
	input	 								   regwr  ,	
	input										 is_jal ,
	input										 is_jalr,
	input										 is_bxx ,
	//ifu
  /*verilator lint_off UNUSED*/
	output								   isRAW_control,
	output [ADDR_WIDTH -1:0] exu_dnpc ,
	//lsu
`ifdef VERILATOR
	output 									 lsu_ebreak,
	output [DATA_WIDTH -1:0] lsu_a0		 ,
	output [DATA_WIDTH -1:0] lsu_inst	 ,
	output [ADDR_WIDTH -1:0] lsu_snpc	 ,
`endif
	output [ADDR_WIDTH -1:0] lsu_pc		 ,
	output [DATA_WIDTH -1:0] lsu_mwdata,
	output	 								 lsu_memwr ,
	output	 								 lsu_memre ,
	output	 								 lsu_regwr ,	
	output [DATA_WIDTH -1:0] paddr     ,
	output [RS_WIDTH   -1:0] gpr_rd		 ,
	output [DATA_WIDTH -1:0] gpr_res   
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


assign exu_dnpc  = pcadder_result; 
assign isRAW_control = (exu_dnpc != dnpc); 

assign paddr   = alu_result;
assign gpr_res = alu_result;
assign gpr_rd  = rd;

assign lsu_pc			= pc		;
assign lsu_mwdata = mwdata;
assign lsu_memwr	= memwr ;
assign lsu_memre  = memre ;
assign lsu_regwr  = regwr ;

`ifdef VERILATOR
assign lsu_ebreak = ebreak;
assign lsu_a0			= a0		;
assign lsu_inst		= inst	;
assign lsu_snpc   = pc + 4;
`endif

endmodule
