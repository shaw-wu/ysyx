module encode83(x, en, y, HEXseg);
	input [7:0] x;
	input en;
	output reg [3:0] y;
	output reg [6:0] HEXseg;

	always @(x or en) begin
		if (en) begin
			if (x == 0) y = 4'b0000;
			else begin
					casez(x)
						8'b00000001 : y = 4'b1001;
						8'b0000001? : y = 4'b1010;
						8'b000001?? : y = 4'b1011;
						8'b00001??? : y = 4'b1100;
						8'b0001???? : y = 4'b1101;
						8'b001????? : y = 4'b1110;
						8'b01?????? : y = 4'b1111;
						8'b1??????? : y = 4'b1000;
						default : y = 4'b0111;
					endcase
			end
	  end
		else y = 4'b0000;
	end

  decode i0(y[2:0], 1,HEXseg);
endmodule
