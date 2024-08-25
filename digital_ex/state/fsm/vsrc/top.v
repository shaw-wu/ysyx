module top
(
	input clk, in, reset,
	output reg out
);

parameter[3:0] s0 = 0, s1 = 1, s2 = 2, s3 = 3, s4 = 4, s5 = 5, s6 = 6, s7 = 7, s8 = 8;

wire [3:0] state_din, state_dout;
wire state_wen;

SimReg#(4, 0) state(clk, reset, state_din, state_dout, state_wen);

assign state_wen = 1;

MuxKeyWithDefault#(9, 4, 1) outMux(.out(out), .key(state_dout), .default_out(0), .lut({
	s0, 1'b0,
	s1, 1'b0,
	s2, 1'b0,
	s3, 1'b0,
	s4, 1'b1,
	s5, 1'b0,
	s6, 1'b0,
	s7, 1'b0,
	s8, 1'b1
}));

MuxKeyWithDefault#(9, 4, 4) stateMux(.out(state_din), .key(state_dout), .default_out(s0), .lut({
	s0, in ? s5 : s1,
	s1, in ? s5 : s2,
	s2, in ? s5 : s3,
	s3, in ? s5 : s4,
	s4, in ? s5 : s4,
	s5, in ? s6 : s1,
	s6, in ? s7 : s1,
	s7, in ? s8 : s1,
	s8, in ? s8 : s1
}));

endmodule
