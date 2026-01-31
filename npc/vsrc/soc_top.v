`timescale 1ns / 1ps
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

wire [ADDR_WIDTH-1:0] cpu_m_lsu_awaddr ;
wire [           2:0] cpu_m_lsu_awsize ;
wire                  cpu_m_lsu_awvalid;
wire                  cpu_m_lsu_awready;
wire [DATA_WIDTH-1:0] cpu_m_lsu_wdata  ;
wire [           3:0] cpu_m_lsu_wstrb  ;
wire                  cpu_m_lsu_wvalid ;
wire                  cpu_m_lsu_wready ;
wire [           2:0] cpu_m_lsu_bresp  ;
wire                  cpu_m_lsu_bvalid ;
wire                  cpu_m_lsu_bready ;
wire [ADDR_WIDTH-1:0] cpu_m_lsu_araddr ;
wire [           2:0] cpu_m_lsu_arsize ;
wire                  cpu_m_lsu_arvalid;
wire                  cpu_m_lsu_arready;
wire [DATA_WIDTH-1:0] cpu_m_lsu_rdata  ;
wire [           2:0] cpu_m_lsu_rresp  ;
wire                  cpu_m_lsu_rvalid ;
wire                  cpu_m_lsu_rready ;
wire [ADDR_WIDTH-1:0] cpu_m_ifu_araddr ;
wire [           2:0] cpu_m_ifu_arsize ;
wire                  cpu_m_ifu_arvalid;
wire                  cpu_m_ifu_arready;
wire [DATA_WIDTH-1:0] cpu_m_ifu_rdata  ;
wire [           2:0] cpu_m_ifu_rresp  ;
wire                  cpu_m_ifu_rvalid ;
wire                  cpu_m_ifu_rready ;

wire [ADDR_WIDTH-1:0] cpu_m_ram_awaddr ;
wire [           2:0] cpu_m_ram_awsize ;
wire                  cpu_m_ram_awvalid;
wire                  cpu_m_ram_awready;
wire [DATA_WIDTH-1:0] cpu_m_ram_wdata  ;
wire [           3:0] cpu_m_ram_wstrb  ;
wire                  cpu_m_ram_wvalid ;
wire                  cpu_m_ram_wready ;
wire [           2:0] cpu_m_ram_bresp  ;
wire                  cpu_m_ram_bvalid ;
wire                  cpu_m_ram_bready ;
wire [ADDR_WIDTH-1:0] cpu_m_ram_araddr ;
wire [           2:0] cpu_m_ram_arsize ;
wire                  cpu_m_ram_arvalid;
wire                  cpu_m_ram_arready;
wire [DATA_WIDTH-1:0] cpu_m_ram_rdata  ;
wire [           2:0] cpu_m_ram_rresp  ;
wire                  cpu_m_ram_rvalid ;
wire                  cpu_m_ram_rready ;

wire                  mem_we   ;
wire                  mem_req  ;
wire                  mem_resp ;
wire [          31:0] mem_len  ;
wire [ADDR_WIDTH-1:0] mem_raddr;
wire [DATA_WIDTH-1:0] mem_rdata;
wire [ADDR_WIDTH-1:0] mem_waddr;
wire [DATA_WIDTH-1:0] mem_wdata;

ysyx_25010009_sram_axi_bridge #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) sram_axi_bridge (
    .aclk        (clk              ),
`ifdef VERILATOR
	.areset      (buf_rst	       ),
`else
	.areset      (rst		       ),
`endif

    .awaddr      (cpu_m_ram_awaddr ),
    .awsize      (cpu_m_ram_awsize ),
    .awvalid     (cpu_m_ram_awvalid),
    .awready     (cpu_m_ram_awready),
                        
    .wdata       (cpu_m_ram_wdata  ),
    .wstrb       (cpu_m_ram_wstrb  ),
    .wvalid      (cpu_m_ram_wvalid ),
    .wready      (cpu_m_ram_wready ),
                       
    .bresp       (cpu_m_ram_bresp  ), 
    .bvalid      (cpu_m_ram_bvalid ),
    .bready      (cpu_m_ram_bready ),
                        
    .araddr      (cpu_m_ram_araddr ),
    .arsize      (cpu_m_ram_arsize ),
    .arvalid     (cpu_m_ram_arvalid),    
    .arready     (cpu_m_ram_arready),
                        
    .rdata       (cpu_m_ram_rdata  ),
    .rresp       (cpu_m_ram_rresp  ),
    .rvalid      (cpu_m_ram_rvalid ),
    .rready      (cpu_m_ram_rready ),
                              
    .we          (mem_we           ),
    .req         (mem_req          ),
    .resp        (mem_resp         ),
    .len         (mem_len          ),
    .mem_raddr   (mem_raddr        ),
    .mem_rdata   (mem_rdata        ),
    .mem_waddr   (mem_waddr        ),
    .mem_wdata   (mem_wdata        )
);

