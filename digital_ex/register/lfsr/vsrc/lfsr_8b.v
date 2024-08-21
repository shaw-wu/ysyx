module lfsr_8b(in, clk, s, Q);
	input [7:0] in;
	input clk;
	input s;
	output reg [7:0] Q;

	reg [7:0] q;
	reg g;

	always @(clk) begin
			q = (in & {8{s}}) + (Q & {8{~s}});
			g = q[4] ^ q[3] ^ q[2] ^ q[0];
			Q = {g, Q[7:1]};
		end
endmodule
