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

wire [ADDR_WIDTH-1:0] s_ram_awaddr ;
wire [           2:0] s_ram_awsize ;
wire                  s_ram_awvalid;
wire                  s_ram_awready;
wire [DATA_WIDTH-1:0] s_ram_wdata  ;
wire [           3:0] s_ram_wstrb  ;
wire                  s_ram_wvalid ;
wire                  s_ram_wready ;
wire [           2:0] s_ram_bresp  ;
wire                  s_ram_bvalid ;
wire                  s_ram_bready ;
wire [ADDR_WIDTH-1:0] s_ram_araddr ;
wire [           2:0] s_ram_arsize ;
wire                  s_ram_arvalid;
wire                  s_ram_arready;
wire [DATA_WIDTH-1:0] s_ram_rdata  ;
wire [           2:0] s_ram_rresp  ;
wire                  s_ram_rvalid ;
wire                  s_ram_rready ;

wire                  mem_we   ;
wire                  mem_req  ;
wire                  mem_resp ;
wire [          31:0] mem_len  ;
wire [ADDR_WIDTH-1:0] mem_raddr;
wire [DATA_WIDTH-1:0] mem_rdata;
wire [ADDR_WIDTH-1:0] mem_waddr;
wire [DATA_WIDTH-1:0] mem_wdata;

wire [ADDR_WIDTH-1:0] s_uart_awaddr ;
wire [           2:0] s_uart_awsize ;
wire                  s_uart_awvalid;
wire                  s_uart_awready;
wire [DATA_WIDTH-1:0] s_uart_wdata  ;
wire [           3:0] s_uart_wstrb  ;
wire                  s_uart_wvalid ;
wire                  s_uart_wready ;
wire [           2:0] s_uart_bresp  ;
wire                  s_uart_bvalid ;
wire                  s_uart_bready ;
//wire [ADDR_WIDTH-1:0] s_uart_araddr ;
//wire [           2:0] s_uart_arsize ;
//wire                  s_uart_arvalid;
//wire                  s_uart_arready;
//wire [DATA_WIDTH-1:0] s_uart_rdata  ;
//wire [           2:0] s_uart_rresp  ;
//wire                  s_uart_rvalid ;
//wire                  s_uart_rready ;
//
//wire                  uart_we   ;
wire                  uart_req  ;
wire                  uart_resp ;
//wire [          31:0] uart_len  ;
//wire [ADDR_WIDTH-1:0] uart_raddr;
//wire [DATA_WIDTH-1:0] uart_rdata;
wire [ADDR_WIDTH-1:0] uart_waddr;
wire [DATA_WIDTH-1:0] uart_wdata;

ysyx_25010009_sram_axi_bridge #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) sram_axi_bridge (
    .aclk        (clk          ),
`ifdef VERILATOR
	.areset      (buf_rst	   ),
`else
	.areset      (rst		   ),
`endif

    .awaddr      (s_ram_awaddr ),
    .awsize      (s_ram_awsize ),
    .awvalid     (s_ram_awvalid),
    .awready     (s_ram_awready),
                  s_
    .wdata       (s_ram_wdata  ),
    .wstrb       (s_ram_wstrb  ),
    .wvalid      (s_ram_wvalid ),
    .wready      (s_ram_wready ),
                  s_
    .bresp       (s_ram_bresp  ), 
    .bvalid      (s_ram_bvalid ),
    .bready      (s_ram_bready ),
                  s_
    .araddr      (s_ram_araddr ),
    .arsize      (s_ram_arsize ),
    .arvalid     (s_ram_arvalid),    
    .arready     (s_ram_arready),
                  s_
    .rdata       (s_ram_rdata  ),
    .rresp       (s_ram_rresp  ),
    .rvalid      (s_ram_rvalid ),
    .rready      (s_ram_rready ),
                              
    .we          (mem_we       ),
    .req         (mem_req      ),
    .resp        (mem_resp     ),
    .len         (mem_len      ),
    .mem_raddr   (mem_raddr    ),
    .mem_rdata   (mem_rdata    ),
    .mem_waddr   (mem_waddr    ),
    .mem_wdata   (mem_wdata    )
);

ysyx_25010009_uart_axi_bridge #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) sram_axi_bridge (
    .aclk        (clk           ),
`ifdef VERILATOR
	.areset      (buf_rst	    ),
`else
	.areset      (rst		    ),
`endif

    .awaddr      (s_uart_awaddr ),
    .awsize      (s_uart_awsize ),
    .awvalid     (s_uart_awvalid),
    .awready     (s_uart_awready),
                  
    .wdata       (s_uart_wdata  ),
    .wstrb       (s_uart_wstrb  ),
    .wvalid      (s_uart_wvalid ),
    .wready      (s_uart_wready ),
                 
    .bresp       (s_uart_bresp  ), 
    .bvalid      (s_uart_bvalid ),
    .bready      (s_uart_bready ),
                        
//    .araddr      (cpu_m_ram_araddr ),
//    .arsize      (cpu_m_ram_arsize ),
//    .arvalid     (cpu_m_ram_arvalid),    
//    .arready     (cpu_m_ram_arready),
//                        
//    .rdata       (cpu_m_ram_rdata  ),
//    .rresp       (cpu_m_ram_rresp  ),
//    .rvalid      (cpu_m_ram_rvalid ),
//    .rready      (cpu_m_ram_rready ),
//                              
//    .we          (mem_we           ),
    .req         (uart_req      ),
    .resp        (uart_resp     ),
//    .len         (mem_len      ),
//    .mem_raddr   (mem_raddr    ),
//    .mem_rdata   (mem_rdata    ),
    .mem_waddr   (uart_waddr    ),
    .mem_wdata   (uart_wdata    )
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
	.clk              (clk          ),
`ifdef VERILATOR      
	.rst              (buf_rst	    ),
`else
	.rst              (rst		    ),
`endif
	.counter          (counter      ),
    //AXI-LIte
    .io_master_awaddr (m_cpu_awaddr ),
    .io_master_awsize (m_cpu_awsize ),
    .io_master_awvalid(m_cpu_awvalid),
    .io_master_awready(m_cpu_awready),

    .io_master_wdata  (m_cpu_wdata  ),
    .io_master_wstrb  (m_cpu_wstrb  ),
    .io_master_wvalid (m_cpu_wvalid ),
    .io_master_wready (m_cpu_wready ),

    .io_master_bresp  (m_cpu_bresp  ),
    .io_master_bvalid (m_cpu_bvalid ),
    .io_master_bready (m_cpu_bready ),

    .io_master_araddr (m_cpu_araddr ),
    .io_master_arsize (m_cpu_arsize ),
    .io_master_arvalid(m_cpu_arvalid),
    .io_master_arready(m_cpu_arready),

    .io_master_rdata  (m_cpu_rdata  ),
    .io_master_rresp  (m_cpu_rresp  ),
    .io_master_rvalid (m_cpu_rvalid ),
    .io_master_rready (m_cpu_rready )
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

ysyx_25010009_uart #(
	.XLEN(DATA_WIDTH)
) SRAM (
	.clk	  (clk	     ),
`ifdef VERILATOR
	.rst      (buf_rst	 ),
`else
	.rst      (rst		 ),
`endif
    //.we       (mem_we   ),
	.req      (uart_req  ),
	.resp     (uart_resp ),
    //.len      (mem_len  ),
	//.mem_raddr(mem_raddr),
	//.mem_rdata(mem_rdata),
	.waddr    (uart_waddr),
	.wdata    (uart_wdata)
);
endmodule
