module complement (a, a_c);
	input [7:0] a;
	output [7:0] a_c;

	wire [7:0] t_no_a;
	assign t_no_a = {a[7], {7{a[7]}} ^ a[6:0]};
	assign a_c = t_no_a + {7'b0000000,a[7]}; 
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
	assign t_no_Cin = {8{s_or_a}} ^ b_c;
	assign {carry, result} = a_c + t_no_Cin + {7'b0000000,s_or_a};
	assign overflow = (a_c[7] == b_c[7]) && (a_c[7] != result[7]);
  assign zero = ~(| result);

endmodule

	

