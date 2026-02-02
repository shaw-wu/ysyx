`timescale 1ns / 1ps
module ysyx_25010009_cpu_top#(
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
	parameter INST_BITS		 = 6 ,
	parameter CNT_WIDTH		 = 32
)(
	input clk,
	input rst,
	output [CNT_WIDTH -1:0] counter    ,
    //AXI-LIte
    output [ADDR_WIDTH-1:0] io_master_awaddr ,
    output [           2:0] io_master_awsize ,
    output                  io_master_awvalid,
    input                   io_master_awready,
    output [DATA_WIDTH-1:0] io_master_wdata  ,
    output [           3:0] io_master_wstrb  ,
    output                  io_master_wvalid ,
    input                   io_master_wready ,
    input  [           2:0] io_master_bresp  ,
    input                   io_master_bvalid ,
    output                  io_master_bready ,
    output [ADDR_WIDTH-1:0] io_master_araddr ,
    output [           2:0] io_master_arsize ,
    output                  io_master_arvalid,
    input                   io_master_arready,
    input  [DATA_WIDTH-1:0] io_master_rdata  ,
    input  [           2:0] io_master_rresp  ,
    input                   io_master_rvalid ,
    output                  io_master_rready 
);

localparam MSTATUS = 12'h0300;
localparam MTVEC   = 12'h0305;
localparam MEPC    = 12'h0341;
localparam MCAUSE  = 12'h0342;

`ifdef CONFIG_RVE
	parameter GPR_NUM = 16;
`else
	parameter GPR_NUM = 32;
`endif

parameter CSR_NUM = 4096;

wire [ADDR_WIDTH-1:0] lsu_awaddr ;
wire [           2:0] lsu_awsize ;
wire                  lsu_awvalid;
wire                  lsu_awready;
wire [DATA_WIDTH-1:0] lsu_wdata  ;
wire [           3:0] lsu_wstrb  ;
wire                  lsu_wvalid ;
wire                  lsu_wready ;
wire [           2:0] lsu_bresp  ;
wire                  lsu_bvalid ;
wire                  lsu_bready ;
wire [ADDR_WIDTH-1:0] lsu_araddr ;
wire [           2:0] lsu_arsize ;
wire                  lsu_arvalid;
wire                  lsu_arready;
wire [DATA_WIDTH-1:0] lsu_rdata  ;
wire [           2:0] lsu_rresp  ;
wire                  lsu_rvalid ;
wire                  lsu_rready ;
wire [ADDR_WIDTH-1:0] ifu_araddr ;
wire [           2:0] ifu_arsize ;
wire                  ifu_arvalid;
wire                  ifu_arready;
wire [DATA_WIDTH-1:0] ifu_rdata  ;
wire [           2:0] ifu_rresp  ;
wire                  ifu_rvalid ;
wire                  ifu_rready ;

wire                  ifu_rreq       ;
wire                  ifu_rdata_ready;
wire                  ifu_rdata_valid;
wire [DATA_WIDTH-1:0] ifu_data       ;
wire [ADDR_WIDTH-1:0] ifu_addr       ;

wire				  ifu_idu_valid;
wire				  ifu_idu_ready;
wire [ADDR_WIDTH-1:0] ifu_idu_inst ;
wire [ADDR_WIDTH-1:0] ifu_idu_pc   ;
wire [ADDR_WIDTH-1:0] ifu_idu_snpc ;
wire [ADDR_WIDTH-1:0] ifu_idu_dnpc ;

wire				   idu_exu_valid ;
wire				   idu_exu_ready ;
`ifdef VERILATOR
wire                   idu_exu_ebreak; 
wire [DATA_WIDTH -1:0] idu_exu_a0	 ; 
wire [DATA_WIDTH -1:0] idu_exu_inst	 ; 
`endif
wire [ADDR_WIDTH -1:0] idu_exu_snpc	 ; 
wire [ADDR_WIDTH -1:0] idu_exu_dnpc	 ; 
wire [ADDR_WIDTH -1:0] idu_exu_pc	 ; 
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

