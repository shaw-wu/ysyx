`timescale 1ns / 1ps
module ysyx_25010009_top #(
	parameter PC_INIT			 = 32'h8000_0000,
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32,
	parameter RS_WIDTH     = 5 , 
	parameter CAR_WIDTH    = 12, 
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

localparam MSTATUS   = 12'h300;
localparam MTVEC	   = 12'h305;
localparam MEPC      = 12'h341;
localparam MCAUSE    = 12'h342;
localparam MCYCLE    = 12'hb00;
localparam MCYCLEH   = 12'hb01;
localparam MVENDORID = 12'hf11;
localparam MARCHID   = 12'hf12;

`ifdef CONFIG_RVE
	parameter GPR_NUM = 16;
`else
	parameter GPR_NUM = 32;
`endif

wire [DATA_WIDTH-1:0] irom_data;
wire [ADDR_WIDTH-1:0] irom_addr;

wire								  dram_awvalid;
wire								  dram_arvalid;
wire [					 3:0] dram_mask ;
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
wire [3:0] idu_exu_mask;
wire idu_exu_sext;
wire idu_exu_regwr ;
wire idu_exu_csr1wr; 
wire idu_exu_csr2wr; 
wire [CAR_WIDTH -1:0] idu_exu_csr1rd; 
wire [CAR_WIDTH -1:0] idu_exu_csr2rd; 
wire idu_exu_is_jalr;
wire idu_exu_is_jal ;
wire idu_exu_is_bxx ;
wire idu_exu_is_ecall;
wire idu_exu_is_mret;
wire idu_exu_is_csrrc;
wire idu_exu_is_csrrs;
wire idu_exu_is_csrrw;
wire [DATA_WIDTH-1:0] idu_exu_csrs;
wire [DATA_WIDTH-1:0] idu_exu_mepc;
wire [DATA_WIDTH-1:0] idu_exu_mtvec;
wire [RS_WIDTH	-1:0] idu_rf_rs1 ;
wire [RS_WIDTH	-1:0] idu_rf_rs2 ;
wire [DATA_WIDTH-1:0] idu_rf_src1;
wire [DATA_WIDTH-1:0] idu_rf_src2;
wire [CAR_WIDTH	-1:0] idu_rf_csr ;
wire [DATA_WIDTH-1:0] idu_rf_csrs;
wire [DATA_WIDTH-1:0] idu_rf_mepc;
wire [DATA_WIDTH-1:0] idu_rf_mtvec;

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
wire exu_lsu_csr1wr 	;
wire exu_lsu_csr2wr 	;
wire [3:0] exu_lsu_mask;
wire exu_lsu_sext;
wire [ADDR_WIDTH-1:0] exu_lsu_paddr  ;
wire [RS_WIDTH-1:0  ] exu_lsu_rd ;
wire [DATA_WIDTH-1:0] exu_lsu_res;
wire [CAR_WIDTH-1:0 ] exu_lsu_csr1;
wire [CAR_WIDTH-1:0 ] exu_lsu_csr2;
wire [DATA_WIDTH-1:0] exu_lsu_csrs1;
wire [DATA_WIDTH-1:0] exu_lsu_csrs2;
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
wire									lsu_wbu_csr1wr;
wire									lsu_wbu_csr2wr;
wire [RS_WIDTH-1:0  ] lsu_wbu_rd ;
wire [DATA_WIDTH-1:0] lsu_wbu_res;
wire [CAR_WIDTH-1:0 ] lsu_wbu_csr1;
wire [CAR_WIDTH-1:0 ] lsu_wbu_csr2;
wire [DATA_WIDTH-1:0 ] lsu_wbu_csrs1;
wire [DATA_WIDTH-1:0 ] lsu_wbu_csrs2;

wire [RS_WIDTH  -1:0] wbu_rf_rd	  ;		 
wire [DATA_WIDTH-1:0] wbu_rf_wdata;	 
wire wbu_rf_wen; 	 
wire [CAR_WIDTH  -1:0] wbu_rf_csr1;		 
wire [CAR_WIDTH  -1:0] wbu_rf_csr2;		 
wire [DATA_WIDTH-1:0] wbu_rf_csrs1;	 
wire [DATA_WIDTH-1:0] wbu_rf_csrs2;	 
wire wbu_rf_cwen1; 	 
wire wbu_rf_cwen2; 	 

wire speec;

ysyx_25010009_irom #(
	.XLEN(DATA_WIDTH)
) IROM (
	.rst (rst),
	.addr(irom_addr),
	.inst(irom_data)
);

