`timescale 1ns / 1ps
module ysyx_25010009_RegisterFile #(
	parameter GPR_NUM = 16,
	parameter CSR_NUM = 4096,
	parameter ADDR_WIDTH = 5, 
	parameter CAR_WIDTH = 12, 
	parameter DATA_WIDTH = 32,
	parameter MSTATUS = 12'h0300,
	parameter MTVEC	= 12'h0305,
	parameter MEPC = 12'h0341,
	parameter MCAUSE = 12'h0342
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
	input  [CAR_WIDTH -1:0] csrs_raddr,
	input csrs_wen1,
	input csrs_wen2,
	output [DATA_WIDTH-1:0] rf_mepc,
	output [DATA_WIDTH-1:0] rf_mtvec
);

reg [DATA_WIDTH-1:0] rf [0:GPR_NUM-1];
reg [DATA_WIDTH-1:0] csrs ;
reg [DATA_WIDTH-1:0] mstatus;
reg [DATA_WIDTH-1:0] mtvec;
reg [DATA_WIDTH-1:0] mepc;
reg [DATA_WIDTH-1:0] mcause;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		integer i;
		for(i = 0; i < GPR_NUM; i=i+1) begin
			rf[i] <= {DATA_WIDTH{1'b0}};
		end
		mstatus <= 0;
		mtvec   <= 0;
		mepc		<= 0;
		mcause  <= 0;
		//for(i = 0; i < CSR_NUM; i=i+1) begin
		//	csrs[i] = {DATA_WIDTH{1'b0}};
		//end
	end else begin
		if (gpr_wen) begin
			if (gpr_waddr != 0) rf[gpr_waddr] <= gpr_wdata;
			else						    rf[gpr_waddr] <= 0		;
		end
		if (csrs_wen1) begin
			//csrs[csrs_waddr1] <= csrs_wdata1;
			case(csrs_waddr1)
				MEPC		: mepc		<= csrs_wdata1;
				MTVEC		: mtvec		<= csrs_wdata1;
				MSTATUS : mstatus <= csrs_wdata1;
				MCAUSE  : mcause  <= csrs_wdata1;
				default : csrs <= 0;
			endcase
		end
		if (csrs_wen2) begin
			//csrs[csrs_waddr2] <= csrs_wdata2;
			case(csrs_waddr2)
				MEPC		: mepc		<= csrs_wdata2;
				MTVEC		: mtvec		<= csrs_wdata2;
				MSTATUS : mstatus <= csrs_wdata2;
				MCAUSE  : mcause  <= csrs_wdata2;
				default : csrs <= 0;
			endcase
		end
	end
end

assign gpr_rdata1 = gpr_raddr1 == 0 ? 0 : rf[gpr_raddr1];
assign gpr_rdata2 = gpr_raddr2 == 0 ? 0 : rf[gpr_raddr2];
assign csrs_rdata = csrs_raddr == MEPC    ? mepc    :
										csrs_raddr == MCAUSE  ? mcause  :
										csrs_raddr == MSTATUS ? mstatus :
										csrs_raddr == MTVEC   ? mtvec   : 0;
assign rf_mepc = mepc;
assign rf_mtvec = mtvec; 

`ifdef VERILATOR
export "DPI-C" task read_gpr;
task automatic read_gpr(input int addr, output int unsigned rdata); 
begin
	if(addr == 0) rdata = 0;
	else if((addr[4:0] == gpr_waddr) && gpr_wen) rdata = gpr_wdata;
	else rdata = rf[addr];
end
endtask
`endif

endmodule
