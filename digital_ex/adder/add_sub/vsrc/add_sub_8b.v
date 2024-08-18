module complement (a, a_c);
	input [7:0] a;
	output [7:0] a_c;

	wire [6:0] t_no_a;
	wire [6:0] tmp_a;
	assign tmp_a = a[6:0];
	assign t_no_a = {7{a[7]}} ^ tmp_a;
	assign a_c = {a[7],t_no_a}; 
endmodule

module add_sub_8b (a, b, s_or_a, carry, zero, overflow, result);
	input [7:0] a;
  input [7:0] b;
	input s_or_a;
  output [7:0] result;
	output carry,zero,overflow;

	wire [7:0] a_c;
	wire [7:0] b_c; 
	wire [7:0] t_no_Cin;
	complement i0(a[7:0], a_c[7:0]);
	complement i1(b[7:0], b_c[7:0]);
	assign t_no_Cin = {8{s_or_a}} ^ b;
	assign {carry, result} = a + t_no_Cin + {7'b0000000,s_or_a};
	assign overflow = (a[7] == b[7]) && (a[7] != result[7]);
  assign zero = ~(| result);

endmodule

	

