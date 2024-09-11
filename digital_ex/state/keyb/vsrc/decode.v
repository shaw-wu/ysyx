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
endmodule;

module kbd7seg
( input clk,
	input [7:0] data,
	input [16*36-1:0] lut,
	output reg [6:0] hex0,
	output reg [6:0] hex1,
	output reg [6:0] hex2,
	output reg [6:0] hex3
);

reg [15:0] lut_array [0:35];

always @(posedge clk) begin
	integer i;
	for(i=0; i<36; i=i+1)begin
		lut_array[i] = lut[16*i+:16];
	end
end

reg [7:0] ascii_code;
always @(posedge clk) begin
	integer i;
		$display("data : %h",data);
	ascii_code = 8'b0000_0000;
	for (i=0; i<36; i=i+1) begin
		if(data == lut_array[i][15:8])begin
			ascii_code = lut_array[i][7:0];
		$display("ascii_code : %h, data : %h",ascii_code,data);
			break;
		end
	end
end

decode i1 (ascii_code[7:4], 1, hex3);
decode i2 (ascii_code[3:0], 1, hex2);
decode i3 (data[7:4]      , 1, hex1);
decode i4 (data[3:0]      , 1, hex0);

endmodule