wire									exu_lsu_valid;
wire									exu_lsu_ready;
`ifdef VERILATOR
wire exu_lsu_ebreak;
wire [DATA_WIDTH-1:0] exu_lsu_a0  ;
wire [DATA_WIDTH-1:0] exu_lsu_inst;
wire [ADDR_WIDTH-1:0] exu_lsu_snpc;
wire [RS_WIDTH-1:0  ] exu_lsu_rs1	;
wire                  exu_lsu_jal ;
wire                  exu_lsu_jalr;
`endif
wire [ADDR_WIDTH-1:0] exu_lsu_dnpc;
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

wire									lsu_wbu_valid;
wire									lsu_wbu_ready;
`ifdef VERILATOR
wire lsu_wbu_ebreak;
wire [DATA_WIDTH-1:0] lsu_wbu_inst;
wire [ADDR_WIDTH-1:0] lsu_wbu_snpc;
wire [RS_WIDTH-1:0  ] lsu_wbu_rs1 ;
wire                  lsu_wbu_jal ;
wire                  lsu_wbu_jalr;
`endif
wire [ADDR_WIDTH-1:0] lsu_wbu_dnpc;
wire [ADDR_WIDTH-1:0] lsu_wbu_pc;
wire									lsu_wbu_regwr;
wire									lsu_wbu_csr1wr;
wire									lsu_wbu_csr2wr;
wire [RS_WIDTH  -1:0] lsu_wbu_rd ;
wire [DATA_WIDTH-1:0] lsu_wbu_res;
wire [CAR_WIDTH -1:0] lsu_wbu_csr1;
wire [CAR_WIDTH -1:0] lsu_wbu_csr2;
wire [DATA_WIDTH-1:0] lsu_wbu_csrs1;
wire [DATA_WIDTH-1:0] lsu_wbu_csrs2;


wire lsu_wreq       ;
wire lsu_back_ready ;
wire lsu_back_valid ;
wire lsu_rreq       ;
wire lsu_rdata_ready;
wire lsu_rdata_valid;
wire [DATA_WIDTH -1:0] lsu_mem_waddr;
wire [DATA_WIDTH -1:0] lsu_mem_wdata;
wire [ADDR_WIDTH -1:0] lsu_mem_raddr;
wire [DATA_WIDTH -1:0] lsu_mem_rdata;
wire [            3:0] lsu_ram_mask;
wire [            1:0] lsu_ram_size;

wire [RS_WIDTH  -1:0] wbu_rf_rd	  ;		 
wire [DATA_WIDTH-1:0] wbu_rf_wdata;	 
wire wbu_rf_wen; 	 
wire [CAR_WIDTH  -1:0] wbu_rf_csr1;		 
wire [CAR_WIDTH  -1:0] wbu_rf_csr2;		 
wire [DATA_WIDTH-1:0] wbu_rf_csrs1;	 
wire [DATA_WIDTH-1:0] wbu_rf_csrs2;	 
wire wbu_rf_cwen1; 	 
wire wbu_rf_cwen2; 	 

wire [ADDR_WIDTH-1:0] wbu_dnpc;
wire speec;

//components

ysyx_25010009_ifu_axi_bridge #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) ifu_axi_bridge (
    .aclk        (clk            ),
    .areset      (rst            ),

    .araddr      (ifu_araddr     ),
    .arsize      (ifu_arsize     ),
    .arvalid     (ifu_arvalid    ),    
    .arready     (ifu_arready    ),
                             
    .rdata       (ifu_rdata      ),
    .rresp       (ifu_rresp      ),
    .rvalid      (ifu_rvalid     ),
    .rready      (ifu_rready     ),

    .cpu_rreq    (ifu_rreq       ),
    .cpu_rready  (ifu_rdata_ready),
    .cpu_rresp   (ifu_rdata_valid),
    .cpu_raddr   (ifu_addr       ),
    .cpu_rdata   (ifu_data       )
);

