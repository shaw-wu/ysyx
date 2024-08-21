module Dflip(in, clk, Q);
	input in;
	input clk;
	output reg Q;

	always @(posedge clk)
		Q = in;
endmodule;

module sr_4b(in, clk, Q);
	input in;
	input clk;
	output reg [3:0] Q;

	Dflip i0(in  , clk, Q[3]);
	Dflip i1(Q[3], clk, Q[2]);
	Dflip i2(Q[2], clk, Q[1]);
	Dflip i3(Q[1], clk, Q[0]);

endmodule;
