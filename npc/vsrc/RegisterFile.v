`timescale 1ns / 1ps
module ysyx_25010009_RegisterFile #(
	parameter GPR_NUM    = 16			,
	parameter CSRS_NUM   = 4096		,
	parameter ADDR_WIDTH = 5			, 
	parameter CAR_WIDTH  = 12			, 
	parameter DATA_WIDTH = 32			,
	parameter MSTATUS		 = 12'h300,
	parameter MTVEC			 = 12'h305,
	parameter MEPC			 = 12'h341,
	parameter MCAUSE		 = 12'h342,
	parameter MCYCLE		 = 12'hb00,
	parameter MCYCLEH		 = 12'hb01,
	parameter MVENDORID  = 12'hf11,
	parameter MARCHID    = 12'hf12
)(
	input clk,
	input rst,
	input [DATA_WIDTH-1:0] gpr_wdata,
	input [ADDR_WIDTH-1:0] gpr_waddr,
	input [ADDR_WIDTH-1:0] gpr_raddr1,
	input [ADDR_WIDTH-1:0] gpr_raddr2,
	output [DATA_WIDTH-1:0] gpr_rdata1,
	output [DATA_WIDTH-1:0] gpr_rdata2,
	input gpr_wen,
	input [DATA_WIDTH-1:0] csrs_wdata1,
	input [CAR_WIDTH -1:0] csrs_waddr1,
	input [DATA_WIDTH-1:0] csrs_wdata2,
	input [CAR_WIDTH -1:0] csrs_waddr2,
	output [DATA_WIDTH-1:0] csrs_rdata,
	input  [CAR_WIDTH -1:0]  csrs_raddr,
	input csrs_wen1,
	input csrs_wen2,
	output [DATA_WIDTH-1:0] mepc,
	output [DATA_WIDTH-1:0] mtvec
);

reg [DATA_WIDTH-1:0] rf [0:GPR_NUM-1];
reg [DATA_WIDTH-1:0] csrs [0:CSRS_NUM-1];

always @(posedge clk or posedge rst) begin
	if(rst) begin
		integer i;
		for(i = 0; i < GPR_NUM; i=i+1) begin
			rf[i] = {DATA_WIDTH{1'b0}};
		end
		for(i = 0; i < CSRS_NUM; i=i+1) begin
			if		 (i == {20'd0, MVENDORID}) csrs[i] = 'h79737978				;
			else if(i == {20'd0, MARCHID	}) csrs[i] = 'h17d9f59 				;
			else										csrs[i] = {DATA_WIDTH{1'b0}};
		end
	end else begin
		csrs[MCYCLE ] <= csrs[MCYCLE] + 1;
		csrs[MCYCLEH] <= &csrs[MCYCLE] ? csrs[MCYCLEH] + 1 : csrs[MCYCLEH];
		if (gpr_wen) begin
			if (gpr_waddr != 0) rf[gpr_waddr] <= gpr_wdata;
			else						    rf[gpr_waddr] <= 0		;
		end
		if (csrs_wen1) begin
			csrs[csrs_waddr1] <= csrs_wdata1;
		end
		if (csrs_wen2) begin
			csrs[csrs_waddr2] <= csrs_wdata2;
		end
	end
end

assign gpr_rdata1 = gpr_raddr1 == 0 ? 0 : rf[gpr_raddr1];
assign gpr_rdata2 = gpr_raddr2 == 0 ? 0 : rf[gpr_raddr2];
assign csrs_rdata = csrs[csrs_raddr];
assign mepc = csrs[MEPC];
assign mtvec = csrs[MTVEC];

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
