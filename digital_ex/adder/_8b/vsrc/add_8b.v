module add_8b (a, b, s, c_out);
	input [7:0] a;
  input [7:0] b;
  output [7:0] s;
	output c_out;

	assign {c_out, s} = a + b;
endmodule

	

