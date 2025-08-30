`timescale 1ns / 1ps
module ysyx_25010009_top #(
	parameter PC_INIT			 = 32'h8000_0000,
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32,
	parameter RS_WIDTH     = 5 , 
	parameter FUNCT3_WIDTH = 3 , 
	parameter FUNCT7_WIDTH = 7 , 
	parameter OPCODE_WIDTH = 7 , 
	parameter OPSEL_WIDTH  = 4 ,
	parameter OPMUX_WIDTH  = 4 ,
	parameter PCMUX_WIDTH  = 2 ,
	parameter INST_BITS		 = 6 
)(
	input clk,
	input rst
);

wire [DATA_WIDTH-1:0] irom_data;
wire [ADDR_WIDTH-1:0] irom_addr;

wire [ADDR_WIDTH-1:0] ifu_idu_inst;
wire [ADDR_WIDTH-1:0] ifu_idu_pc	;
wire [ADDR_WIDTH-1:0] ifu_idu_snpc;
wire [ADDR_WIDTH-1:0] ifu_idu_dnpc;

wire [ADDR_WIDTH -1:0] idu_exu_snpc	 ; 
wire [ADDR_WIDTH -1:0] idu_exu_dnpc	 ; 
wire [ADDR_WIDTH -1:0] idu_exu_pc		 ; 
wire [DATA_WIDTH -1:0] idu_exu_imm 	 ; 
wire [DATA_WIDTH -1:0] idu_exu_src1	 ; 
wire [DATA_WIDTH -1:0] idu_exu_src2	 ; 
wire [RS_WIDTH	 -1:0] idu_exu_rd    ;  
wire [OPSEL_WIDTH-1:0] idu_exu_opsel ;	 
wire [DATA_WIDTH -1:0] idu_exu_mwdata;
wire idu_exu_memwr  ;
wire idu_exu_memre  ;
wire idu_exu_regwr  ;
wire idu_exu_is_jalr;
wire idu_exu_is_jal ;
wire idu_exu_is_bxx ;
wire [RS_WIDTH	-1:0] idu_rf_rs1		 ;
wire [RS_WIDTH	-1:0] idu_rf_rs2		 ;
wire [DATA_WIDTH-1:0] idu_rf_src1;
wire [DATA_WIDTH-1:0] idu_rf_src2;

wire [ADDR_WIDTH-1:0] exu_lsu_pc		;
wire [DATA_WIDTH-1:0] exu_lsu_mwdata;
wire exu_lsu_memwr 	;
wire exu_lsu_memre 	;
wire exu_wbu_regwr 	;
wire [ADDR_WIDTH-1:0] exu_lsu_paddr  ;
wire [RS_WIDTH-1:0  ] exu_wbu_rd ;
wire [DATA_WIDTH-1:0] exu_wbu_res;
wire [ADDR_WIDTH-1:0] exu_dnpc;

wire [RS_WIDTH  -1:0] wbu_rf_rd	  ;		 
wire [DATA_WIDTH-1:0] wbu_rf_wdata;	 
wire wbu_rf_wen; 	 

ysyx_25010009_irom #(
	.XLEN(DATA_WIDTH)
) IROM (
	.addr(irom_addr),
	.inst(irom_data)
);

ysyx_25010009_ifu #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.PC_INIT	 (PC_INIT		)
) IFU (
	.clk(clk),
	.rst(rst),
	.finst(irom_data),
	.addr	(irom_addr),
	.inst (ifu_idu_inst),
	.pc		(ifu_idu_pc	 ),
	.snpc (ifu_idu_snpc),
	.dnpc (ifu_idu_dnpc),
	.is_RAW_control(1'b0),
	.exu_dnpc(exu_dnpc )
);

ysyx_25010009_idu #(
	.ADDR_WIDTH  (ADDR_WIDTH  ), 
	.DATA_WIDTH  (DATA_WIDTH  ),
	.RS_WIDTH    (RS_WIDTH    ), 
	.FUNCT3_WIDTH(FUNCT3_WIDTH), 
	.FUNCT7_WIDTH(FUNCT7_WIDTH), 
	.OPCODE_WIDTH(OPCODE_WIDTH), 
	.OPSEL_WIDTH (OPSEL_WIDTH ),
	.OPMUX_WIDTH (OPMUX_WIDTH ),
	.INST_BITS	 (INST_BITS		),
	.PCMUX_WIDTH (PCMUX_WIDTH )
) IDU (
	.clk		 (clk						 ),
	.rst     (rst     			 ),
	.inst    (ifu_idu_inst   ),
	.pc			 (ifu_idu_pc		 ),
	.snpc	   (ifu_idu_snpc	 ),
	.dnpc	   (ifu_idu_dnpc	 ),
	.exu_snpc(idu_exu_snpc	 ),
	.exu_dnpc(idu_exu_dnpc	 ),
	.exu_pc	 (idu_exu_pc		 ),
  .exu_imm (idu_exu_imm 	 ),
	.src1		 (idu_exu_src1	 ),
  .src2		 (idu_exu_src2	 ),
	.rd      (idu_exu_rd     ),
	.opsel	 (idu_exu_opsel	 ),
	.mwdata  (idu_exu_mwdata ),
	.memwr   (idu_exu_memwr  ),
	.memre   (idu_exu_memre  ),
	.regwr   (idu_exu_regwr  ),	
	.is_jalr (idu_exu_is_jalr),
	.is_jal  (idu_exu_is_jal ),
	.is_bxx  (idu_exu_is_bxx ),
	.rs1		 (idu_rf_rs1		 ),
	.rs2		 (idu_rf_rs2		 ),
	.rf_src1 (idu_rf_src1		 ),
  .rf_src2 (idu_rf_src2 	 )
);

ysyx_25010009_exu #(
	.DATA_WIDTH (DATA_WIDTH ), 
	.RS_WIDTH   (RS_WIDTH   ), 
	.OPSEL_WIDTH(OPSEL_WIDTH)
) EXU (
	.clk					(clk					),
	.rst					(rst					),
	.dnpc					(idu_exu_dnpc					),
	.pc     			(idu_exu_pc     			),
	.imm    			(idu_exu_imm    			),
	.src1	  			(idu_exu_src1	  			),
  .src2	  			(idu_exu_src2	  			),
	.rd     			(idu_exu_rd     			),
	.opsel  			(idu_exu_opsel  			),
	.mwdata 			(idu_exu_mwdata 			),
	.memwr  			(idu_exu_memwr  			),
	.memre  			(idu_exu_memre  			),
	.regwr  			(idu_exu_regwr  			),	
	.is_jal 			(idu_exu_is_jal 			),
	.is_jalr			(idu_exu_is_jalr			),
	.is_bxx 			(idu_exu_is_bxx 			),
	.isRAW_control(             				),
	.exu_dnpc			(exu_dnpc						  ),
	.lsu_pc		 		(exu_lsu_pc		 				),
	.lsu_mwdata		(exu_lsu_mwdata				),
	.lsu_memwr 		(exu_lsu_memwr 				),
	.lsu_memre 		(exu_lsu_memre 				),
	.lsu_regwr 		(exu_wbu_regwr 				),	
	.paddr     		(exu_lsu_paddr    		),
	.gpr_rd		 		(exu_wbu_rd						),
	.gpr_res   		(exu_wbu_res  				)
);

ysyx_25010009_wbu #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.RS_WIDTH  (RS_WIDTH  )
) WBU (
	.clk		 (clk						 ),
	.rst		 (rst		    		 ),
	.pc		   (exu_lsu_pc		 ),
	.regwr   (exu_wbu_regwr	 ),	
	.rd		   (exu_wbu_rd		 ),
	.gpr_res (exu_wbu_res		 ),  
	.rf_rd	 (wbu_rf_rd			 ),
	.rf_wdata(wbu_rf_wdata	 ),
	.rf_wen  (wbu_rf_wen  	 )
);

ysyx_25010009_RegisterFile #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(RS_WIDTH  )
) GPR (
	.clk		 (clk						 ),
	.rst		 (rst		    		 ),
	.wdata	 (wbu_rf_wdata	 ),
	.waddr	 (wbu_rf_rd			 ),
	.raddr1	 (idu_rf_rs1		 ),
	.raddr2	 (idu_rf_rs2		 ),
	.rdata1	 (idu_rf_src1		 ),
	.rdata2	 (idu_rf_src2		 ),
	.wen		 (wbu_rf_wen		 )
);

endmodule
