`timescale 1ns / 1ps
module ysyx_25010009 (
	input clock,
	input reset, 
	output        io_ifu_reqValid,
	output [31:0] io_ifu_addr,
	input         io_ifu_respValid,
	input  [31:0] io_ifu_rdata,
	output        io_lsu_reqValid,
	output [31:0] io_lsu_addr,
	output [1 :0] io_lsu_size,
	output        io_lsu_wen,
	output [31:0] io_lsu_wdata,
	output [3 :0] io_lsu_wmask,
	input         io_lsu_respValid,
	input  [31:0] io_lsu_rdata
);

parameter PC_INIT			 = 32'h3000_0000;
parameter ADDR_WIDTH   = 32; 
parameter DATA_WIDTH   = 32;
parameter RS_WIDTH     = 4 ; 
parameter CAR_WIDTH    = 12; 
parameter FUNCT3_WIDTH = 3 ; 
parameter FUNCT7_WIDTH = 7 ; 
parameter OPCODE_WIDTH = 7 ; 
parameter OPSEL_WIDTH  = 4 ;
parameter OPMUX_WIDTH  = 4 ;
parameter PCMUX_WIDTH  = 2 ;
parameter INST_BITS		 = 6 ; 
localparam MSTATUS   = 12'h300;
localparam MTVEC	   = 12'h305;
localparam MEPC      = 12'h341;
localparam MCAUSE    = 12'h342;
localparam MCYCLE    = 12'hb00;
localparam MCYCLEH   = 12'hb01;
localparam MVENDORID = 12'hf11;
localparam MARCHID   = 12'hf12;

parameter GPR_NUM = 16;

wire ifu_idu_valid;
wire [ADDR_WIDTH-1:0] ifu_idu_inst;
wire [ADDR_WIDTH-1:0] ifu_idu_pc	;
wire [ADDR_WIDTH-1:0] ifu_idu_snpc;
wire [ADDR_WIDTH-1:0] ifu_idu_dnpc;

//`ifdef VERILATOR
//wire                   idu_exu_ebreak; 
//wire [DATA_WIDTH -1:0] idu_exu_a0		 ; 
////wire [DATA_WIDTH -1:0] idu_exu_inst	 ; 
//`endif
wire idu_exu_valid;
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
wire [DATA_WIDTH-1:0] idu_rf_a0	 ;
wire [CAR_WIDTH	-1:0] idu_rf_csr ;
wire [DATA_WIDTH-1:0] idu_rf_csrs;
wire [DATA_WIDTH-1:0] idu_rf_mepc;
wire [DATA_WIDTH-1:0] idu_rf_mtvec;

//`ifdef VERILATOR
//wire exu_lsu_ebreak;
//wire [DATA_WIDTH-1:0] exu_lsu_a0  ;
////wire [DATA_WIDTH-1:0] exu_lsu_inst;
////wire [ADDR_WIDTH-1:0] exu_lsu_snpc;
////wire [ADDR_WIDTH-1:0] exu_lsu_dnpc;
////wire [RS_WIDTH-1:0  ] exu_lsu_rs1	;
////wire                  exu_lsu_jal ;
////wire                  exu_lsu_jalr;
//`endif
wire									exu_lsu_valid ;
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

//`ifdef VERILATOR
//wire lsu_wbu_ebreak;
//wire [DATA_WIDTH-1:0] lsu_wbu_a0  ;
////wire [DATA_WIDTH-1:0] lsu_wbu_inst;
////wire [ADDR_WIDTH-1:0] lsu_wbu_snpc;
////wire [ADDR_WIDTH-1:0] lsu_wbu_dnpc;
////wire [RS_WIDTH-1:0  ] lsu_wbu_rs1 ;
////wire                  lsu_wbu_jal ;
////wire                  lsu_wbu_jalr;
//`endif
wire									lsu_wbu_valid;
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

//wire							    wbu_valid;
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

