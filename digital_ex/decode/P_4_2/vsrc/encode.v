module encode(x, en, y);
	input [3:0] x;
	input en;
	output [1:0] y;

	assign y[0] = ((~x[3] & ~x[2] & x[1]) + x[3]) & en;
	assign y[1] = ((~x[3] &  x[2]) + x[3]) & en;
endmodule
