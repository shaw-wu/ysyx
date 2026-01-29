module ysyx_25010009_soc_top #(
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32,
	parameter CNT_WIDTH		 = 32
)(
    input clk,
    input rst,
    output [CNT_WIDTH-1:0] counter
);

`ifdef VERILATOR
reg buf_rst;
always @(posedge clk) begin
	buf_rst <= rst;
end
`endif

wire [ADDR_BITS-1:0] cpu_m_awaddr ;
wire                 cpu_m_awvalid;
wire                 cpu_m_awready;
wire [DATA_BITS-1:0] cpu_m_wdata  ;
wire [          3:0] cpu_m_wstrb  ;
wire                 cpu_m_wvalid ;
wire                 cpu_m_wready ;
wire [          2:0] cpu_m_bresp  ;
wire                 cpu_m_bvalid ;
wire                 cpu_m_bready ;
wire [ADDR_BITS-1:0] cpu_m_araddr ;
wire                 cpu_m_arvalid;
wire                 cpu_m_arready;
wire [DATA_BITS-1:0] cpu_m_rdata  ;
wire [          2:0] cpu_m_rresp  ;
wire                 cpu_m_rvalid ;
wire                 cpu_m_rready ;

ysyx_25010009_dram_axi_bridge dram_axi_bridge(
    .aclk        (clk         ),
    .areset      (rst         ),

    .araddr      (araddr      ),
    .arvalid     (arvalid     ),    
    .arready     (arready     ),
                         
    .rdata       (rdata       ),
    .rresp       (rresp       ),
    .rvalid      (rvalid      ),
    .rready      (rready      ),
                              
    .awaddr      (awaddr      ),
    .awvalid     (awvalid     ),
    .awready     (awready     ),
                              
    .wdata       (wdata       ),
    .wstrb       (wstrb       ),
    .wvalid      (wvalid      ),
    .wready      (wready      ),
                               
    .bresp       (bresp       ), 
    .bvalid      (bvalid      ),
    .bready      (bvalid      ),

    .cpu_wreq    (lsu_wreq    ),
    .cpu_wready  (lsu_wready  ),
    .cpu_wresp   (lsu_wresp   ),
    .cpu_rreq    (lsu_rreq)   ),
    .cpu_rready  (lsu_rready  ),
    .cpu_rresp   (lsu_rresp   ),
    .cpu_waddr   (lsu_waddr   ),
    .cpu_wdata   (lsu_wdata   ),
    .cpu_raddr   (lsu_raddr   ),
    .cpu_rdata   (lsu_rdata   ),
    .cpu_ram_mask(lsu_ram_mask),
    .cpu_ram_size(lsu_ram_size),
    .cpu_bready  (bready      )
);
localparam PC_INIT	    = 32'h8000_0000;
localparam RS_WIDTH     = 5 ; 
localparam CAR_WIDTH    = 12; 
localparam FUNCT3_WIDTH = 3 ; 
localparam FUNCT7_WIDTH = 7 ; 
localparam OPCODE_WIDTH = 7 ; 
localparam OPSEL_WIDTH  = 4 ;
localparam OPMUX_WIDTH  = 4 ;
localparam PCMUX_WIDTH  = 2 ;
localparam INST_BITS	= 6 ;

ysyx_25010009_cpu_top u_cpu#(
	.PC_INIT	 (PC_INIT	  ),
	.ADDR_WIDTH  (ADDR_WIDTH  ), 
	.DATA_WIDTH  (DATA_WIDTH  ),
	.RS_WIDTH    (RS_WIDTH    ), 
	.CAR_WIDTH   (CAR_WIDTH   ), 
	.FUNCT3_WIDTH(FUNCT3_WIDTH), 
	.FUNCT7_WIDTH(FUNCT7_WIDTH), 
	.OPCODE_WIDTH(OPCODE_WIDTH), 
	.OPSEL_WIDTH (OPSEL_WIDTH ),
	.OPMUX_WIDTH (OPMUX_WIDTH ),
	.PCMUX_WIDTH (PCMUX_WIDTH ),
	.INST_BITS	 (INST_BITS	  ),
	.CNT_WIDTH	 (CNT_WIDTH	  )
)(
	.clk    (clk    ),
	.rst    (rst    ),
	.counter(counter),
    //AXI-LIte
    .awaddr (cpu_m_awaddr ),
    .awvalid(cpu_m_awvalid),
    .awready(cpu_m_awready),
    .wdata  (cpu_m_wdata  ),
    .wstrb  (cpu_m_wstrb  ),
    .wvalid (cpu_m_wvalid ),
    .wready (cpu_m_wready ),
    .bresp  (cpu_m_bresp  ),
    .bvalid (cpu_m_bvalid ),
    .bready (cpu_m_bready ),
    .araddr (cpu_m_araddr ),
    .arvalid(cpu_m_arvalid),
    .arready(cpu_m_arready),
    .rdata  (cpu_m_rdata  ),
    .rresp  (cpu_m_rresp  ),
    .rvalid (cpu_m_rvalid ),
    .rready (cpu_m_rready )
);

ysyx_25010009_dram #(
	.XLEN(DATA_WIDTH)
) DRAM (
	.clk	(clk		),
`ifdef VERILATOR
	.rst (buf_rst	 ),
`else
	.rst (rst			 ),
`endif
	.mask	(dram_mask	 ),
	.size   (dram_size	 ),
	.awvalid(dram_awvalid),
	.arvalid(dram_arvalid),
	.bvalid(dram_bvalid),
	.rvalid(dram_rvalid),
	.raddr(dram_raddr),
	.rdata(dram_rdata),
	.waddr(dram_waddr),
	.wdata(dram_wdata)
);
endmodule
