`timescale 1ns / 1ps
module ysyx_25010009_RegisterFile #(
	parameter GPR_NUM = 16,
	parameter ADDR_WIDTH = 5, 
	parameter DATA_WIDTH = 32
)(
	input clk,
	input rst,
	input [DATA_WIDTH-1:0] wdata,
	input [ADDR_WIDTH-1:0] waddr,
	input [ADDR_WIDTH-1:0] raddr1,
	input [ADDR_WIDTH-1:0] raddr2,
	output [DATA_WIDTH-1:0] rdata1,
	output [DATA_WIDTH-1:0] rdata2,
	input wen
);

reg [DATA_WIDTH-1:0] rf [0:GPR_NUM-1];

always @(posedge clk or posedge rst) begin
	if(rst) begin
		for(integer i = 0; i < DATA_WIDTH; i=i+1) begin
			rf[i] = 32'b0;
		end
	end else begin
		if (wen) begin
			if (waddr != 0) rf[waddr] <= wdata;
			else						rf[waddr] <= 0		;
		end
	end
end

assign rdata1 = raddr1 == 0 ? 0 : rf[raddr1];
assign rdata2 = raddr2 == 0 ? 0 : rf[raddr2];

`ifdef VERILATOR
export "DPI-C" task read_gpr;
task automatic read_gpr(input int addr, output int unsigned rdata); 
begin
	if(addr == 0) rdata = 0;
	else          rdata = rf[addr];
end
endtask
`endif

endmodule
