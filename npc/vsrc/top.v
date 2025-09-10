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
`ifdef CONFIG_RVE
	parameter GPR_NUM = 16;
`else
	parameter GPR_NUM = 32;
`endif

wire [DATA_WIDTH-1:0] irom_data;
wire [ADDR_WIDTH-1:0] irom_addr;

wire								  dram_awvalid;
wire								  dram_arvalid;
wire [ADDR_WIDTH-1:0] dram_raddr;
wire [DATA_WIDTH-1:0] dram_rdata;
wire [ADDR_WIDTH-1:0] dram_waddr;
wire [DATA_WIDTH-1:0] dram_wdata;

wire [ADDR_WIDTH-1:0] ifu_idu_inst;
wire [ADDR_WIDTH-1:0] ifu_idu_pc	;
wire [ADDR_WIDTH-1:0] ifu_idu_snpc;
wire [ADDR_WIDTH-1:0] ifu_idu_dnpc;

`ifdef VERILATOR
wire                   idu_exu_ebreak; 
wire [DATA_WIDTH -1:0] idu_exu_a0		 ; 
wire [DATA_WIDTH -1:0] idu_exu_inst	 ; 
`endif
wire [ADDR_WIDTH -1:0] idu_exu_snpc	 ; 
wire [ADDR_WIDTH -1:0] idu_exu_dnpc	 ; 
wire [ADDR_WIDTH -1:0] idu_exu_pc		 ; 
wire [DATA_WIDTH -1:0] idu_exu_shamt ; 
wire [DATA_WIDTH -1:0] idu_exu_imm 	 ; 
wire [DATA_WIDTH -1:0] idu_exu_src1	 ; 
wire [DATA_WIDTH -1:0] idu_exu_src2	 ; 
wire [RS_WIDTH	 -1:0] idu_exu_rd    ;  
wire [OPMUX_WIDTH-1:0] idu_exu_opmux ;	 
wire [OPSEL_WIDTH-1:0] idu_exu_opsel ;	 
wire [DATA_WIDTH -1:0] idu_exu_mwdata;
wire idu_exu_memwr  ;
wire idu_exu_memre  ;
wire idu_exu_regwr  ;
wire idu_exu_is_jalr;
wire idu_exu_is_jal ;
wire idu_exu_is_bxx ;
wire [RS_WIDTH	-1:0] idu_rf_rs1 ;
wire [RS_WIDTH	-1:0] idu_rf_rs2 ;
wire [DATA_WIDTH-1:0] idu_rf_src1;
wire [DATA_WIDTH-1:0] idu_rf_src2;

`ifdef VERILATOR
wire exu_lsu_ebreak;
wire [DATA_WIDTH-1:0] exu_lsu_a0  ;
wire [DATA_WIDTH-1:0] exu_lsu_inst;
wire [ADDR_WIDTH-1:0] exu_lsu_snpc;
wire [ADDR_WIDTH-1:0] exu_lsu_dnpc;
wire [RS_WIDTH-1:0  ] exu_lsu_rs1	;
wire                  exu_lsu_jal ;
wire                  exu_lsu_jalr;
`endif
wire [ADDR_WIDTH-1:0] exu_lsu_pc		;
wire [DATA_WIDTH-1:0] exu_lsu_mwdata;
wire exu_lsu_memwr 	;
wire exu_lsu_memre 	;
wire exu_lsu_regwr 	;
wire [ADDR_WIDTH-1:0] exu_lsu_paddr  ;
wire [RS_WIDTH-1:0  ] exu_lsu_rd ;
wire [DATA_WIDTH-1:0] exu_lsu_res;
wire [ADDR_WIDTH-1:0] exu_dnpc;

`ifdef VERILATOR
wire lsu_wbu_ebreak;
wire [DATA_WIDTH-1:0] lsu_wbu_inst;
wire [ADDR_WIDTH-1:0] lsu_wbu_snpc;
wire [ADDR_WIDTH-1:0] lsu_wbu_dnpc;
wire [RS_WIDTH-1:0  ] lsu_wbu_rs1 ;
wire                  lsu_wbu_jal ;
wire                  lsu_wbu_jalr;
`endif
wire [ADDR_WIDTH-1:0] lsu_wbu_pc;
wire									lsu_wbu_regwr;
wire [RS_WIDTH-1:0  ] lsu_wbu_rd ;
wire [DATA_WIDTH-1:0] lsu_wbu_res;

wire [RS_WIDTH  -1:0] wbu_rf_rd	  ;		 
wire [DATA_WIDTH-1:0] wbu_rf_wdata;	 
wire wbu_rf_wen; 	 

wire speec;

ysyx_25010009_irom #(
	.XLEN(DATA_WIDTH)
) IROM (
	.addr(irom_addr),
	.inst(irom_data)
);

ysyx_25010009_dram #(
	.XLEN(DATA_WIDTH)
) DRAM (
	.clk	(clk),
	.rst	(rst),
	.awvalid(dram_awvalid),
	.arvalid(dram_arvalid),
	.raddr(dram_raddr),
	.rdata(dram_rdata),
	.waddr(dram_waddr),
	.wdata(dram_wdata)
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
`ifdef VERILATOR
	.exu_ebreak(idu_exu_ebreak),
	.exu_inst  (idu_exu_inst	),
