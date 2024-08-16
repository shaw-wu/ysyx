module bcd7seg(
	input [3:0] b,
  output reg [6:0] h
);

  reg [6:0] dec;
	decode i0(b[2:0], 1, dec[6:0]);
  always @(b[3])
			h = dec;
endmodule
