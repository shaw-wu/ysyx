`timescale 1ns / 1ps
module decoder(
	input [3:0] x,
	output reg [6:0] y
);

always @(*) begin
	case (x)
		4'h1 : y = 7'b111_1001;
		4'h2 : y = 7'b010_0100;
		4'h3 : y = 7'b011_0000;
		4'h4 : y = 7'b001_1001;
		4'h5 : y = 7'b001_0010;
		4'h6 : y = 7'b000_0010;
		4'h7 : y = 7'b111_1000;
		4'h8 : y = 7'b000_0000;
		4'h9 : y = 7'b001_0000;
		4'h0 : y = 7'b100_0000;
		4'ha : y = 7'b000_1000;
		4'hb : y = 7'b000_0011;
		4'hc : y = 7'b100_0110;
		4'hd : y = 7'b010_0001;
		4'he : y = 7'b000_0110;
		4'hf : y = 7'b000_1110;
		default : y = 7'b111_1111;
	endcase
end

endmodule
