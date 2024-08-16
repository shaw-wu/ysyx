module decode(x, en, y);
	input [2:0] x;
	input en;
	output reg [6:0] y;

	always @(x or en) begin
		if (en) begin
			case (x)
			  3'b000 : y = 7'b0000000;
			  3'b001 : y = 7'b1111001;
			  3'b010 : y = 7'b0100100;
			  3'b011 : y = 7'b0110000;
			  3'b100 : y = 7'b0011001;
			  3'b101 : y = 7'b0010010;
			  3'b110 : y = 7'b0000010;
			  3'b111 : y = 7'b1111000;
				default : y = 7'b1111111;
			endcase
		end	
		else y = 7'b1111111;
	end
endmodule