ysyx_25010009_ifu #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.PC_INIT	 (PC_INIT		)
) IFU (
	.clk(clock),
	.rst(reset),
	.reqvalid(io_ifu_reqValid ),
	.resvalid(io_ifu_respValid),
	.finst(io_ifu_rdata),
	.addr	(io_ifu_addr ),
	.valid(ifu_idu_valid),
	.inst (ifu_idu_inst),
	.pc		(ifu_idu_pc	 ),
	.snpc (ifu_idu_snpc),
	.dnpc (ifu_idu_dnpc),
	.is_RAW_control(1'b0),
	.exu_dnpc(exu_dnpc ),
	.speec	 (speec		 )
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
	.clk		  (clock					),
	.rst      (reset     			),
	.ifu_valid(ifu_idu_valid),
	.inst     (ifu_idu_inst ),
	.pc			  (ifu_idu_pc		),
	.snpc	    (ifu_idu_snpc	),
	.dnpc	    (ifu_idu_dnpc	),
//`ifdef VERILATOR
//	.exu_ebreak(idu_exu_ebreak),
//	.exu_a0		 (idu_exu_a0		),
////	.exu_inst  (idu_exu_inst	),
//`endif
	.idu_valid(idu_exu_valid ),
	.exu_snpc (idu_exu_snpc	 ),
	.exu_dnpc (idu_exu_dnpc	 ),
	.exu_pc	  (idu_exu_pc		 ),
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
  .rf_a0	 (idu_rf_a0			 ),
	.mepc	 	 (idu_rf_mepc		 ),
	.mtvec	 (idu_rf_mtvec	 )
);

ysyx_25010009_exu #(
	.DATA_WIDTH (DATA_WIDTH ), 
	.RS_WIDTH   (RS_WIDTH   ), 
	.OPSEL_WIDTH(OPSEL_WIDTH)
) EXU (
	.clk					(clock					),
	.rst					(reset					),
//`ifdef VERILATOR
//	.ebreak				(idu_exu_ebreak			  ),
//	.a0						(idu_exu_a0						),
////	.inst					(idu_exu_inst				  ),
////	.rs1					(idu_rf_rs1					  ),
//`endif
	.idu_valid		(idu_exu_valid				),
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
//`ifdef VERILATOR
//	.lsu_ebreak	  (exu_lsu_ebreak				),
//	.lsu_a0				(exu_lsu_a0						),
////	.lsu_inst			(exu_lsu_inst					),
////	.lsu_snpc			(exu_lsu_snpc					),
////	.lsu_rs1			(exu_lsu_rs1					),
////	.lsu_jal			(exu_lsu_jal				  ),
////	.lsu_jalr			(exu_lsu_jalr				  ),
////	.lsu_dnpc			(exu_lsu_dnpc				  ),
//`endif
	.exu_valid		(exu_lsu_valid				),
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
	.clk		 (clock						 ),
	.rst		 (reset		    		 ),
//`ifdef VERILATOR
//	.ebreak	  (exu_lsu_ebreak),
//	.a0				(exu_lsu_a0		 ),
////	.inst			(exu_lsu_inst	 ),
////	.snpc			(exu_lsu_snpc	 ),
////	.dnpc			(exu_lsu_dnpc	 ),
////	.rs1			(exu_lsu_rs1	 ),
////	.jal			(exu_lsu_jal	 ),
////	.jalr			(exu_lsu_jalr	 ),
//`endif
  .exu_valid(exu_lsu_valid ),
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
	.lsu_reqvalid(io_lsu_reqValid ),
	.lsu_resvalid(io_lsu_respValid),
	.lsu_size	 (io_lsu_size	),
	.lsu_addr	 (io_lsu_addr ),
	.lsu_rdata (io_lsu_rdata),
	.lsu_wdata (io_lsu_wdata),
	.lsu_wmask (io_lsu_wmask),
	.lsu_wen	 (io_lsu_wen  ),
//`ifdef VERILATOR
//	.wbu_ebreak (lsu_wbu_ebreak ),
//	.wbu_a0			(lsu_wbu_a0			),
////	.wbu_inst		(lsu_wbu_inst		),
////	.wbu_snpc		(lsu_wbu_snpc		),
////	.wbu_dnpc		(lsu_wbu_dnpc		),
////	.wbu_rs1		(lsu_wbu_rs1    ),
////	.wbu_jal		(lsu_wbu_jal		),
////	.wbu_jalr		(lsu_wbu_jalr		),
//`endif
  .lsu_valid   (lsu_wbu_valid  ),
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
	.clk		 (clock						 ),
	.rst		 (reset		    		 ),
	.lsu_valid(lsu_wbu_valid ),
	.pc		   (lsu_wbu_pc		 ),
//`ifdef VERILATOR
//	.ebreak  (lsu_wbu_ebreak ),
//	.a0			 (lsu_wbu_a0		 ),
////	.inst		 (lsu_wbu_inst	 ),
////	.snpc		 (lsu_wbu_snpc   ),
////	.dnpc		 (lsu_wbu_dnpc   ),
////	.rs1		 (lsu_wbu_rs1		 ),
////	.jal		 (lsu_wbu_jal		 ),
////	.jalr		 (lsu_wbu_jalr	 ),
//`endif
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
	.clk		 (clock						 ),
	.rst		 (reset		    		 ),
	.gpr_wdata	 (wbu_rf_wdata	 ),
	.gpr_waddr	 (wbu_rf_rd			 ),
	.gpr_raddr1	 (idu_rf_rs1		 ),
	.gpr_raddr2	 (idu_rf_rs2		 ),
	.gpr_rdata1	 (idu_rf_src1		 ),
	.gpr_rdata2	 (idu_rf_src2		 ),
	.gpr_a0			 (idu_rf_a0			 ),
	.gpr_wen		 (wbu_rf_wen		 ),
	.csrs_wdata1 (wbu_rf_csrs1),
	.csrs_waddr1 (wbu_rf_csr1 ),
	.csrs_wdata2 (wbu_rf_csrs2),
	.csrs_waddr2 (wbu_rf_csr2 ),
	.csrs_rdata	 (idu_rf_csrs),
	.csrs_raddr	 (idu_rf_csr ),
	.csrs_wen1	 (wbu_rf_cwen1),
	.csrs_wen2	 (wbu_rf_cwen1),
	.rf_mepc	   (idu_rf_mepc ),
	.rf_mtvec		 (idu_rf_mtvec)
);

////`ifdef VERILATOR
////import "DPI-C" function void speec_once(int speec);
////always @(*) 
////	speec_once({31'b0, speec});
////`endif

endmodule

module ysyx_25010009_ALU #(
	parameter DATA_WIDTH  = 32, 
	parameter OPSEL_WIDTH = 4
)(
	input  [OPSEL_WIDTH-1:0] sel,
	input  [DATA_WIDTH -1:0] ina,
	input  [DATA_WIDTH -1:0] inb,
	output [DATA_WIDTH -1:0] out
);

wire [DATA_WIDTH-1:0] and_;
wire [DATA_WIDTH-1:0] or_ ;
wire [DATA_WIDTH-1:0] xor_;
wire [DATA_WIDTH-1:0] eq  ;
wire [DATA_WIDTH-1:0] ne  ;
wire [DATA_WIDTH-1:0] lt  ;
wire [DATA_WIDTH-1:0] ge  ;
wire [DATA_WIDTH-1:0] ltu ;
wire [DATA_WIDTH-1:0] geu ;
wire [DATA_WIDTH-1:0] cla_out  ;
wire [DATA_WIDTH-1:0] shift_out;