ysyx_25010009_lsu_axi_bridge #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) lsu_axi_bridge (
    .aclk        (clk            ),
    .areset      (rst            ),

    .araddr      (lsu_araddr     ),
    .arsize      (lsu_arsize     ),
    .arvalid     (lsu_arvalid    ),    
    .arready     (lsu_arready    ),
                             
    .rdata       (lsu_rdata      ),
    .rresp       (lsu_rresp      ),
    .rvalid      (lsu_rvalid     ),
    .rready      (lsu_rready     ),
                          
    .awaddr      (lsu_awaddr     ),
    .awsize      (lsu_awsize     ),
    .awvalid     (lsu_awvalid    ),
    .awready     (lsu_awready    ),
                          
    .wdata       (lsu_wdata      ),
    .wstrb       (lsu_wstrb      ),
    .wvalid      (lsu_wvalid     ),
    .wready      (lsu_wready     ),
                           
    .bresp       (lsu_bresp      ), 
    .bvalid      (lsu_bvalid     ),
    .bready      (lsu_bready     ),

    .cpu_wreq    (lsu_wreq       ),
    .cpu_wready  (lsu_back_ready ),
    .cpu_wresp   (lsu_back_valid ),
    .cpu_rreq    (lsu_rreq       ),
    .cpu_rready  (lsu_rdata_ready),
    .cpu_rresp   (lsu_rdata_valid),
    .cpu_waddr   (lsu_mem_waddr  ),
    .cpu_wdata   (lsu_mem_wdata  ),
    .cpu_raddr   (lsu_mem_raddr  ),
    .cpu_rdata   (lsu_mem_rdata  ),
    .cpu_ram_mask(lsu_ram_mask   ),
    .cpu_ram_size(lsu_ram_size   )
);

