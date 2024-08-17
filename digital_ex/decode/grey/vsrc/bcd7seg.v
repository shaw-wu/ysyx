module bcd7seg(b, h0, h1);
	input [4:0] b;
  output reg [6:0] h0;
  output reg [6:0] h1;
  
	integer d0, d1, i, decc, base;
	initial begin
		decc = 0;
		base = 1;
		for (i=0; i<=3; i=i+1) begin
			decc = b[i] * base;
			base *= 2;
		end
	  d0 = decc / 10;
	  d1 = decc % 10;
  end

  reg [6:0] hex0;
	reg [6:0] hex1;
	decode i0(d0[3:0], 1, hex0[6:0]);
	decode i1(d1[3:0], 1, hex1[6:0]);
	
	always @(*) begin
		if (b[4]) begin h0 = hex0; h1 = hex1; end
		else begin h0 = 7'b1111111; h1 = 7'b1111111; end
	end
endmodule