ysyx_25010009_dram #(
	.XLEN(DATA_WIDTH)
) DRAM (
	.clk	(clk),
	.rst	(rst),
	.mask		(dram_mask	 ),
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
	.CAR_WIDTH   (CAR_WIDTH   ), 
	.FUNCT3_WIDTH(FUNCT3_WIDTH), 
	.FUNCT7_WIDTH(FUNCT7_WIDTH), 
	.OPCODE_WIDTH(OPCODE_WIDTH), 
	.OPSEL_WIDTH (OPSEL_WIDTH ),
	.OPMUX_WIDTH (OPMUX_WIDTH ),
	.INST_BITS	 (INST_BITS		),
	.PCMUX_WIDTH (PCMUX_WIDTH ),
	.MSTATUS		 (MSTATUS			),
	.MTVEC			 (MTVEC	 			),
	.MEPC   		 (MEPC   			),
	.MCAUSE 		 (MCAUSE 			) 
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
	.mem_mask(idu_exu_mask	 ),
	.mem_sext(idu_exu_sext	 ),
	.regwr   (idu_exu_regwr  ),	
	.csr1wr	 (idu_exu_csr1wr ),
	.csr2wr	 (idu_exu_csr2wr ),
	.csr1rd	 (idu_exu_csr1rd ),
	.csr2rd	 (idu_exu_csr2rd ),
	.is_jalr (idu_exu_is_jalr),
	.is_jal  (idu_exu_is_jal ),
	.is_bxx  (idu_exu_is_bxx ),
	.is_ecall(idu_exu_is_ecall),
	.is_mret (idu_exu_is_mret ),
	.is_csrrc(idu_exu_is_csrrc),
	.is_csrrs(idu_exu_is_csrrs),
	.is_csrrw(idu_exu_is_csrrw),
	.exu_csrs (idu_exu_csrs  ),
	.exu_mepc (idu_exu_mepc	 ),
	.exu_mtvec(idu_exu_mtvec ),
	.csr		 (idu_rf_csr		 ),
	.csrs		 (idu_rf_csrs		 ),
	.rs1		 (idu_rf_rs1		 ),
	.rs2		 (idu_rf_rs2		 ),
	.rf_src1 (idu_rf_src1		 ),
  .rf_src2 (idu_rf_src2 	 ),
	.mepc	 	 (idu_rf_mepc		 ),
	.mtvec	 (idu_rf_mtvec	 )
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
	.mem_mask			(idu_exu_mask					),
	.mem_sext			(idu_exu_sext					),
	.memre  			(idu_exu_memre  			),
	.memwr  			(idu_exu_memwr  			),
	.regwr  			(idu_exu_regwr  			),	
	.csr1wr  			(idu_exu_csr1wr  			),	
	.csr2wr  			(idu_exu_csr2wr  			),	
	.csr1rd  			(idu_exu_csr1rd  			),	
	.csr2rd  			(idu_exu_csr2rd  			),	
	.is_jal 			(idu_exu_is_jal 			),
	.is_jalr			(idu_exu_is_jalr			),
	.is_bxx 			(idu_exu_is_bxx 			),
	.is_ecall			(idu_exu_is_ecall		  ),
	.is_mret			(idu_exu_is_mret		  ),
	.is_csrrc			(idu_exu_is_csrrc			),
	.is_csrrs			(idu_exu_is_csrrs			),
	.is_csrrw			(idu_exu_is_csrrw			),
	.csrs					(idu_exu_csrs					),
	.mepc					(idu_exu_mepc					),
	.mtvec				(idu_exu_mtvec				),
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
	.lsu_mask			(exu_lsu_mask					),
	.lsu_sext			(exu_lsu_sext					),
	.lsu_csr1wr 	(exu_lsu_csr1wr				),	
	.lsu_csr2wr 	(exu_lsu_csr2wr				),	
	.lsu_regwr 		(exu_lsu_regwr 				),	
	.paddr     		(exu_lsu_paddr    		),
	.gpr_rd		 		(exu_lsu_rd						),
	.gpr_res   		(exu_lsu_res  				),
	.csr_rd1			(exu_lsu_csr1					),
	.csr_rd2			(exu_lsu_csr2					),
	.csr_res1			(exu_lsu_csrs1				),
	.csr_res2			(exu_lsu_csrs2				)
);