ysyx_25010009_axi_arbiter #(
	.ADDR_WIDTH  (ADDR_WIDTH  ), 
	.DATA_WIDTH  (DATA_WIDTH  )
) axi_arbiter (
	.clk        (clk              ),
	.rst        (rst		      ),
    //cpu AXI-LIte
    .lsu_awaddr (lsu_awaddr       ),
    .lsu_awsize (lsu_awsize       ),
    .lsu_awvalid(lsu_awvalid      ),
    .lsu_awready(lsu_awready      ),

    .lsu_wdata  (lsu_wdata        ),
    .lsu_wstrb  (lsu_wstrb        ),
    .lsu_wvalid (lsu_wvalid       ),
    .lsu_wready (lsu_wready       ),

    .lsu_bresp  (lsu_bresp        ),
    .lsu_bvalid (lsu_bvalid       ),
    .lsu_bready (lsu_bready       ),

    .lsu_araddr (lsu_araddr       ),
    .lsu_arsize (lsu_arsize       ),
    .lsu_arvalid(lsu_arvalid      ),
    .lsu_arready(lsu_arready      ),

    .lsu_rdata  (lsu_rdata        ),
    .lsu_rresp  (lsu_rresp        ),
    .lsu_rvalid (lsu_rvalid       ),
    .lsu_rready (lsu_rready       ),

    .ifu_araddr (ifu_araddr       ),
    .ifu_arsize (ifu_arsize       ),
    .ifu_arvalid(ifu_arvalid      ),
    .ifu_arready(ifu_arready      ),

    .ifu_rdata  (ifu_rdata        ),
    .ifu_rresp  (ifu_rresp        ),
    .ifu_rvalid (ifu_rvalid       ),
    .ifu_rready (ifu_rready       ),
    
    //master AXI-Lite
    .awaddr     (io_master_awaddr ),
    .awsize     (io_master_awsize ),
    .awvalid    (io_master_awvalid),
    .awready    (io_master_awready),
     
    .wdata      (io_master_wdata  ),
    .wstrb      (io_master_wstrb  ),
    .wvalid     (io_master_wvalid ),
    .wready     (io_master_wready ),
     
    .bresp      (io_master_bresp  ), 
    .bvalid     (io_master_bvalid ),
    .bready     (io_master_bready ),
     
    .araddr     (io_master_araddr ),
    .arsize     (io_master_arsize ),
    .arvalid    (io_master_arvalid),    
    .arready    (io_master_arready),
    
    .rdata      (io_master_rdata  ),
    .rresp      (io_master_rresp  ),
    .rvalid     (io_master_rvalid ),
    .rready     (io_master_rready )
                              
);
ysyx_25010009_ifu #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.PC_INIT   (PC_INIT   )
) IFU (
	.clk          (clk            ),
	.rst          (rst	          ),
	.ifu_idu_valid(ifu_idu_valid  ),
	.ifu_idu_ready(ifu_idu_ready  ),
    .rreq         (ifu_rreq       ),
    .rdata_ready  (ifu_rdata_ready),
    .rdata_valid  (ifu_rdata_valid),
	.finst        (ifu_data       ),
	.addr         (ifu_addr       ),
	.inst         (ifu_idu_inst   ),
	.pc	          (ifu_idu_pc     ),
	.snpc         (ifu_idu_snpc   ),
	.dnpc         (ifu_idu_dnpc   ),
	.wbu_dnpc     (wbu_dnpc       ),
	.speec	      (speec	      ),
	.is_RAW_control(1'b0)
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
	.INST_BITS	 (INST_BITS	  ),
	.PCMUX_WIDTH (PCMUX_WIDTH ),
	.MSTATUS	 (MSTATUS	  ),
	.MTVEC		 (MTVEC	 	  ),
	.MEPC   	 (MEPC   	  ),
	.MCAUSE 	 (MCAUSE 	  ) 
) IDU (
	.clk(clk    ),
	.rst(rst	),
	.ifu_idu_valid(ifu_idu_valid),
	.ifu_idu_ready(ifu_idu_ready),
	.inst         (ifu_idu_inst ),
	.pc			  (ifu_idu_pc	),
	.snpc	      (ifu_idu_snpc	),
	.dnpc	      (ifu_idu_dnpc	),
	.idu_exu_valid(idu_exu_valid),
	.idu_exu_ready(idu_exu_ready),
`ifdef VERILATOR
	.exu_ebreak   (idu_exu_ebreak),
	.exu_inst     (idu_exu_inst	 ),
`endif
	.exu_snpc (idu_exu_snpc	   ),
	.exu_dnpc (idu_exu_dnpc	   ),
	.exu_pc	  (idu_exu_pc	   ),
	.exu_shamt(idu_exu_shamt   ),
    .exu_imm  (idu_exu_imm 	   ),
	.src1	  (idu_exu_src1	   ),
	.src2	  (idu_exu_src2	   ),
	.rd       (idu_exu_rd      ),
	.opmux	  (idu_exu_opmux   ),
	.opsel	  (idu_exu_opsel   ),
	.mwdata   (idu_exu_mwdata  ),
	.memwr    (idu_exu_memwr   ),
	.memre    (idu_exu_memre   ),
	.mem_mask (idu_exu_mask	   ),
	.mem_sext (idu_exu_sext	   ),
	.regwr    (idu_exu_regwr   ),	
	.csr1wr	  (idu_exu_csr1wr  ),
	.csr2wr	  (idu_exu_csr2wr  ),
	.csr1rd	  (idu_exu_csr1rd  ),
	.csr2rd	  (idu_exu_csr2rd  ),
	.is_jalr  (idu_exu_is_jalr ),
	.is_jal   (idu_exu_is_jal  ),
	.is_bxx   (idu_exu_is_bxx  ),
	.is_ecall (idu_exu_is_ecall),
	.is_mret  (idu_exu_is_mret ),
	.is_csrrc (idu_exu_is_csrrc),
	.is_csrrs (idu_exu_is_csrrs),
	.is_csrrw (idu_exu_is_csrrw),
	.exu_csrs (idu_exu_csrs    ),
	.exu_mepc (idu_exu_mepc	   ),
	.exu_mtvec(idu_exu_mtvec   ),
	.csr	  (idu_rf_csr	   ),
	.csrs	  (idu_rf_csrs	   ),
	.rs1	  (idu_rf_rs1	   ),
	.rs2	  (idu_rf_rs2	   ),
	.rf_src1  (idu_rf_src1	   ),
    .rf_src2  (idu_rf_src2 	   ),
	.mepc	  (idu_rf_mepc	   ),
	.mtvec	  (idu_rf_mtvec	   )
);

ysyx_25010009_exu #(
	.DATA_WIDTH (DATA_WIDTH ), 
	.RS_WIDTH   (RS_WIDTH   ), 
	.OPSEL_WIDTH(OPSEL_WIDTH)
) EXU (
	.clk(clk	),
	.rst(rst	),
	.idu_exu_valid(idu_exu_valid),
	.idu_exu_ready(idu_exu_ready),
`ifdef VERILATOR
	.ebreak		  (idu_exu_ebreak  ),
	.inst		  (idu_exu_inst	   ),
	.rs1		  (idu_rf_rs1	   ),
`endif
	.dnpc		  (idu_exu_dnpc	   ),
	.pc     	  (idu_exu_pc      ),
	.imm    	  (idu_exu_imm     ),
	.shamt		  (idu_exu_shamt   ),
	.src1	  	  (idu_exu_src1	   ),
	.src2	  	  (idu_exu_src2	   ),
	.rd     	  (idu_exu_rd      ),
	.opmux		  (idu_exu_opmux   ),
	.opsel  	  (idu_exu_opsel   ),
	.mwdata 	  (idu_exu_mwdata  ),
	.mem_mask	  (idu_exu_mask	   ),
	.mem_sext	  (idu_exu_sext	   ),
	.memre  	  (idu_exu_memre   ),
	.memwr  	  (idu_exu_memwr   ),
	.regwr  	  (idu_exu_regwr   ),	
	.csr1wr  	  (idu_exu_csr1wr  ),	
	.csr2wr  	  (idu_exu_csr2wr  ),	
	.csr1rd  	  (idu_exu_csr1rd  ),	
	.csr2rd  	  (idu_exu_csr2rd  ),	
	.is_jal 	  (idu_exu_is_jal  ),
	.is_jalr	  (idu_exu_is_jalr ),
	.is_bxx 	  (idu_exu_is_bxx  ),
	.is_ecall	  (idu_exu_is_ecall),
	.is_mret	  (idu_exu_is_mret ),
	.is_csrrc	  (idu_exu_is_csrrc),
	.is_csrrs	  (idu_exu_is_csrrs),
	.is_csrrw	  (idu_exu_is_csrrw),
	.csrs		  (idu_exu_csrs	   ),
	.mepc		  (idu_exu_mepc	   ),
	.mtvec		  (idu_exu_mtvec   ),
	.isRAW_control(),
	.exu_lsu_valid(exu_lsu_valid   ),
	.exu_lsu_ready(exu_lsu_ready   ),
`ifdef VERILATOR
	.lsu_ebreak	  (exu_lsu_ebreak  ),
	.lsu_inst	  (exu_lsu_inst	   ),
	.lsu_snpc	  (exu_lsu_snpc	   ),
	.lsu_rs1	  (exu_lsu_rs1	   ),
	.lsu_jal	  (exu_lsu_jal	   ),
	.lsu_jalr	  (exu_lsu_jalr	   ),
`endif
	.lsu_dnpc	  (exu_lsu_dnpc	   ),
	.lsu_pc		  (exu_lsu_pc	   ),
	.lsu_mwdata	  (exu_lsu_mwdata  ),
	.lsu_memwr 	  (exu_lsu_memwr   ),
	.lsu_memre 	  (exu_lsu_memre   ),
	.lsu_mask	  (exu_lsu_mask	   ),
	.lsu_sext	  (exu_lsu_sext	   ),
	.lsu_csr1wr   (exu_lsu_csr1wr  ),	
	.lsu_csr2wr   (exu_lsu_csr2wr  ),	
	.lsu_regwr 	  (exu_lsu_regwr   ),	
	.paddr     	  (exu_lsu_paddr   ),
	.gpr_rd		  (exu_lsu_rd	   ),
	.gpr_res   	  (exu_lsu_res     ),
	.csr_rd1	  (exu_lsu_csr1	   ),
	.csr_rd2	  (exu_lsu_csr2	   ),
	.csr_res1	  (exu_lsu_csrs1   ),
	.csr_res2	  (exu_lsu_csrs2   )
);

