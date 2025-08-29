`timescale 1ns / 1ps
module ysyx_25010009_Pretree #(
	parameter STAGE = 1
)(
	input [31:0] Gin,
	input [31:0] Pin,
	output [31:0] Gout,
	output [31:0] Pout
);

genvar i;
generate
	for(i = 0; i < 32; i = i + 1) begin : _bit
		if(i < (1 << (STAGE - 1))) begin : low
			assign Gout[i] = Gin[i];
			assign Pout[i] = Pin[i];
		end else begin : high
			assign Gout[i] = Gin[i] | (Pin[i] & Gin[i - (1 << (STAGE - 1))]);
			assign Pout[i] = Pin[i] &  Pin[i - (1 << (STAGE - 1))];
		end
	end
endgenerate

endmodule

