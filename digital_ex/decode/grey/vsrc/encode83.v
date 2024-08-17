module grey(x, en, y, HEXseg0, HEXseg1);
	input [3:0] x;
	input en;
	output reg [4:0] y;
	output reg [6:0] HEXseg0;
	output reg [6:0] HEXseg1;

	integer i;

	always @(x or en) begin
		if (en) begin
			y[3] = x[3];
			for (i=2; i>=0; i-=1) y[i] = y[i+1] | x[i];
			y[4] = 1;			
	  end
		else y[4] = 0;
	end

  bcd7seg seg0(y[4:0], HEXseg0[6:0], HEXseg1[6:0]);
endmodule