ysyx_25010009_lsu #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.RS_WIDTH  (RS_WIDTH  ),
	.CAR_WIDTH (CAR_WIDTH )
) LSU (
	.clk          (clk	          ),
	.rst          (rst	          ),
	.exu_lsu_valid(exu_lsu_valid  ),
	.exu_lsu_ready(exu_lsu_ready  ),
`ifdef VERILATOR
	.ebreak	      (exu_lsu_ebreak ),
	.inst		  (exu_lsu_inst	  ),
	.snpc		  (exu_lsu_snpc	  ),
	.rs1		  (exu_lsu_rs1	  ),
	.jal		  (exu_lsu_jal	  ),
	.jalr		  (exu_lsu_jalr	  ),
`endif
	.dnpc		  (exu_lsu_dnpc	  ),
	.pc		 	  (exu_lsu_pc	  ),
	.mwdata		  (exu_lsu_mwdata ),
	.mem_mask     (exu_lsu_mask	  ),
	.mem_sext     (exu_lsu_sext	  ),
	.memwr 		  (exu_lsu_memwr  ),
	.memre 		  (exu_lsu_memre  ),
	.regwr 		  (exu_lsu_regwr  ),	
	.csr1wr 	  (exu_lsu_csr1wr ),	
	.csr2wr 	  (exu_lsu_csr2wr ),	
	.paddr        (exu_lsu_paddr  ),
	.gpr_rd		  (exu_lsu_rd	  ),
	.gpr_res      (exu_lsu_res    ),
	.csr_rd1	  (exu_lsu_csr1	  ),
	.csr_rd2	  (exu_lsu_csr2	  ),
	.csr_res1     (exu_lsu_csrs1  ),
	.csr_res2     (exu_lsu_csrs2  ),
    .wreq         (lsu_wreq       ),
    .back_ready   (lsu_back_ready ),
    .back_valid   (lsu_back_valid ),
    .rreq         (lsu_rreq       ),
    .rdata_ready  (lsu_rdata_ready),
    .rdata_valid  (lsu_rdata_valid),
    .waddr        (lsu_mem_waddr  ),
    .wdata        (lsu_mem_wdata  ),
    .raddr        (lsu_mem_raddr  ),
    .rdata        (lsu_mem_rdata  ),
    .ram_mask     (lsu_ram_mask   ),
    .ram_size     (lsu_ram_size   ),
	.lsu_wbu_valid(lsu_wbu_valid  ),
	.lsu_wbu_ready(lsu_wbu_ready  ),
`ifdef VERILATOR
	.wbu_ebreak   (lsu_wbu_ebreak ),
	.wbu_inst	  (lsu_wbu_inst	  ),
	.wbu_snpc	  (lsu_wbu_snpc	  ),
	.wbu_rs1	  (lsu_wbu_rs1    ),
	.wbu_jal	  (lsu_wbu_jal	  ),
	.wbu_jalr	  (lsu_wbu_jalr	  ),
`endif
	.wbu_dnpc	  (lsu_wbu_dnpc	  ),
	.wbu_pc		  (lsu_wbu_pc	  ),
	.wbu_regwr    (lsu_wbu_regwr  ),	
	.wbu_csr1wr   (lsu_wbu_csr1wr ),	
	.wbu_csr2wr   (lsu_wbu_csr2wr ),	
	.wbu_gpr_rd	  (lsu_wbu_rd	  ),
	.wbu_gpr_res  (lsu_wbu_res	  ),
	.wbu_csr_rd1  (lsu_wbu_csr1	  ),
	.wbu_csr_rd2  (lsu_wbu_csr2	  ),
	.wbu_csr_res1 (lsu_wbu_csrs1  ),
	.wbu_csr_res2 (lsu_wbu_csrs2  ) 
);

