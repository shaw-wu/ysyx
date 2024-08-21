module lfsr_8b(in, clk, s, Q);
	input [7:0] in;
	input clk;
	input s;
	output reg [7:0] Q;

	reg g;

	always @(posedge clk or s) begin
			if (s) Q = in;
			else begin
			  g = Q[4] ^ Q[3] ^ Q[2] ^ Q[0];
				Q = {g, Q[7:1]};
			end
		end
endmodule