ysyx_25010009_axi_arbiter #(
	.ADDR_WIDTH  (ADDR_WIDTH  ), 
	.DATA_WIDTH  (DATA_WIDTH  )
) axi_arbiter (
	.clk        (clk              ),
`ifdef VERILATOR
	.rst        (buf_rst	      ),
`else
	.rst        (rst		      ),
`endif
    //cpu AXI-LIte
    .lsu_awaddr (cpu_m_lsu_awaddr ),
    .lsu_awsize (cpu_m_lsu_awsize ),
    .lsu_awvalid(cpu_m_lsu_awvalid),
    .lsu_awready(cpu_m_lsu_awready),

    .lsu_wdata  (cpu_m_lsu_wdata  ),
    .lsu_wstrb  (cpu_m_lsu_wstrb  ),
    .lsu_wvalid (cpu_m_lsu_wvalid ),
    .lsu_wready (cpu_m_lsu_wready ),

    .lsu_bresp  (cpu_m_lsu_bresp  ),
    .lsu_bvalid (cpu_m_lsu_bvalid ),
    .lsu_bready (cpu_m_lsu_bready ),

    .lsu_araddr (cpu_m_lsu_araddr ),
    .lsu_arsize (cpu_m_lsu_arsize ),
    .lsu_arvalid(cpu_m_lsu_arvalid),
    .lsu_arready(cpu_m_lsu_arready),

    .lsu_rdata  (cpu_m_lsu_rdata  ),
    .lsu_rresp  (cpu_m_lsu_rresp  ),
    .lsu_rvalid (cpu_m_lsu_rvalid ),
    .lsu_rready (cpu_m_lsu_rready ),

    .ifu_araddr (cpu_m_ifu_araddr ),
    .ifu_arsize (cpu_m_ifu_arsize ),
    .ifu_arvalid(cpu_m_ifu_arvalid),
    .ifu_arready(cpu_m_ifu_arready),

    .ifu_rdata  (cpu_m_ifu_rdata  ),
    .ifu_rresp  (cpu_m_ifu_rresp  ),
    .ifu_rvalid (cpu_m_ifu_rvalid ),
    .ifu_rready (cpu_m_ifu_rready ),
    
    //ram AXI-Lite
    .ram_awaddr (cpu_m_ram_awaddr ),
    .ram_awsize (cpu_m_ram_awsize ),
    .ram_awvalid(cpu_m_ram_awvalid),
    .ram_awready(cpu_m_ram_awready),
     
    .ram_wdata  (cpu_m_ram_wdata  ),
    .ram_wstrb  (cpu_m_ram_wstrb  ),
    .ram_wvalid (cpu_m_ram_wvalid ),
    .ram_wready (cpu_m_ram_wready ),
     
    .ram_bresp  (cpu_m_ram_bresp  ), 
    .ram_bvalid (cpu_m_ram_bvalid ),
    .ram_bready (cpu_m_ram_bready ),
     
    .ram_araddr (cpu_m_ram_araddr ),
    .ram_arsize (cpu_m_ram_arsize ),
    .ram_arvalid(cpu_m_ram_arvalid),    
    .ram_arready(cpu_m_ram_arready),
    
    .ram_rdata  (cpu_m_ram_rdata  ),
    .ram_rresp  (cpu_m_ram_rresp  ),
    .ram_rvalid (cpu_m_ram_rvalid ),
    .ram_rready (cpu_m_ram_rready )
                              
);

ysyx_25010009_cpu_top #(
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
) u_cpu (
	.clk        (clk              ),
`ifdef VERILATOR
	.rst        (buf_rst	      ),
`else
	.rst        (rst		      ),
`endif
	.counter    (counter          ),
    //AXI-LIte
    .lsu_awaddr (cpu_m_lsu_awaddr ),
    .lsu_awsize (cpu_m_lsu_awsize ),
    .lsu_awvalid(cpu_m_lsu_awvalid),
    .lsu_awready(cpu_m_lsu_awready),

    .lsu_wdata  (cpu_m_lsu_wdata  ),
    .lsu_wstrb  (cpu_m_lsu_wstrb  ),
    .lsu_wvalid (cpu_m_lsu_wvalid ),
    .lsu_wready (cpu_m_lsu_wready ),

    .lsu_bresp  (cpu_m_lsu_bresp  ),
    .lsu_bvalid (cpu_m_lsu_bvalid ),
    .lsu_bready (cpu_m_lsu_bready ),

    .lsu_araddr (cpu_m_lsu_araddr ),
    .lsu_arsize (cpu_m_lsu_arsize ),
    .lsu_arvalid(cpu_m_lsu_arvalid),
    .lsu_arready(cpu_m_lsu_arready),

    .lsu_rdata  (cpu_m_lsu_rdata  ),
    .lsu_rresp  (cpu_m_lsu_rresp  ),
    .lsu_rvalid (cpu_m_lsu_rvalid ),
    .lsu_rready (cpu_m_lsu_rready ),

    .ifu_araddr (cpu_m_ifu_araddr ),
    .ifu_arsize (cpu_m_ifu_arsize ),
    .ifu_arvalid(cpu_m_ifu_arvalid),
    .ifu_arready(cpu_m_ifu_arready),

    .ifu_rdata  (cpu_m_ifu_rdata  ),
    .ifu_rresp  (cpu_m_ifu_rresp  ),
    .ifu_rvalid (cpu_m_ifu_rvalid ),
    .ifu_rready (cpu_m_ifu_rready )
);

ysyx_25010009_sram #(
	.XLEN(DATA_WIDTH)
) SRAM (
	.clk	  (clk	    ),
`ifdef VERILATOR
	.rst      (buf_rst	),
`else
	.rst      (rst		),
`endif
    .we       (mem_we   ),
	.req      (mem_req  ),
	.resp     (mem_resp ),
    .len      (mem_len  ),
	.mem_raddr(mem_raddr),
	.mem_rdata(mem_rdata),
	.mem_waddr(mem_waddr),
	.mem_wdata(mem_wdata)
);
endmodule