`endif
	.exu_snpc(idu_exu_snpc	 ),
	.exu_dnpc(idu_exu_dnpc	 ),
	.exu_pc	 (idu_exu_pc		 ),
	.exu_shamt(idu_exu_shamt ),
  .exu_imm (idu_exu_imm 	 ),
	.src1		 (idu_exu_src1	 ),
	.src2		 (idu_exu_src2	 ),
	.rd      (idu_exu_rd     ),
	.opmux	 (idu_exu_opmux  ),
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
`ifdef VERILATOR
	.ebreak				(idu_exu_ebreak			  ),
	.inst					(idu_exu_inst				  ),
	.rs1					(idu_rf_rs1					  ),
`endif
	.dnpc					(idu_exu_dnpc					),
	.pc     			(idu_exu_pc     			),
	.imm    			(idu_exu_imm    			),
	.shamt				(idu_exu_shamt			  ),
	.src1	  			(idu_exu_src1	  			),
	.src2	  			(idu_exu_src2	  			),
	.rd     			(idu_exu_rd     			),
	.opmux			  (idu_exu_opmux  			),
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
`ifdef VERILATOR
	.lsu_ebreak	  (exu_lsu_ebreak				),
	.lsu_inst			(exu_lsu_inst					),
	.lsu_snpc			(exu_lsu_snpc					),
	.lsu_rs1			(exu_lsu_rs1					),
	.lsu_jal			(exu_lsu_jal				  ),
	.lsu_jalr			(exu_lsu_jalr				  ),
	.lsu_dnpc			(exu_lsu_dnpc				  ),
`endif
	.lsu_pc		 		(exu_lsu_pc		 				),
	.lsu_mwdata		(exu_lsu_mwdata				),
	.lsu_memwr 		(exu_lsu_memwr 				),
	.lsu_memre 		(exu_lsu_memre 				),
	.lsu_regwr 		(exu_lsu_regwr 				),	
	.paddr     		(exu_lsu_paddr    		),
	.gpr_rd		 		(exu_lsu_rd						),
	.gpr_res   		(exu_lsu_res  				)
);

ysyx_25010009_lsu #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.RS_WIDTH  (RS_WIDTH  )
) LSU (
	.clk		 (clk						 ),
	.rst		 (rst		    		 ),
`ifdef VERILATOR
	.ebreak	  (exu_lsu_ebreak),
	.inst			(exu_lsu_inst	 ),
	.snpc			(exu_lsu_snpc	 ),
	.dnpc			(exu_lsu_dnpc	 ),
	.rs1			(exu_lsu_rs1	 ),
	.jal			(exu_lsu_jal	 ),
	.jalr			(exu_lsu_jalr	 ),
`endif
	.pc		 		(exu_lsu_pc		 ),
	.mwdata		(exu_lsu_mwdata),
	.memwr 		(exu_lsu_memwr ),
	.memre 		(exu_lsu_memre ),
	.regwr 		(exu_lsu_regwr ),	
	.paddr    (exu_lsu_paddr ),
	.gpr_rd		(exu_lsu_rd		 ),
	.gpr_res  (exu_lsu_res   ),
	.awvalid  (dram_awvalid  ),
	.arvalid  (dram_arvalid  ),
	.araddr		(dram_raddr),
	.rdata    (dram_rdata),
	.awaddr		(dram_waddr),
	.wdata    (dram_wdata),
`ifdef VERILATOR
	.wbu_ebreak (lsu_wbu_ebreak ),
	.wbu_inst		(lsu_wbu_inst		),
	.wbu_snpc		(lsu_wbu_snpc		),
	.wbu_dnpc		(lsu_wbu_dnpc		),
	.wbu_rs1		(lsu_wbu_rs1    ),
	.wbu_jal		(lsu_wbu_jal		),
	.wbu_jalr		(lsu_wbu_jalr		),
`endif
	.wbu_pc			 (lsu_wbu_pc		 ),
	.wbu_regwr   (lsu_wbu_regwr	 ),	
	.wbu_gpr_rd	 (lsu_wbu_rd		 ),
	.wbu_gpr_res (lsu_wbu_res		 )  
);

ysyx_25010009_wbu #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.RS_WIDTH  (RS_WIDTH  )
) WBU (
	.clk		 (clk						 ),
	.rst		 (rst		    		 ),
	.pc		   (lsu_wbu_pc		 ),
`ifdef VERILATOR
	.ebreak  (lsu_wbu_ebreak ),
	.inst		 (lsu_wbu_inst	 ),
	.snpc		 (lsu_wbu_snpc   ),
	.dnpc		 (lsu_wbu_dnpc   ),
	.rs1		 (lsu_wbu_rs1		 ),
	.jal		 (lsu_wbu_jal		 ),
	.jalr		 (lsu_wbu_jalr	 ),
`endif
	.regwr   (lsu_wbu_regwr	 ),	
	.rd		   (lsu_wbu_rd		 ),
	.gpr_res (lsu_wbu_res		 ),  
	.rf_rd	 (wbu_rf_rd			 ),
	.rf_wdata(wbu_rf_wdata	 ),
	.rf_wen  (wbu_rf_wen  	 ),
	.speec	 (speec					 )
);

ysyx_25010009_RegisterFile #(
	.GPR_NUM	 (GPR_NUM		),
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

`ifdef VERILATOR
import "DPI-C" function void speec_once(int speec);
always @(*) 
	speec_once({31'b0, speec});
`endif

endmodule
