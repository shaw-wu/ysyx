module mux2_1(a1, a0, s, result);
	input a1, a0;
	input s;
	output result;

	assign result = (a1 & s) | (a0 & ~s);
endmodule;

module mux4_1(a3, a2, a1, a0, s1, s0, result);
	input a3, a2, a1, a0; 
	input s1, s0;
	output result;

	assign result = (a0 & ~s1 & ~s0) | (a3 & ~s1 &  s0) |
									(a2 &  s1 & ~s0) | (a1 &  s1 &  s0);
endmodule;

module level_0(din, a_l, l_r, shamt, dout);
	input [7:0] din;
	input shamt, a_l, l_r;
	output [7:0] dout;

	wire first;
  
	mux2_1 i0(
					.a1 (din[7]), 
					.a0 (0), 
					.s (a_l),
					.result (first));
	mux4_1 i1(
					.a3 (first) , 
					.a2 (din[7]), 
					.a1 (din[6]), 
					.a0 (din[7]), 
					.s1 (l_r), 
					.s0 (shamt),
				  .result (dout[7]));
	mux4_1 i2(
					.a3 (din[7]), 
					.a2 (din[6]), 
					.a1 (din[5]), 
					.a0 (din[6]), 
					.s1 (l_r), 
					.s0 (shamt),
				  .result (dout[6]));
	mux4_1 i3(
					.a3 (din[6]), 
					.a2 (din[5]), 
					.a1 (din[4]), 
					.a0 (din[5]), 
					.s1 (l_r), 
					.s0 (shamt),
				  .result (dout[5]));
	mux4_1 i4(
					.a3 (din[5]), 
					.a2 (din[4]), 
					.a1 (din[3]), 
					.a0 (din[4]), 
					.s1 (l_r), 
					.s0 (shamt),
				  .result (dout[4]));
	mux4_1 i5(
					.a3 (din[4]), 
					.a2 (din[3]), 
					.a1 (din[2]), 
					.a0 (din[3]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[3]));
	mux4_1 i6(
					.a3 (din[3]), 
					.a2 (din[2]), 
					.a1 (din[1]), 
					.a0 (din[2]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[2]));
	mux4_1 i7(
					.a3 (din[2]), 
					.a2 (din[1]), 
					.a1 (din[0]), 
					.a0 (din[1]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[1]));
	mux4_1 i8(
					.a3 (din[1]), 
					.a2 (din[0]), 
					.a1 (0)     , 
					.a0 (din[0]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[0]));

endmodule;

module level_1(din, a_l, l_r, shamt, dout);
	input [7:0] din;
	input shamt, a_l, l_r;
	output [7:0] dout;

	wire first;
  
	mux2_1 i0(
					.a1 (din[7]), 
					.a0 (0), 
					.s (a_l), 
					.result (first));
	mux4_1 i1(
					.a3 (first) , 
					.a2 (din[7]), 
					.a1 (din[5]), 
					.a0 (din[7]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[7]));
	mux4_1 i2(
					.a3 (first) , 
					.a2 (din[6]), 
					.a1 (din[4]), 
					.a0 (din[6]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[6]));
	mux4_1 i3(
					.a3 (din[7]), 
					.a2 (din[5]), 
					.a1 (din[3]), 
					.a0 (din[5]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[5]));
	mux4_1 i4(
					.a3 (din[6]), 
					.a2 (din[4]), 
					.a1 (din[2]), 
					.a0 (din[4]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[4]));
	mux4_1 i5(
					.a3 (din[5]), 
					.a2 (din[3]), 
					.a1 (din[1]), 
					.a0 (din[3]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[3]));
	mux4_1 i6(
					.a3 (din[4]), 
					.a2 (din[2]), 
					.a1 (din[0]), 
					.a0 (din[2]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[2]));
	mux4_1 i7(
					.a3 (din[3]), 
					.a2 (din[1]), 
					.a1 (0)     , 
					.a0 (din[1]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[1]));
	mux4_1 i8(
					.a3 (din[2]), 
					.a2 (din[0]), 
					.a1 (0)     , 
					.a0 (din[0]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[0]));

endmodule;

module level_2(din, a_l, l_r, shamt, dout);
	input [7:0] din;
	input shamt, a_l, l_r;
	output [7:0] dout;

	wire first;
  
	mux2_1 i0(
					.a1 (din[7]), 
					.a0 (0), 
					.s (a_l), 
					.result (first));
	mux4_1 i1(
					.a3 (first) , 
					.a2 (din[7]), 
					.a1 (din[5]), 
					.a0 (din[7]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[7]));
	mux4_1 i2(
					.a3 (first) , 
					.a2 (din[6]), 
					.a1 (din[4]), 
					.a0 (din[6]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[6]));
	mux4_1 i3(
					.a3 (first) , 
					.a2 (din[5]), 
					.a1 (din[3]), 
					.a0 (din[5]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[5]));
	mux4_1 i4(
					.a3 (first) , 
					.a2 (din[4]), 
					.a1 (din[2]), 
					.a0 (din[4]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[4]));
	mux4_1 i5(
					.a3 (din[7]), 
					.a2 (din[3]), 
					.a1 (0)     , 
					.a0 (din[3]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[3]));
	mux4_1 i6(
					.a3 (din[6]), 
					.a2 (din[2]), 
					.a1 (0)     , 
					.a0 (din[2]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[2]));
	mux4_1 i7(
					.a3 (din[5]), 
					.a2 (din[1]), 
					.a1 (0)     , 
					.a0 (din[1]), 
					.s1 (l_r), 
					.s0 (shamt),
					.result (dout[1]));
	mux4_1 i8(
					.a3 (din[4]), 
					.a2 (din[0]), 
					.a1 (0)     , 
					.a0 (din[0]), 
					.s1 (l_r), 
					.s0 (shamt),
				  .result (dout[0]));

endmodule;

module top(din, a_l, l_r, shamt, dout);
	input [7:0] din;
	input [2:0] shamt;
	input a_l, l_r;
	output [7:0] dout;

	wire [7:0] dout_0;
	wire [7:0] dout_1;
	level_0 i0(din   , a_l, l_r, shamt[0], dout_0);
	level_1 i1(dout_0, a_l, l_r, shamt[1], dout_1);
	level_2 i2(dout_1, a_l, l_r, shamt[2], dout  );
endmodule;
