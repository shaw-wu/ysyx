module ysyx_25010009_RegisterFile #(ADDR_WIDTH = 1, DATA_WIDTH = 1) (
	input clk,
	input [DATA_WIDTH-1:0] wdata,
	input [ADDR_WIDTH-1:0] waddr,
	output reg [DATA_WIDTH-1:0] rdata,
	input [ADDR_WIDTH-1:0] raddr,
	input wen,
	input ren
);

reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];
always @(posedge clk) begin
	if (wen) rf[waddr] <= wdata;
end

Reg #(DATA_WIDTH, {DATA_WIDTH{0}}) i0 (
	.clk(clk),
	.rst(1'b0),
	.din(rf[raddr]),
	.dout(rdata),
	.wen(ren)
);

always @(*) begin
	rf[0] = {DATA_WDITH{0}};
end

endmodule