ysyx_25010009_wbu #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.RS_WIDTH  (RS_WIDTH  ),
	.CAR_WIDTH (CAR_WIDTH )
) WBU (
	.clk(clk	),
	.rst(rst	),
	.pc		      (lsu_wbu_pc	),
	.lsu_wbu_valid(lsu_wbu_valid),
	.lsu_wbu_ready(lsu_wbu_ready),
`ifdef VERILATOR
	.ebreak       (lsu_wbu_ebreak),
	.inst		  (lsu_wbu_inst	 ),
	.snpc		  (lsu_wbu_snpc  ),
	.rs1		  (lsu_wbu_rs1	 ),
	.jal		  (lsu_wbu_jal	 ),
	.jalr		  (lsu_wbu_jalr	 ),
`endif
	.dnpc		  (lsu_wbu_dnpc  ),
	.regwr        (lsu_wbu_regwr ),	
	.csr1wr       (lsu_wbu_csr1wr),	
	.csr2wr       (lsu_wbu_csr2wr),	
	.rd		      (lsu_wbu_rd	 ),
	.gpr_res      (lsu_wbu_res	 ),  
	.csr_rd1      (lsu_wbu_csr1	 ),
	.csr_rd2      (lsu_wbu_csr2	 ),
	.csr_res1     (lsu_wbu_csrs1 ),
	.csr_res2     (lsu_wbu_csrs2 ),
	.rf_gpr_rd	  (wbu_rf_rd	 ),
	.rf_gpr_wdata (wbu_rf_wdata	 ),
	.rf_gpr_wen   (wbu_rf_wen  	 ),
	.rf_csr_rd1	  (wbu_rf_csr1	 ),
	.rf_csr_rd2	  (wbu_rf_csr2	 ),
	.rf_csr_res1  (wbu_rf_csrs1	 ),
	.rf_csr_res2  (wbu_rf_csrs2	 ),
	.rf_csr_wen1  (wbu_rf_cwen1	 ),
	.rf_csr_wen2  (wbu_rf_cwen2	 ),
	.wbu_dnpc     (wbu_dnpc      ),
	.speec	      (speec		 )
);

