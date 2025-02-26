module ysyx_25010009_Host2Guest #(XLEN = 32, MBASE = 32'h80000000, PMEM = 32'b0) (
	input [XLEN-1:0] haddr,
	output reg [XLEN-1:0] paddr
);

reg [XLEN-1:0] addr;
assign addr = haddr - PMEM + MBASE;
always @(*) begin
	paddr = addr;
end

endmodule
