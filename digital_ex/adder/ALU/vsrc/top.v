module complement (a, a_c);
	input [3:0] a;
	output [3:0] a_c;

	wire [3:0] t_no_a;
	assign t_no_a = {a[3], {3{a[3]}} ^ a[2:0]};
	assign a_c = t_no_a + {3'b000,a[3]}; 
endmodule

module add_sub_4b (a, b, s_or_a, carry, zero, overflow, result);
	input [3:0] a;
  input [3:0] b;
	input s_or_a;
  output [3:0] result;
	output carry,zero,overflow;

	wire [3:0] a_c;
	wire [3:0] b_c; 
	wire [3:0] t_no_Cin;
	wire [3:0] t_result;
	complement i0(a[3:0], a_c[3:0]);
	complement i1(b[3:0], b_c[3:0]);
	complement i2(t_result[3:0], result[3:0]);
	assign t_no_Cin = {4{s_or_a}} ^ b_c;
	assign {carry, t_result} = a_c + t_no_Cin + {3'b000,s_or_a};
	assign overflow = (a_c[3] == t_no_Cin[3]) && (a_c[3] != t_result[3]);
  assign zero = ~(| t_result);

endmodule

module and_4b(a, b, s);
	input [3:0] a;
  input	[3:0] b;
	output [3:0] s;

	assign s = a & b;
endmodule
	
module or_4b(a, b, s);
	input [3:0] a;
  input	[3:0] b;
	output [3:0] s;

	assign s = a | b;
endmodule

module xor_4b(a, b, s);
	input [3:0] a;
  input	[3:0] b;
	output [3:0] s;

	assign s = a ^ b;
endmodule
	
module not_4b(a, s);
		input [3:0] a;
		output [3:0] s;
		
		assign s = a ^ 4'b1111;
endmodule

module top(a, b, o, s, out, carry, zero, overflow);
	input [3:0] a;
  input	[3:0] b;
	input [2:0] o;
	output reg [3:0] s;
  output reg carry,zero,overflow;
	output reg out;
	
	wire [3:0] t_a;
	wire [3:0] t_s;
	wire carry_a,zero_a,overflow_a;
	wire carry_s,zero_s,overflow_s;
	wire [3:0] s_not;
	wire [3:0] s_and;
	wire [3:0] s_or;
	wire [3:0] s_xor;
	wire out_c;
	wire out_e;
  add_sub_4b i0 (a[3:0], b[3:0], 0, carry_a, zero_a, overflow_a, t_a[3:0]);  
  add_sub_4b i1 (a[3:0], b[3:0], 0, carry_s, zero_s, overflow_s, t_s[3:0]); 
  not_4b i2 (a[3:0], s_not[3:0]);
	and_4b i3 (a[3:0], b[3:0], s_and[3:0]);
	or_4b i4 (a[3:0], b[3:0], s_or[3:0]);
	xor_4b i5 (a[3:0], b[3:0], s_xor[3:0]);
  assign out_c = a[3] ^ carry_s;
	assign out_e = zero_s;
  
	assign carry = ~(o[2] | o[1]) & ((carry_a | o[0]) & (carry_s | ~o[0]));
	assign zero = ~(o[2] | o[1]) & ((zero_a | o[0]) & (zero_s | ~o[0]));
	assign overflow = ~(o[2] | o[1]) & ((overflow_a | o[0]) & (overflow_s | ~o[0]));
  assign out = (o[2] & o[1]) & ((out_c | o[0]) & (out_e | ~o[0]));
  assign s = 	({4{~o[2] & ~o[1] & ~o[0]}} & t_a) + 
		({4{~o[2] & ~o[1] &  o[0]}} & t_s) +
    ({4{~o[2] &  o[1] & ~o[0]}} & s_not) +
    ({4{~o[2] &  o[1] &  o[0]}} & s_and) +
    ({4{ o[2] & ~o[1] & ~o[0]}} & s_or) +
    ({4{ o[2] & ~o[1] &  o[0]}} & s_xor);
  
endmodule