ysyx_25010009_RegisterFile #(
	.GPR_NUM   (GPR_NUM	  ),
	.CSR_NUM   (CSR_NUM	  ),
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(RS_WIDTH  ),
	.MSTATUS   (MSTATUS	  ),
	.MTVEC	   (MTVEC	  ),
	.MEPC      (MEPC   	  ),
	.MCAUSE    (MCAUSE 	  ) 
) GPR (
	.clk(clk	),
	.rst(rst	),
	.gpr_wdata	(wbu_rf_wdata),
	.gpr_waddr	(wbu_rf_rd	 ),
	.gpr_raddr1	(idu_rf_rs1	 ),
	.gpr_raddr2	(idu_rf_rs2	 ),
	.gpr_rdata1	(idu_rf_src1 ),
	.gpr_rdata2	(idu_rf_src2 ),
	.gpr_wen	(wbu_rf_wen	 ),
	.csrs_wdata1(wbu_rf_csrs1),
	.csrs_waddr1(wbu_rf_csr1 ),
	.csrs_wdata2(wbu_rf_csrs2),
	.csrs_waddr2(wbu_rf_csr2 ),
	.csrs_rdata	(idu_rf_csrs ),
	.csrs_raddr	(idu_rf_csr  ),
	.csrs_wen1	(wbu_rf_cwen1),
	.csrs_wen2	(wbu_rf_cwen1),
	.rf_mepc	(idu_rf_mepc ),
	.rf_mtvec	(idu_rf_mtvec)
);

ysyx_25010009_counter #(
	.WIDTH(CNT_WIDTH)
) CNT (
	.clk(clk     ),
	.rst(rst	),
	.en (!rst	),
	.cnt(counter)
);

`ifdef VERILATOR
import "DPI-C" function void speec_once(int speec);
always @(posedge clk) 
	speec_once({31'b0, speec});
`endif

endmodule
