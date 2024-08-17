module unitadd (a, b, c_in, s);
	input a,b,c_in;
	output s;

	assign s = (a ^ b) ^ c_in;
endmodule

module unitc (a, b, c_in, c_out);
	input a,b,c_in;
	output c_out;

	assign c_out = (a & b) | ((a ^ b) & c_in);
endmodule

module add_4b (a, b, s, c_out);
	input [3:0] a;
  input [3:0] b;
  output [3:0] s;
	output c_out;

	wire [2:0] c_i;

	unitc i1 (a[0], b[0], 0,      c_i[0]);
	unitc i2 (a[1], b[1], c_i[0], c_i[1]);
	unitc i3 (a[2], b[2], c_i[1], c_i[2]);
	unitc i4 (a[3], b[3], c_i[2], c_out);
	unitadd i5 (a[0], b[0], 0,      s[0]);
	unitadd i6 (a[1], b[1], c_i[0], s[1]);
	unitadd i7 (a[2], b[2], c_i[1], s[2]);
	unitadd i8 (a[3], b[3], c_i[2], s[3]);

endmodule

	

