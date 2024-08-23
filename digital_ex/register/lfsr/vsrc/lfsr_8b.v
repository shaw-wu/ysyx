module decode(x, en, y);
	input [3:0] x;
	input en;
	output reg [6:0] y;

	always @(x or en) begin
		if(en) begin
			case(x)
				4'b0000 : y = 7'b1000000;
				4'b0001 : y = 7'b1111001;
				4'b0010 : y = 7'b0100100;
				4'b0011 : y = 7'b0110000;
				4'b0100 : y = 7'b0011001;
				4'b0101 : y = 7'b0010010;
				4'b0110 : y = 7'b0000010;
				4'b0111 : y = 7'b1111000;
				4'b1000 : y = 7'b0000000;
				4'b1001 : y = 7'b0010000;
				4'b1010 : y = 7'b0001000;
				4'b1011 : y = 7'b0000011;
				4'b1100 : y = 7'b1000110;
				4'b1101 : y = 7'b0100001;
				4'b1110 : y = 7'b0000110;
				4'b1111 : y = 7'b0001110;
				default : y = 7'b1111111;
			endcase
		end
		else y = 7'b1111111;
	end
endmodule

module lfsr_8b(in, clk, s, Q, hex0, hex1);
	input [7:0] in;
	input clk;
	input s;
	output reg [7:0] Q;
	output [6:0] hex0;
	output [6:0] hex1;

	reg g;
	decode i0(.x  (in[3:0]),
					  .en (1),
						.y  (hex0));
	decode i1(.x  (in[7:4]),
					  .en (1),
						.y  (hex1));

	always @(posedge s or  posedge clk) begin
			if (s) Q = in;
			else begin
			  g = Q[4] ^ Q[3] ^ Q[2] ^ Q[0];
				Q = {g, Q[7:1]};
			end
		end
endmodule
