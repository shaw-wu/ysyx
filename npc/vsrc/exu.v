module ysyx_25010009_exu #(
	parameter DATA_WIDTH  = 32, 
	parameter RS_WIDTH    = 5 , 
	parameter OPSEL_WIDTH = 4
)(
	input clk,
	input rst,
	//idu
	input  [DATA_WIDTH -1:0] src1	 ,
  input  [DATA_WIDTH -1:0] src2	 ,
	input  [RS_WIDTH   -1:0] rd    ,
	input  [OPSEL_WIDTH-1:0] opsel ,
	input  [DATA_WIDTH -1:0] csr	 ,
	input  [DATA_WIDTH -1:0] mwdata,
	input	 								   memwr ,
	input	 								   memre ,
	input	 								   regwr ,	
	input	 								   csrwr ,	
	input  [ADDR_WIDTH -1:0] pc    ,
	input  [ADDR_WIDTH -1:0] snpc  ,
	input										 is_csr,
	input										 is_jmp,
	//ifu
	output [ADDR_WIDTH -1:0] dnpc  ,
	//lsu
	output [ADDR_WIDTH -1:0] lsu_pc		 ,
	input  [DATA_WIDTH -1:0] lsu_mwdata,
	input	 								   lsu_memwr ,
	input	 								   lsu_memre ,
	input	 								   lsu_regwr ,	
	input	 								   lsu_csrwr ,	
	output [DATA_WIDTH -1:0] paddr     ,
	output [DATA_WIDTH -1:0] csr_res   ,
	output [DATA_WIDTH -1:0] gpr_res   
);

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

assign paddr   = alu_result;
assign csr_res = alu_result;
assign gpr_res = is_csr ? csr    : alu_result;

assign lsu_pc			= pc		;
assign lsu_mwdata = mwdata;
assign lsu_memwr	= memwr ;
assign lsu_memre  = memre ;
assign lsu_regwr  = regwr ;
assign lsu_csrwr  = csrwr ;

assign dnpc = is_jmp ? alu_result : snpc; 

endmodule
