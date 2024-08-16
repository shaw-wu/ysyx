module encode(x, e, y);
	input [3:0] x;
	input e;
	output [1:0] y;

	assign y[0] = (~x[0] &  x[1] & ~x[2] & ~x[3]) + (~x[0] & ~x[1] & x[2] & ~x[3]);
	assign y[1] = (~x[0] & ~x[1] & ~x[2] &  x[3]) + (~x[0] & ~x[1] & x[2] & ~x[3]);
endmodule
