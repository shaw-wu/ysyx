module my_and(a,b,c);
  input  a,b;
  output c;

  assign c = a & b;
endmodule

module my_or(a,b,c);
  input  a,b;
  output c;

  assign c = a | b;
endmodule

module my_not(a,b);
  input  a;
  output b;

  assign b = ~a;
endmodule

module mux21(a,b,s,y);
  input  a,b,s;
  output y;

  wire l, r, s_n; // 内部网线声明
  my_not i1(.a(s), .b(s_n));        // 实例化非门，实现~s
  my_and i2(.a(s_n), .b(a), .c(l)); // 实例化与门，实现(~s&a)
  my_and i3(.a(s),   .b(b), .c(r)); // 实例化与门，实现(s&b)
  my_or  i4(.a(l),   .b(r), .c(y)); // 实例化或门，实现(~s&a)|(s&b)
endmodule

module mux41(a0,a1,a2,a3,s0,s1,y);
	input a0,a1,a2,a3;
	input s0,s1;
	output y;

	wire l, r, r, s0_n, s_or0, s_or1;
  mux21 i1(.a(a0), .b(a1), .s(s1), .y(l));	
  mux21 i2(.a(a2), .b(a3), .s(s1), .y(r));
	my_not i3(.a(s0), .b(s0_n));
	my_or i4(.a(l), .b(s0),   .c(s_or0));
	my_or i5(.a(r), .b(s0_n), .c(s_or1));
	my_and i6(.a(s_or0), .b(s_or1), .c(y));
endmodule