//shift
wire [1:0] shift_sel;
assign shift_sel = (sel == 4'b0110) ? 2'b01 :
									 (sel == 4'b0111) ? 2'b10 :
								   (sel == 4'b1000) ? 2'b11 :
									 2'b00;	 
ysyx_25010009_SHIFT shift_0(
	.a    (ina      ),
	.shamt(inb[4:0] ),
	.sel  (shift_sel),
	.out	(shift_out)
);

//cla
wire [DATA_WIDTH-1:0] cla_a, cla_b;
wire                  cla_cout;
wire									overflow;
wire							    is_sub;
wire								  cin;
assign cla_a  = ina; 
assign cla_b  = {DATA_WIDTH{is_sub}} ^ inb; 
assign is_sub = (sel == 4'b0010) || (sel == 4'b1011) || (sel == 4'b1100) ; 
assign cin    = is_sub;
assign overflow = (ina[DATA_WIDTH-1] == cla_b[DATA_WIDTH-1]) && (cla_out[DATA_WIDTH-1] != ina[DATA_WIDTH-1]);
ysyx_25010009_CLA cla_0(
	.a   (cla_a   ),
	.b   (cla_b   ),
	.cin (cin     ),
	.sum (cla_out ),
	.cout(cla_cout)
);

assign and_ = ina & inb;
assign or_  = ina | inb;
assign xor_ = ina ^ inb;
assign eq   = {{(DATA_WIDTH-1){1'b0}}, ina == inb}; 
assign ne   = {{(DATA_WIDTH-1){1'b0}}, ina != inb};
assign lt   =	overflow ? {{(DATA_WIDTH-1){1'b0}},  ina[DATA_WIDTH-1]} : {{(DATA_WIDTH-1){1'b0}},  cla_out[DATA_WIDTH-1]}; 
assign ge   = overflow ? {{(DATA_WIDTH-1){1'b0}}, !ina[DATA_WIDTH-1]} : {{(DATA_WIDTH-1){1'b0}}, !cla_out[DATA_WIDTH-1]}; 
assign ltu  = {{(DATA_WIDTH-1){1'b0}}, ina <  inb}; 
assign geu  = {{(DATA_WIDTH-1){1'b0}}, ina >= inb}; 

reg [DATA_WIDTH-1:0] result;
always @(*) begin
	case(sel)
		4'b0001, 4'b0010: result = cla_out;
		4'b0011         : result = and_		;	
		4'b0100         : result = or_		;	
		4'b0101         : result = xor_   ;	
		4'b0110, 4'b0111, 4'b1000: result = shift_out;	
		4'b1001         : result = eq     ;	
		4'b1010         : result = ne     ;	
		4'b1011         : result = lt     ;	
		4'b1100         : result = ge     ;	
		4'b1101         : result = ltu    ;	
		4'b1110         : result = geu    ;	
		default: result = {DATA_WIDTH{1'b0}};
	endcase
end
assign out = result;

endmodule

module ysyx_25010009_CLA (
	input  [31:0] a		,
	input	 [31:0] b	 	,
	input				  cin	,
	output [31:0] sum	,
	output			  cout
);

wire [31:0] g, p;
assign g = a & b;
assign p = a ^ b;

wire [32:0] c;
assign c[0] = cin;

localparam STAGE_NUM = clog2(32); 
wire [31:0] G [0:STAGE_NUM];
wire [31:0] P [0:STAGE_NUM];

assign G[0] = g;
assign P[0] = p;

ysyx_25010009_Pretree #(1) p1(G[0], P[0], G[1], P[1]);
ysyx_25010009_Pretree #(2) p2(G[1], P[1], G[2], P[2]);
ysyx_25010009_Pretree #(3) p3(G[2], P[2], G[3], P[3]);
ysyx_25010009_Pretree #(4) p4(G[3], P[3], G[4], P[4]);
ysyx_25010009_Pretree #(5) p5(G[4], P[4], G[5], P[5]);

genvar i;
generate
	for(i = 0; i < 32; i = i + 1) begin : carry
		assign c[i+1] = G[STAGE_NUM][i] | (P[STAGE_NUM][i] & cin);
	end
endgenerate

assign sum = p ^ c[31:0];
assign cout = c[32];

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

module ysyx_25010009_ebreak(
	input clk      ,
	input ebreak   ,
	input [31:0] a0
);

//`ifdef VERILATOR
////import "DPI-C" function void is_ebreak(int unsigned ebreak, int unsigned pc, int unsigned snpc, int unsigned dnpc, int unsigned inst, int unsigned rd, int unsigned rs1, int unsigned jal, int unsigned jalr);
//import "DPI-C" function void is_ebreak(int unsigned ebreak, int unsigned a0);
//
//always @(posedge clk)
//	is_ebreak({31'b0, ebreak}, a0);
//`endif

endmodule

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
//`ifdef VERILATOR
//	input										 ebreak	,
//	input  [DATA_WIDTH -1:0] a0			,
////	input  [DATA_WIDTH -1:0] inst		,
////	input  [RS_WIDTH   -1:0] rs1		,
//`endif
	input										 idu_valid,
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
//`ifdef VERILATOR
//	output 									 lsu_ebreak,
//	output [DATA_WIDTH -1:0] lsu_a0		 ,
////	output [DATA_WIDTH -1:0] lsu_inst	 ,
////	output [ADDR_WIDTH -1:0] lsu_snpc	 ,
////	output [RS_WIDTH   -1:0] lsu_rs1	 ,
////	output									 lsu_jal   ,
////	output									 lsu_jalr  ,
////	output [ADDR_WIDTH -1:0] lsu_dnpc ,
//`endif
	output									 exu_valid ,
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
assign csr_res1= is_ecall ? pc + 4				 : 
								 is_csrrc ? csrs & (~src1) : 
								 is_csrrs ? csrs |   src1  : 
								 is_csrrw ?          src1  : 0;
assign csr_res2= is_ecall ? 32'hb	 : 0;

assign exu_valid  = idu_valid;
assign lsu_pc			= pc		;
assign lsu_mwdata = mwdata;
assign lsu_memwr	= memwr ;
assign lsu_memre  = memre ;
assign lsu_regwr  = regwr ;
assign lsu_csr1wr = csr1wr;
assign lsu_csr2wr = csr2wr;
assign lsu_mask   = mem_mask;
assign lsu_sext   = mem_sext;

//`ifdef VERILATOR
//assign lsu_ebreak = ebreak;
//assign lsu_a0			= a0		;
////assign lsu_inst		= inst	;
////assign lsu_snpc   = pc + 4;
////assign lsu_dnpc   = exu_dnpc;
////assign lsu_rs1		= rs1		;
////assign lsu_jal		= is_jal ;
////assign lsu_jalr		= is_jalr;
//`endif

endmodule

module ysyx_25010009_idu #(
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32,
	parameter RS_WIDTH     = 5 , 
	parameter CAR_WIDTH    = 12, 
	parameter FUNCT3_WIDTH = 3 ,
	parameter FUNCT7_WIDTH = 7 ,
	parameter OPCODE_WIDTH = 7 , 
	parameter OPSEL_WIDTH  = 4 ,
	parameter OPMUX_WIDTH  = 4 ,
	parameter	INST_BITS    = 6 ,
	parameter PCMUX_WIDTH  = 2 ,
	parameter MSTATUS = 12'h0300,
	parameter MTVEC	= 12'h0305,
	parameter MEPC = 12'h0341,
	parameter MCAUSE = 12'h0342
) (
	input clk,
	input rst,
	//ifu
	input										 ifu_valid,
	input  [DATA_WIDTH -1:0] inst   ,
	input  [ADDR_WIDTH -1:0] pc			,
	input  [ADDR_WIDTH -1:0] snpc	  ,
	input  [ADDR_WIDTH -1:0] dnpc	  ,
	//exu
	output									 idu_valid ,
//`ifdef VERILATOR
//	output                   exu_ebreak,
//  output [DATA_WIDTH -1:0] exu_a0		 ,
////  output [DATA_WIDTH -1:0] exu_inst	 ,
//`endif
	output [ADDR_WIDTH -1:0] exu_snpc  ,
	output [ADDR_WIDTH -1:0] exu_dnpc	 ,
	output [ADDR_WIDTH -1:0] exu_pc	 	 ,
  output [DATA_WIDTH -1:0] exu_imm 	 ,
  output [DATA_WIDTH -1:0] exu_shamt ,
	output [DATA_WIDTH -1:0] src1			 ,
	output [DATA_WIDTH -1:0] src2			 ,
	output [RS_WIDTH   -1:0] rd      	 ,
	output [OPMUX_WIDTH-1:0] opmux	 	 ,
	output [OPSEL_WIDTH-1:0] opsel	 	 ,
	output [DATA_WIDTH -1:0] mwdata  	 ,
	output									 memwr   	 ,
	output									 memre   	 ,
	output [            3:0] mem_mask  ,
	output                   mem_sext  ,
	output									 regwr   	 ,	
	output									 csr1wr    ,	
	output									 csr2wr    ,	
	output [CAR_WIDTH  -1:0] csr1rd		 ,
	output [CAR_WIDTH  -1:0] csr2rd		 ,
	output									 is_jalr 	 ,
	output									 is_jal  	 ,
	output									 is_bxx  	 ,
	output									 is_ecall	 ,
	output									 is_mret	 ,
	output									 is_csrrs  ,
	output									 is_csrrc  ,
	output									 is_csrrw  ,
	output [DATA_WIDTH -1:0] exu_csrs	 ,
	output [DATA_WIDTH -1:0] exu_mepc	 ,
	output [DATA_WIDTH -1:0] exu_mtvec ,
	//regfile
	output [RS_WIDTH   -1:0] rs1		,
	output [RS_WIDTH   -1:0] rs2		,
	input  [DATA_WIDTH -1:0] rf_src1,
  input  [DATA_WIDTH -1:0] rf_src2,
  input  [DATA_WIDTH -1:0] rf_a0	,
	output [CAR_WIDTH  -1:0] csr		,
	input  [DATA_WIDTH -1:0] csrs		,
	input  [DATA_WIDTH -1:0] mepc		,
	input  [DATA_WIDTH -1:0] mtvec
);

localparam OPCODE_ST = 0;
localparam OPCODE_EN = 6;
localparam RD_ST     = 7;
localparam RD_EN     = 10;
localparam FUNCT3_ST = 12;
localparam FUNCT3_EN = 14;
localparam RS1_ST    = 15;
localparam RS1_EN    = 18;
localparam RS2_ST    = 20;
localparam RS2_EN    = 23;
localparam FUNCT7_ST = 25;
localparam FUNCT7_EN = 31;
localparam TYPE_WIDTH = 3 ;
                                                                                      
wire [FUNCT3_WIDTH-1:0] funct3;
wire [FUNCT7_WIDTH-1:0] funct7;
wire [OPCODE_WIDTH-1:0] opcode;
assign funct3 = inst[FUNCT3_EN:FUNCT3_ST];
assign funct7 = inst[FUNCT7_EN:FUNCT7_ST];
assign opcode = inst[OPCODE_EN:OPCODE_ST];

//decode
wire lui   =  (opcode == 7'b0110111)                        ;//
wire auipc =  (opcode == 7'b0010111)                        ;//
wire jal	 =  (opcode == 7'b1101111)                        ;//
wire jalr	 = ((opcode == 7'b1100111) && (funct3 == 3'b000)) ;//
wire beq	 = ((opcode == 7'b1100011) && (funct3 == 3'b000)) ;//
wire bne	 = ((opcode == 7'b1100011) && (funct3 == 3'b001)) ;//
wire blt	 = ((opcode == 7'b1100011) && (funct3 == 3'b100)) ;//
wire bge	 = ((opcode == 7'b1100011) && (funct3 == 3'b101)) ;//
wire bltu	 = ((opcode == 7'b1100011) && (funct3 == 3'b110)) ;//
wire bgeu	 = ((opcode == 7'b1100011) && (funct3 == 3'b111)) ;//
wire lb		 = ((opcode == 7'b0000011) && (funct3 == 3'b000)) ;//
wire lh		 = ((opcode == 7'b0000011) && (funct3 == 3'b001)) ;//
wire lw		 = ((opcode == 7'b0000011) && (funct3 == 3'b010)) ;//
wire lbu	 = ((opcode == 7'b0000011) && (funct3 == 3'b100)) ;//
wire lhu	 = ((opcode == 7'b0000011) && (funct3 == 3'b101)) ;//
wire sb		 = ((opcode == 7'b0100011) && (funct3 == 3'b000)) ;//
wire sh		 = ((opcode == 7'b0100011) && (funct3 == 3'b001)) ;//
wire sw		 = ((opcode == 7'b0100011) && (funct3 == 3'b010)) ;//
wire addi	 = ((opcode == 7'b0010011) && (funct3 == 3'b000)) ;
wire slti	 = ((opcode == 7'b0010011) && (funct3 == 3'b010)) ;//
wire sltiu = ((opcode == 7'b0010011) && (funct3 == 3'b011)) ;//
wire xori	 = ((opcode == 7'b0010011) && (funct3 == 3'b100)) ;//
wire ori	 = ((opcode == 7'b0010011) && (funct3 == 3'b110)) ;//
wire andi	 = ((opcode == 7'b0010011) && (funct3 == 3'b111)) ;//
wire slli  = ((opcode == 7'b0010011) && (funct3 == 3'b001) && (funct7 == 7'b0000000));//
wire srli  = ((opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0000000));//
wire srai	 = ((opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0100000));//
wire add	 = ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000));//
wire sub	 = ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000));//
wire sll	 = ((opcode == 7'b0110011) && (funct3 == 3'b001) && (funct7 == 7'b0000000));//
wire slt	 = ((opcode == 7'b0110011) && (funct3 == 3'b010) && (funct7 == 7'b0000000));//
wire sltu	 = ((opcode == 7'b0110011) && (funct3 == 3'b011) && (funct7 == 7'b0000000));//
wire xor_	 = ((opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0000000));//
wire srl	 = ((opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000000));//
wire sra	 = ((opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0100000));//
wire or_	 = ((opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0000000));//
wire and_	 = ((opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0000000));//
wire csrrc = ((opcode == 7'b1110011) && (funct3 == 3'b011));
wire csrrs = ((opcode == 7'b1110011) && (funct3 == 3'b010));
wire csrrw = ((opcode == 7'b1110011) && (funct3 == 3'b001));
wire ecall = inst == 32'h00000073;
wire mret  = inst == 32'h30200073;
//`ifdef VERILATOR
//assign exu_ebreak = inst == 32'h00100073;
//assign exu_a0			= rf_a0;
////assign exu_inst = inst;
//`endif

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
							 slli  || srli  || srai || addi || xori || ori || andi || slti  ||
							 sltiu || jalr  || lb   || lh   || lw		|| lbu || lhu	 || ecall || 
							 mret  || csrrc || csrrs || csrrw																	 ? TYPE_I : 
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
assign opmux = sll || srl  || sra || add || sub || xor_ || or_  || and_ ||
							 slt || sltu ||	beq || bne || blt || bge  || bltu || bgeu		 ? 4'b0001 : //rs1_rs2
							 addi || xori || ori || andi || slti || sltiu || lb || lh ||
							 lw		|| lbu  || lhu || sb   || sh	 || sw									 ? 4'b0010 : //rs1_imm
							 auipc                                                       ? 4'b0011 : //pc_imm
							 slli || srli || srai																				 ? 4'b0100 : //rs1_shamt
							 lui																												 ? 4'b0101 : //imm_0
							 jal  || jalr																								 ? 4'b0110 : //pc_4
							 csrrc || csrrw || csrrs																		 ? 4'b0111 : //csrs_0
							 4'b0000; //rs1_rs2
assign opsel = add || addi || lui   || auipc ||
							 lb  || lh	 || lw	  || lbu	 ||
							 lhu || sb	 || sh	  || sw		 ||	
							 jal || jalr || csrrc || csrrs || 
							 csrrw													  ? 4'b0001 : //+
							 sub												      ? 4'b0010 : //-
							 and_ || andi								      ? 4'b0011 : //&
							 or_	|| ori								      ? 4'b0100 : //|
							 xor_	|| xori								      ? 4'b0101 : //^
							 sll || slli								      ? 4'b0110 : //<<
							 srl || srli								      ? 4'b0111 : //>>u
							 sra || srai                      ? 4'b1000 : //>>s
							 beq												      ? 4'b1001 : //==
							 bne												      ? 4'b1010 : //!=
							 slt || slti || blt					      ? 4'b1011 : //<
							 bge												      ? 4'b1100 : //>=
							 sltu || sltiu || bltu			      ? 4'b1101 : //<u
							 bgeu												      ? 4'b1110 : //>=u
							 4'b0000;//+
						 
assign src1 = rf_src1;
assign src2 = rf_src2;

//other output signal
assign rs1 = inst[RS1_EN:RS1_ST];
assign rs2 = inst[RS2_EN:RS2_ST];
assign rd  = inst[RD_EN : RD_ST];
assign is_jalr  = jalr;
assign is_jal   = jal;
assign is_bxx   = beq || bne || blt || bge || bltu || bgeu;
assign mwdata = rf_src2;
assign memwr = (sb || sh || sw);
assign memre = lb || lh || lw || lbu || lhu;
assign mem_mask = sb || lb || lbu ? 4'b0001 :
									sh || lh || lhu ? 4'b0011 :
									sw || lw				? 4'b1111 : 4'b0000;
assign mem_sext = sb || lb || sh || lh || sw || lw;
assign regwr = (sll  || slli || srl || srli || sra  || srai || add || addi || sub  || lui   || auipc ||
												 xor_ || xori	|| or_ || ori  || and_ || andi || slt || slti || sltu || sltiu || lb		||
							 					 lh		|| lw		|| lbu || lhu	 || jal  || jalr || csrrw || csrrc || csrrs);
assign csr1wr = (ecall || csrrw || csrrc || csrrs);
assign csr2wr = ecall;
assign csr1rd = ecall ? MEPC : imm[11:0];
assign csr2rd = ecall ? MCAUSE : 0;
assign csr = csr1rd;

assign is_csrrs = csrrs;
assign is_csrrc = csrrc;
assign is_csrrw = csrrw;
assign is_ecall = ecall;
assign is_mret  = mret;

assign exu_csrs = csrs;
assign exu_mepc = mepc;
assign exu_mtvec= mtvec;
assign exu_pc   = pc;
assign exu_snpc = snpc;
assign exu_dnpc = dnpc;
assign exu_imm  = imm ;
assign exu_shamt= shamt;
assign idu_valid = ifu_valid;

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

module ysyx_25010009_ifu #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 32,
	parameter PC_INIT    = 32'h8000_0000
)(
	input clk,
	input rst,
	//irom
	input  resvalid,
	output reqvalid,
	input  [DATA_WIDTH-1:0] finst,
	output [ADDR_WIDTH-1:0] addr,
	//idu
	output valid,
	output     [DATA_WIDTH-1:0] inst,
	output reg [ADDR_WIDTH-1:0] pc  ,
	output		 [ADDR_WIDTH-1:0] snpc,
	output     [ADDR_WIDTH-1:0] dnpc,
	//exu
  /*verilator lint_off UNUSED*/
	input									 is_RAW_control,
	input [ADDR_WIDTH-1:0] exu_dnpc,
	input									 speec
	//input									 wub_valid
);

wire [DATA_WIDTH-1:0] ifu_inst;
wire [ADDR_WIDTH-1:0] ifu_addr;

parameter IDLE = 2'b00;
parameter WAIT_ROM = 2'b01;
parameter WAIT_SPEEC = 2'b11;

reg [1:0] current_state, next_state;

always @(*) begin
	case(current_state)
		IDLE : begin
			next_state = WAIT_ROM; 
		end
		WAIT_ROM : begin
			if(resvalid && speec)				next_state = IDLE;
			else if(resvalid && !speec) next_state = WAIT_SPEEC;
			else				 next_state = WAIT_ROM;
		end
		WAIT_SPEEC : begin
			if(speec) next_state = IDLE;
			else			next_state = WAIT_SPEEC;
		end
		default :
			next_state = IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= IDLE;
	end else begin
		current_state <= next_state;
	end
end

assign reqvalid = current_state == IDLE && !rst;
assign ifu_addr = pc;
assign ifu_inst = finst; 

always @(posedge clk or posedge rst) begin
	if(rst) begin
		pc <= PC_INIT;
	end else begin
		//if(wbu_valid) pc <= exu_dnpc;
		if(speec) pc <= exu_dnpc;
	end
end

assign valid = resvalid;
assign addr = ifu_addr;

assign inst = ifu_inst;
assign snpc = pc + 4;
assign dnpc = pc + 4;

endmodule

module ysyx_25010009_lsu #(
	parameter DATA_WIDTH  = 32, 
	parameter ADDR_WIDTH  = 32, 
	parameter RS_WIDTH    = 5 ,
	parameter CAR_WIDTH   = 12
)(
	input clk,
	input rst,
	//exu <> lsu
//`ifdef VERILATOR
//	input 									ebreak ,
//	input [DATA_WIDTH -1:0] a0		 ,
////	input [DATA_WIDTH -1:0] inst	 ,
////	input [ADDR_WIDTH -1:0] snpc	 ,
////	input [ADDR_WIDTH -1:0] dnpc	 ,
////	input [RS_WIDTH   -1:0] rs1		 ,
////	input										jal		 ,
////	input										jalr	 ,
//`endif
  input										exu_valid,
	input [ADDR_WIDTH -1:0] pc		 ,
	input [DATA_WIDTH -1:0] mwdata ,
	input										memwr  ,
	input	 								 	memre  ,
	input	 								 	regwr  ,	
	input	 								 	csr1wr ,	
	input	 								 	csr2wr ,	
	input	[						 3:0] mem_mask,	
	input	                  mem_sext,	
	input [DATA_WIDTH -1:0] paddr  ,
	input [RS_WIDTH   -1:0] gpr_rd ,
	input [DATA_WIDTH -1:0] gpr_res,
	input [CAR_WIDTH  -1:0] csr_rd1	,
	input [CAR_WIDTH  -1:0] csr_rd2	,
	input [DATA_WIDTH -1:0] csr_res1,
	input [DATA_WIDTH -1:0] csr_res2,   
	// lsu <> ram
	//output									 awvalid,
	//output									 arvalid,
	output lsu_reqvalid,
	input  lsu_resvalid,
	output [1:0] lsu_size,
	output [ADDR_WIDTH -1:0] lsu_addr ,
	input  [DATA_WIDTH -1:0] lsu_rdata,
	output [DATA_WIDTH -1:0] lsu_wdata,
	output [            3:0] lsu_wmask,
	output									 lsu_wen	,
	output									 lsu_valid ,
	// lsu <> wbu
//`ifdef VERILATOR
//	output 									 wbu_ebreak,
//	output [DATA_WIDTH -1:0] wbu_a0		 ,
////	output [DATA_WIDTH -1:0] wbu_inst	 ,
////	output [ADDR_WIDTH -1:0] wbu_snpc	 ,
////	output [ADDR_WIDTH -1:0] wbu_dnpc	 ,
////	output [RS_WIDTH   -1:0] wbu_rs1	 ,
////	output									 wbu_jal	 ,
////	output									 wbu_jalr	 ,
//`endif
	output [ADDR_WIDTH -1:0] wbu_pc		 ,
	output	 								 wbu_regwr ,	
	output	 								 wbu_csr1wr,	
	output	 								 wbu_csr2wr,	
	output [RS_WIDTH   -1:0] wbu_gpr_rd	,
	output [DATA_WIDTH -1:0] wbu_gpr_res,
	output [CAR_WIDTH  -1:0] wbu_csr_rd1 ,
	output [CAR_WIDTH  -1:0] wbu_csr_rd2 ,
	output [DATA_WIDTH -1:0] wbu_csr_res1,
	output [DATA_WIDTH -1:0] wbu_csr_res2 
);

localparam UART_ST = 32'h1000_0000;
localparam UART_EN = 32'h1000_0fff;
localparam SPI_ST = 32'h1000_1000;
localparam SPI_EN = 32'h1000_1fff;
localparam FLASH_ST = 32'h3000_0000;
localparam FLASH_EN = 32'h3fff_ffff;
localparam SDRAM_ST = 32'h8000_0000;
localparam SDRAM_EN = 32'h81ff_ffff;

//wire aligned = (paddr >= FLASH_ST && paddr <= FLASH_EN) || 
//							 (paddr >= SDRAM_ST && paddr <= SDRAM_EN)   ;
//wire unaligned = (paddr >= UART_ST && paddr <= UART_EN) || 
//								 (paddr >= SPI_ST  && paddr <= SPI_EN )   ;

parameter IDLE = 1'b0;
parameter WAIT = 1'b1;

reg current_state, next_state;

always @(*) begin
	case(current_state)
		IDLE : begin
			if(lsu_reqvalid) next_state = WAIT;
			else						 next_state = IDLE;
		end
		WAIT : begin
			if(lsu_resvalid) next_state = IDLE;
			else						 next_state = WAIT;
		end
		default : next_state = IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= IDLE;
	end else begin
		current_state <= next_state;
	end
end

wire [DATA_WIDTH-1:0] ur_result;
wire [DATA_WIDTH-1:0] sr_result;
wire [DATA_WIDTH-1:0] re_result;
wire [7:0] byte_rdata;
wire [15:0] half_rdata;

assign byte_rdata =
										paddr[1:0] == 2'b00 ? lsu_rdata[7 : 0] :
										paddr[1:0] == 2'b01 ? lsu_rdata[15: 8] :
										paddr[1:0] == 2'b10 ? lsu_rdata[23:16] : lsu_rdata[31:24];
assign half_rdata = 
										paddr[1:0] == 2'b00 ? lsu_rdata[15: 0] :
										paddr[1:0] == 2'b01 ? lsu_rdata[23: 8] :
										paddr[1:0] == 2'b10 ? lsu_rdata[31:16] : 0;
assign ur_result = mem_mask == 4'b0001 ? {24'b0, byte_rdata} :
									 mem_mask == 4'b0011 ? {16'b0, half_rdata} :
									 mem_mask == 4'b1111 ?         lsu_rdata   : 32'b0;
assign sr_result = mem_mask == 4'b0001 ? {{24{byte_rdata[7 ]}}, byte_rdata} :
									 mem_mask == 4'b0011 ? {{16{half_rdata[15]}}, half_rdata[15:0]} :
									 mem_mask == 4'b1111 ? lsu_rdata : 32'b0;
assign re_result = mem_sext ? sr_result : ur_result;

wire [31:0] byte_wdata;
wire [31:0] half_wdata;

assign byte_wdata = paddr[1:0] == 2'b00 ? {24'b0, mwdata[7 : 0]		  	} :
										paddr[1:0] == 2'b01 ? {16'b0, mwdata[7 : 0],  8'b0} :
										paddr[1:0] == 2'b10 ? { 8'b0, mwdata[7 : 0], 16'b0} : {mwdata[7 : 0], 24'b0}; 
assign half_wdata = paddr[1:0] == 2'b00 ? {16'b0, mwdata[15: 0]		  	} :
										paddr[1:0] == 2'b01 ? { 8'b0, mwdata[15: 0],  8'b0} :
										paddr[1:0] == 2'b10 ? {       mwdata[15: 0], 16'b0} : 0; 

wire [3:0] byte_mask;
wire [3:0] half_mask;
assign byte_mask = 
									 paddr[1:0] == 2'b00 ? 4'b0001 :
									 paddr[1:0] == 2'b01 ? 4'b0010 :
									 paddr[1:0] == 2'b10 ? 4'b0100 : 4'b1000; 
assign half_mask = 
									 paddr[1:0] == 2'b00 ? 4'b0011 :
									 paddr[1:0] == 2'b10 ? 4'b1100 : 0; 

//assign lsu_addr = aligned ? paddr & 32'hfffffffc : paddr;
assign lsu_addr = paddr;
assign lsu_wdata = mem_mask == 4'b0001 ? byte_wdata :
									 mem_mask == 4'b0011 ? half_wdata :
									 mem_mask == 4'b1111 ? mwdata			: 0;	 
//assign lsu_wdata = mwdata;
assign lsu_wmask = mem_mask == 4'b0001 ? byte_mask :
									 mem_mask == 4'b0011 ? half_mask :
									 mem_mask == 4'b1111 ? mem_mask	 : 0;
assign lsu_size  = memre							 ? 2'b10 :
									 mem_mask == 4'b0001 ? 2'b00 :
									 mem_mask == 4'b0011 ? 2'b01 :
									 mem_mask == 4'b1111 ? 2'b10 : 2'b00;
assign lsu_wen = memwr;
assign lsu_reqvalid = exu_valid && (memre || memwr);

//`ifdef VERILATOR
//assign wbu_ebreak = ebreak;
//assign wbu_a0			= a0		;
////assign wbu_inst = inst;
////assign wbu_snpc = snpc;
////assign wbu_dnpc = dnpc;
////assign wbu_rs1  = rs1	;
////assign wbu_jal	= jal ;
////assign wbu_jalr	= jalr;
//`endif
assign lsu_valid = (current_state == WAIT && lsu_resvalid) || (!memre && !memwr && exu_valid);
assign wbu_pc = pc;
assign wbu_regwr = regwr;
assign wbu_csr1wr = csr1wr;
assign wbu_csr2wr = csr2wr;
assign wbu_gpr_rd = gpr_rd;
assign wbu_gpr_res = memre ? re_result : gpr_res;
assign wbu_csr_rd1 = csr_rd1;
assign wbu_csr_rd2 = csr_rd2;
assign wbu_csr_res1 = csr_res1;
assign wbu_csr_res2 = csr_res2;

endmodule

module ysyx_25010009_Pretree #(
	parameter STAGE = 1
)(
	input [31:0] Gin,
	input [31:0] Pin,
	output [31:0] Gout,
	output [31:0] Pout
);

genvar i;
generate
	for(i = 0; i < 32; i = i + 1) begin : _bit
		if(i < (1 << (STAGE - 1))) begin : low
			assign Gout[i] = Gin[i];
			assign Pout[i] = Pin[i];
		end else begin : high
			assign Gout[i] = Gin[i] | (Pin[i] & Gin[i - (1 << (STAGE - 1))]);
			assign Pout[i] = Pin[i] &  Pin[i - (1 << (STAGE - 1))];
		end
	end
endgenerate

endmodule

module ysyx_25010009_RegisterFile #(
	parameter GPR_NUM    = 16			,
	parameter CSRS_NUM   = 4096		,
	parameter ADDR_WIDTH = 4			, 
	parameter CAR_WIDTH  = 12			, 
	parameter DATA_WIDTH = 32			,
	parameter MSTATUS		 = 12'h300,
	parameter MTVEC			 = 12'h305,
	parameter MEPC			 = 12'h341,
	parameter MCAUSE		 = 12'h342,
	parameter MCYCLE		 = 12'hb00,
	parameter MCYCLEH		 = 12'hb01,
	parameter MVENDORID  = 12'hf11,
	parameter MARCHID    = 12'hf12
)(
	input clk,
	input rst,
	input [DATA_WIDTH-1:0] gpr_wdata,
	input [ADDR_WIDTH-1:0] gpr_waddr,
	input [ADDR_WIDTH-1:0] gpr_raddr1,
	input [ADDR_WIDTH-1:0] gpr_raddr2,
	output [DATA_WIDTH-1:0] gpr_rdata1,
	output [DATA_WIDTH-1:0] gpr_rdata2,
	output [DATA_WIDTH-1:0] gpr_a0		,
	input gpr_wen,
	input [DATA_WIDTH-1:0] csrs_wdata1,
	input [CAR_WIDTH -1:0] csrs_waddr1,
	input [DATA_WIDTH-1:0] csrs_wdata2,
	input [CAR_WIDTH -1:0] csrs_waddr2,
	output [DATA_WIDTH-1:0] csrs_rdata,
	input  [CAR_WIDTH -1:0]  csrs_raddr,
	input csrs_wen1,
	input csrs_wen2,
	output [DATA_WIDTH-1:0] rf_mepc,
	output [DATA_WIDTH-1:0] rf_mtvec
);

reg [DATA_WIDTH-1:0] rf [0:GPR_NUM-1];
//reg [DATA_WIDTH-1:0] csrs [0:CSRS_NUM-1];
reg [DATA_WIDTH-1:0] mepc;
reg [DATA_WIDTH-1:0] mtvec;
reg [DATA_WIDTH-1:0] mcause;
reg [DATA_WIDTH-1:0] mstatus;
reg [DATA_WIDTH-1:0] mcycle;
reg [DATA_WIDTH-1:0] mcycleh;
reg [DATA_WIDTH-1:0] mvendorid;
reg [DATA_WIDTH-1:0] marchid;
reg [DATA_WIDTH-1:0] csrs;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		integer i;
		for(i = 0; i < GPR_NUM; i=i+1) begin
			rf[i] <= {DATA_WIDTH{1'b0}};
		end
		mepc <= 0;
		mtvec <= 0;
		mcause <= 0;
		mstatus <= 0;
		mcycle <= 0;
		mcycleh <= 0;
		mvendorid <= 32'h79737978;
		marchid <= 32'h017d9f59;
		//for(i = 0; i < CSRS_NUM; i=i+1) begin
		//	if		 (i == {20'd0, MVENDORID}) csrs[i] = 'h79737978				;
		//	else if(i == {20'd0, MARCHID	}) csrs[i] = 'h17d9f59 				;
		//	else										csrs[i] = {DATA_WIDTH{1'b0}};
		//end
	end else begin
		mcycle <= mcycle + 1;
		mcycleh <= &mcycle ? mcycleh + 1 : mcycleh;
		//csrs[MCYCLE ] <= csrs[MCYCLE] + 1;
		//csrs[MCYCLEH] <= &csrs[MCYCLE] ? csrs[MCYCLEH] + 1 : csrs[MCYCLEH];
		if (gpr_wen) begin
			if (gpr_waddr != 0) rf[gpr_waddr] <= gpr_wdata;
			else						    rf[gpr_waddr] <= 0		;
		end
		if (csrs_wen1) begin
			//csrs[csrs_waddr1] <= csrs_wdata1;
			case(csrs_waddr1)
				MEPC			: mepc			<= csrs_wdata1;
				MTVEC 		: mtvec	 		<= csrs_wdata1;
				MCAUSE		: mcause 		<= csrs_wdata1;
				MSTATUS		: mstatus		<= csrs_wdata1;
				MCYCLE		: mcycle 		<= csrs_wdata1;
				MCYCLEH		: mcycleh		<= csrs_wdata1;
				MVENDORID : mvendorid <= csrs_wdata1;
				MARCHID		: marchid   <= csrs_wdata1;
				default : csrs <= 0;
			endcase
		end
		if (csrs_wen2) begin
			//csrs[csrs_waddr2] <= csrs_wdata2;
			case(csrs_waddr2)
				MEPC			: mepc			<= csrs_wdata2;
				MTVEC 		: mtvec	 		<= csrs_wdata2;
				MCAUSE		: mcause 		<= csrs_wdata2;
				MSTATUS		: mstatus		<= csrs_wdata2;
				MCYCLE		: mcycle 		<= csrs_wdata2;
				MCYCLEH		: mcycleh		<= csrs_wdata2;
				MVENDORID : mvendorid <= csrs_wdata2;
				MARCHID		: marchid   <= csrs_wdata2;
				default : csrs <= 0;
			endcase
		end
	end
end

assign gpr_rdata1 = gpr_raddr1 == 0 ? 0 : rf[gpr_raddr1];
assign gpr_rdata2 = gpr_raddr2 == 0 ? 0 : rf[gpr_raddr2];
assign gpr_a0	= rf[10];
//assign csrs_rdata = csrs[csrs_raddr];
//assign mepc = csrs[MEPC];
//assign mtvec = csrs[MTVEC];
assign csrs_rdata = csrs_raddr == MEPC			? mepc			:
										csrs_raddr == MTVEC   	? mtvec  		:
										csrs_raddr == MCAUSE  	? mcause 		:
										csrs_raddr == MSTATUS 	? mstatus		:
										csrs_raddr == MCYCLE  	? mcycle 		:
										csrs_raddr == MCYCLEH		? mcycleh		:
										csrs_raddr == MVENDORID ? mvendorid :
										csrs_raddr == MARCHID   ? marchid   : 0;
assign rf_mepc = mepc;
assign rf_mtvec = mtvec;

////`ifdef VERILATOR
////export "DPI-C" task read_gpr;
////task automatic read_gpr(input int addr, output int unsigned rdata); 
////begin
////	if(addr == 0) rdata = 0;
////	else          rdata = rf[addr];
////end
////endtask
////export "DPI-C" task read_csr;
////task automatic read_csr(input int addr, output int unsigned rdata); 
////begin
////	rdata = csrs[addr];
////end
////endtask
////`endif

endmodule

module ysyx_25010009_SHIFT (
	input [31:0] a    ,
	input [4 :0] shamt,
	input	[1 :0] sel	,
	output [31:0] out
);

//wire [31:0]  l_shift1,  l_shift2,  l_shift3,  l_shift4,  l_shift5;
//wire [31:0] ru_shift1, ru_shift2, ru_shift3, ru_shift4, ru_shift5;
//wire [31:0] rs_shift1, rs_shift2, rs_shift3, rs_shift4, rs_shift5;
//
//assign l_shift1 = shamt[0] ? {       a[30:0],  1'b0} : a       ;
//assign l_shift2 = shamt[1] ? {l_shift1[29:0],  2'b0} : l_shift1;
//assign l_shift3 = shamt[2] ? {l_shift2[27:0],  4'b0} : l_shift2;
//assign l_shift4 = shamt[3] ? {l_shift3[23:0],  8'b0} : l_shift3;
//assign l_shift5 = shamt[4] ? {l_shift4[15:0], 16'b0} : l_shift4;
//
//assign ru_shift1 = shamt[0] ? { 1'b0,         a[31: 1]} : a       ;
//assign ru_shift2 = shamt[1] ? { 2'b0, ru_shift1[31: 2]} : ru_shift1;
//assign ru_shift3 = shamt[2] ? { 4'b0, ru_shift2[31: 4]} : ru_shift2;
//assign ru_shift4 = shamt[3] ? { 8'b0, ru_shift3[31: 8]} : ru_shift3;
//assign ru_shift5 = shamt[4] ? {16'b0, ru_shift4[31:16]} : ru_shift4;
//
//assign rs_shift1 = shamt[0] ? {{ 1{a[31]}},         a[31: 1]} : a       ;
//assign rs_shift2 = shamt[1] ? {{ 2{a[31]}}, rs_shift1[31: 2]} : rs_shift1;
//assign rs_shift3 = shamt[2] ? {{ 4{a[31]}}, rs_shift2[31: 4]} : rs_shift2;
//assign rs_shift4 = shamt[3] ? {{ 8{a[31]}}, rs_shift3[31: 8]} : rs_shift3;
//assign rs_shift5 = shamt[4] ? {{16{a[31]}}, rs_shift4[31:16]} : rs_shift4;

assign out = (sel == 2'b01) ? a <<  shamt: 
						 (sel == 2'b11) ? a >>  shamt:
						 (sel == 2'b10) ? a >>> shamt:
						 a;

endmodule

module ysyx_25010009_wbu #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 32,
	parameter RS_WIDTH   = 5 ,
	parameter CAR_WIDTH  = 12 
)(
	input clk,
	input rst,
//`ifdef VERILATOR
//	input										 ebreak,
//	input		[DATA_WIDTH  -1:0] a0  ,
////	input [DATA_WIDTH  -1:0] inst  ,
////	input [ADDR_WIDTH  -1:0] snpc	 ,
////	input [ADDR_WIDTH  -1:0] dnpc	 ,
////	input [RS_WIDTH    -1:0] rs1   ,
////	input                    jal	 ,
////	input										 jalr  ,
//`endif
	input										 lsu_valid,
	input  [ADDR_WIDTH -1:0] pc		 ,
	// lsu <> wbu
	//input	 								   wbu_valid,	
	input	 								   regwr ,	
	input	 								   csr1wr,	
	input	 								   csr2wr,	
	input [RS_WIDTH   -1:0] rd		 ,
	input [DATA_WIDTH -1:0] gpr_res,  
	input [CAR_WIDTH  -1:0] csr_rd1	,
	input [CAR_WIDTH  -1:0] csr_rd2	,
	input [DATA_WIDTH -1:0] csr_res1,
	input [DATA_WIDTH -1:0] csr_res2,   
	// wbu <> rf
	output [CAR_WIDTH  -1:0] rf_csr_rd1	,
	output [CAR_WIDTH  -1:0] rf_csr_rd2	,
	output [DATA_WIDTH -1:0] rf_csr_res1,
	output [DATA_WIDTH -1:0] rf_csr_res2,   
	output									 rf_csr_wen1,
	output									 rf_csr_wen2,
	output [RS_WIDTH   -1:0] rf_gpr_rd	,
	output [DATA_WIDTH -1:0] rf_gpr_wdata,
	output									 rf_gpr_wen  ,
	output									 speec
);

assign rf_gpr_wen   = lsu_valid && regwr;
assign rf_gpr_rd    = rd;
assign rf_gpr_wdata = gpr_res;
assign rf_csr_wen1 = lsu_valid && csr1wr;
assign rf_csr_wen2 = lsu_valid && csr2wr;
assign rf_csr_rd1  = csr_rd1;
assign rf_csr_rd2  = csr_rd2;
assign rf_csr_res1 = csr_res1;
assign rf_csr_res2 = csr_res2;

//`ifdef VERILATOR
////ebreak EBREAK(clk, ebreak, pc, snpc, dnpc, inst, rd, rs1, jal, jalr);
//ysyx_25010009_ebreak EBREAK(clk, ebreak, a0);
//
////export "DPI-C" task read_pc;
////task automatic read_pc(output int unsigned rdata); 
////begin
////	rdata = pc;
////end
////endtask
//`endif

//reg reg_speec;
//always @(posedge clk or posedge rst) begin
//	if(rst) begin
//		reg_speec <= 0;
//	end else begin
//		reg_speec <= lsu_valid;
//	end
//end
//assign speec = reg_speec;
assign speec = lsu_valid;

//assign wbu_valid = lsu_valid;

endmodule
	
