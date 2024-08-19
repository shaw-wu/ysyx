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
	assign overflow = (a_c[3] == b_c[3]) && (a_c[3] != result[3]);
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

	always_latch
	begin
		case(o)
			3'b000 : begin
				s = t_a;
				carry = carry_a;
				zero = zero_a; 
				overflow = overflow_a;
			end
			3'b001 : begin
				s = t_s;
				carry = carry_s;
				zero = zero_s;
				overflow = overflow_s;
			end
			3'b010 : s = s_not;
			3'b011 : s = s_and;
			3'b100 : s = s_or;
			3'b101 : s = s_xor;
			3'b110 : out = out_c;
			3'b111 : out = out_e;
			default : begin
				s = 4'b1111;
				carry = 1;
				zero = 1;
				overflow = 1;
				out = 1;
			end
		endcase
	end
endmodule