ysyx_25010009_lsu #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.RS_WIDTH  (RS_WIDTH  ),
	.CAR_WIDTH (CAR_WIDTH )
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
	.mem_mask (exu_lsu_mask	 ),
	.mem_sext (exu_lsu_sext	 ),
	.memwr 		(exu_lsu_memwr ),
	.memre 		(exu_lsu_memre ),
	.regwr 		(exu_lsu_regwr ),	
	.csr1wr 	(exu_lsu_csr1wr),	
	.csr2wr 	(exu_lsu_csr2wr),	
	.paddr    (exu_lsu_paddr ),
	.gpr_rd		(exu_lsu_rd		 ),
	.gpr_res  (exu_lsu_res   ),
	.csr_rd1	(exu_lsu_csr1	 ),
	.csr_rd2	(exu_lsu_csr2	 ),
	.csr_res1 (exu_lsu_csrs1 ),
	.csr_res2 (exu_lsu_csrs2 ),
	.ram_mask (dram_mask		 ),
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
	.wbu_csr1wr  (lsu_wbu_csr1wr ),	
	.wbu_csr2wr  (lsu_wbu_csr2wr ),	
	.wbu_gpr_rd	 (lsu_wbu_rd		 ),
	.wbu_gpr_res (lsu_wbu_res		 ),
	.wbu_csr_rd1 (lsu_wbu_csr1	 ),
	.wbu_csr_rd2 (lsu_wbu_csr2	 ),
	.wbu_csr_res1(lsu_wbu_csrs1	 ),
	.wbu_csr_res2(lsu_wbu_csrs2	 ) 
);

ysyx_25010009_wbu #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.RS_WIDTH  (RS_WIDTH  ),
	.CAR_WIDTH (CAR_WIDTH )
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
	.csr1wr  (lsu_wbu_csr1wr ),	
	.csr2wr  (lsu_wbu_csr2wr ),	
	.rd		   (lsu_wbu_rd		 ),
	.gpr_res (lsu_wbu_res		 ),  
	.csr_rd1 (lsu_wbu_csr1	 ),
	.csr_rd2 (lsu_wbu_csr2	 ),
	.csr_res1(lsu_wbu_csrs1	 ),
	.csr_res2(lsu_wbu_csrs2	 ),
	.rf_gpr_rd	 (wbu_rf_rd			 ),
	.rf_gpr_wdata(wbu_rf_wdata	 ),
	.rf_gpr_wen  (wbu_rf_wen  	 ),
	.rf_csr_rd1	 (wbu_rf_csr1		 ),
	.rf_csr_rd2	 (wbu_rf_csr2		 ),
	.rf_csr_res1 (wbu_rf_csrs1	 ),
	.rf_csr_res2 (wbu_rf_csrs2	 ),
	.rf_csr_wen1 (wbu_rf_cwen1	 ),
	.rf_csr_wen2 (wbu_rf_cwen2	 ),
	.speec	 (speec					 )
);

ysyx_25010009_RegisterFile #(
	.GPR_NUM	 (GPR_NUM		),
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(RS_WIDTH  ),
	.MSTATUS		 (MSTATUS			),
	.MTVEC			 (MTVEC	 			),
	.MEPC   		 (MEPC   			),
	.MCAUSE 		 (MCAUSE 			),
	.MCYCLE			 (MCYCLE			),
	.MCYCLEH		 (MCYCLEH			),
	.MVENDORID	 (MVENDORID		),
	.MARCHID		 (MARCHID			)
) GPR (
	.clk		 (clk						 ),
	.rst		 (rst		    		 ),
	.gpr_wdata	 (wbu_rf_wdata	 ),
	.gpr_waddr	 (wbu_rf_rd			 ),
	.gpr_raddr1	 (idu_rf_rs1		 ),
	.gpr_raddr2	 (idu_rf_rs2		 ),
	.gpr_rdata1	 (idu_rf_src1		 ),
	.gpr_rdata2	 (idu_rf_src2		 ),
	.gpr_wen		 (wbu_rf_wen		 ),
	.csrs_wdata1 (wbu_rf_csrs1),
	.csrs_waddr1 (wbu_rf_csr1 ),
	.csrs_wdata2 (wbu_rf_csrs2),
	.csrs_waddr2 (wbu_rf_csr2 ),
	.csrs_rdata	 (idu_rf_csrs),
	.csrs_raddr	 (idu_rf_csr ),
	.csrs_wen1	 (wbu_rf_cwen1),
	.csrs_wen2	 (wbu_rf_cwen1),
	.mepc				 (idu_rf_mepc ),
	.mtvec			 (idu_rf_mtvec)
);

`ifdef VERILATOR
import "DPI-C" function void speec_once(int speec);
always @(*) 
	speec_once({31'b0, speec});
`endif

endmodule
