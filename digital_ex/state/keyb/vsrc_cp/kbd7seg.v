`timescale 1ns / 1ps
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
/*
always @(posedge clk) begin
	integer i;
	if (data!=0) begin $display("data_seg1 : %h",data);end
	for(i=0; i<36; i=i+1)begin
		lut_array[i] = lut[16*i+:16];
	end
end
*/
reg [7:0] ascii_code;
always @(posedge clk) begin
	integer i;
	//if (data!=0) begin $display("data_seg1 : %h",data);end
	for(i=0; i<36; i=i+1)begin
		lut_array[i] = lut[16*i+:16];
	end
	ascii_code = 8'b000_0000;
	for (i=0; i<36; i=i+1) begin
		if(data == lut_array[i][15:8])begin
			ascii_code = lut_array[i][7:0];
		//$display("ascii_code : %h, data : %h",ascii_code,data);
			break;
		end
	end
end

decode i1 (
	.clk(clk),
	.x(ascii_code[7:4]), 
	.en(1), 
	.y(hex3)
);
decode i2 (
	.clk(clk),
	.x(ascii_code[3:0]), 
	.en(1),
 	.y(hex2)
);
decode i3 (
	.clk(clk),
	.x(data[7:4]), 
	.en(1), 
	.y(hex1)
);
decode i4 (
	.clk(clk),
	.x(data[3:0]), 
	.en(1), 
	.y(hex0)
);

endmodule
