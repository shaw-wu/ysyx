module ysyx_25010009_exu #(
	parameter DATA_WIDTH  = 32, 
	parameter ADDR_WIDTH  = 32, 
	parameter RS_WIDTH    = 5 , 
	parameter OPSEL_WIDTH = 4
)(
	input clk,
	input rst,
	//idu
	input  [ADDR_WIDTH -1:0] dnpc   ,
	input  [ADDR_WIDTH -1:0] pc     ,
	input  [DATA_WIDTH -1:0] imm    ,
	input  [DATA_WIDTH -1:0] src1	  ,
  input  [DATA_WIDTH -1:0] src2	  ,
	input  [RS_WIDTH   -1:0] rd     ,
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
ysyx_25010009_ALU #(
	.DATA_WIDTH (DATA_WIDTH),
	.OPSEL_WIDTH(OPSEL_WIDTH)
) alu(
	.sel(opsel ),
	.ina(src1  ),
	.inb(src2  ),
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

endmodule
