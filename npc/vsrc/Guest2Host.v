module ysyx_25010009_Guest2Host #(XLEN = 32, MBASE = 32'h80000000, PMEM = 32'b0) (
	input [XLEN-1:0] paddr,
	output reg [XLEN-1:0] haddr
);

reg [XLEN-1:0] addr;
assign addr = PMEM + paddr - MBASE;
always @(*) begin
	haddr = addr;
end

endmodule
