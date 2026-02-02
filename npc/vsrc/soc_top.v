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
	.clk              (clk              ),
`ifdef VERILATOR      
	.rst              (buf_rst	        ),
`else
	.rst              (rst		        ),
`endif
	.counter          (counter          ),
    //AXI-LIte
    .io_master_awaddr (cpu_m_ram_awaddr ),
    .io_master_awsize (cpu_m_ram_awsize ),
    .io_master_awvalid(cpu_m_ram_awvalid),
    .io_master_awready(cpu_m_ram_awready),

    .io_master_wdata  (cpu_m_ram_wdata  ),
    .io_master_wstrb  (cpu_m_ram_wstrb  ),
    .io_master_wvalid (cpu_m_ram_wvalid ),
    .io_master_wready (cpu_m_ram_wready ),

    .io_master_bresp  (cpu_m_ram_bresp  ),
    .io_master_bvalid (cpu_m_ram_bvalid ),
    .io_master_bready (cpu_m_ram_bready ),

    .io_master_araddr (cpu_m_ram_araddr ),
    .io_master_arsize (cpu_m_ram_arsize ),
    .io_master_arvalid(cpu_m_ram_arvalid),
    .io_master_arready(cpu_m_ram_arready),

    .io_master_rdata  (cpu_m_ram_rdata  ),
    .io_master_rresp  (cpu_m_ram_rresp  ),
    .io_master_rvalid (cpu_m_ram_rvalid ),
    .io_master_rready (cpu_m_ram_rready )
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
