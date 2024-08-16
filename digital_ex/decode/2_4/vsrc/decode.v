module decode(x, e, y);
	input [1:0] x;
	input e;
	output [3:0] y;

	assign y[0] = ~x[0] & ~x[1] & e;
	assign y[1] = ~x[0] &  x[1] & e;
	assign y[2] =  x[0] & ~x[1] & e;
	assign y[3] =  x[0] &  x[1] & e;
endmodule
