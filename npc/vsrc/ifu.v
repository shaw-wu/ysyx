module ysyx_25010009_ifu #(XLEN = 32, MBASE = 32'h80000000, PMEN = 32'b0) (
	input clk,
	input rst.
	input [XLEN-1:0] pc,
	input [XLEN-1:0] data,
	output [XLEN-1:0] haddr,
	output [XLEN-1:0] inst,
	input en
);

reg [XLEN-1:0] _haddr;
reg [XLEN-1:0] _inst;

ysyx_25010009_Reg #(XLEN, 32'h00000000) i0 (
	.clk(clk),
	.rst(rst),
	.din(data),
	.dout(_inst),
	.wen(en)
);
ysyx_25010009_Guest2Host #(XLEN, MBASE, PMEM) s0 (
	.paddr(pc),
  .haddr(_haddr)
);

assign haddr = _haddr;
assign inst = _inst;

endmodule
