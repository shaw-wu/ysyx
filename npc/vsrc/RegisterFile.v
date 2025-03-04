module ysyx_25010009_RegisterFile #(ADDR_WIDTH = 1, DATA_WIDTH = 1) (
	input clk,
	input rst,
	input [DATA_WIDTH-1:0] wdata,
	input [ADDR_WIDTH-1:0] waddr,
	output [DATA_WIDTH-1:0] rdata,
	input [ADDR_WIDTH-1:0] raddr,
	input wen,
	input ren,
);

reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];
reg [DATA_WIDTH-1:0] _rdata;

always @(posedge clk) begin
	if (wen) rf[waddr] <= wdata;
	else if(ren) _rdata <= rf[raddr];
end

assign rdata = _rdata;

always @(*) begin
	rf[0] = {DATA_WDITH{0}};
end

endmodule
