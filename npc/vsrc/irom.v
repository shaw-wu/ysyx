`timescale 1ns / 1ps
module ysyx_25010009_irom #(
	parameter XLEN = 32
)(
	input  reqvalid,
	output resvalid,
	input							clk	,
	input							rst	,
	input  [XLEN-1:0] addr,
	output [XLEN-1:0] inst 
);

import "DPI-C" function int unsigned vaddr_ifetch(int unsigned addr, int len, int ren);

reg [XLEN-1:0] rdata;
reg	reg_resvalid;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		reg_resvalid <= 0;
	end else begin
		if(reqvalid) rdata <= vaddr_ifetch(addr, 4, {31'b0, !rst});
		reg_resvalid <= reqvalid;
	end
end

assign inst = rdata;
assign resvalid = reg_resvalid;

endmodule
