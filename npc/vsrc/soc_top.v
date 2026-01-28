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
