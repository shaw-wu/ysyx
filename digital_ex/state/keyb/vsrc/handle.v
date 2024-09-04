`timescale 1ns / 1ps
module handle
(
	input ps2_clk, ps2_data, clrn,
	output [6:0] hex0,hex1,hex2,hex3,
	output reg led1,led2
);
parameter period_clk = 20;
reg clk;
initial begin
	clk = 0;
	forever
		#(period_clk/2)clk = ~clk;
end	
always @(posedge ps2_clk) begin
	led1 = ~led1;
end

reg nextdata_n,ready,overflow;
reg [7:0] data_reg;
reg [7:0] data;

ps2_keyboard s1(clk, clrn, ps2_clk, ps2_data, data, ready, nextdata_n, overflow);
kbd7seg s2
( .clk(clk), .data(data_reg),.hex0(hex0),.hex1(hex1),.hex2(hex2),.hex3(hex3),
	.lut({ 8'b00010101,4'd7,4'd1,  //q 71
    8'b00011101,4'd7,4'd7 ,  //w 77
		8'b00100100,4'd6,4'd5 ,  //e 65
		8'b00101101,4'd7,4'd2 ,  //r 72
    8'b00101100,4'd7,4'd4 ,  //t 74
    8'b00110101,4'd7,4'd9 ,  //y 79
    8'b00111100,4'd7,4'd5 ,  //u 75
    8'b01000011,4'd6,4'd9 ,  //i 69
    8'b01000100,4'd6,4'd15,  //o 6f
    8'b01001101,4'd7,4'd0 ,  //p 70
    8'b00011100,4'd6,4'd1 ,  //a 61
    8'b00011011,4'd7,4'd3 ,  //s 73
    8'b00100011,4'd6,4'd4 ,  //d 64
    8'b00101011,4'd6,4'd6 ,  //f 66
    8'b00110100,4'd6,4'd7 ,  //g 67
    8'b00110011,4'd6,4'd8 ,  //h 68
    8'b00111011,4'd6,4'd10,  //j 6a
    8'b01000010,4'd6,4'd11,  //k 6b
    8'b01001011,4'd6,4'd12,  //l 6c
    8'b00011010,4'd7,4'd10,  //z 7a
    8'b00100010,4'd7,4'd8 ,  //x 78
    8'b00100001,4'd6,4'd3 ,  //c 63
    8'b00101010,4'd7,4'd6 ,  //v 96
    8'b00110010,4'd6,4'd2 ,  //b 62
    8'b00110001,4'd6,4'd14,  //n 6e
    8'b00111010,4'd6,4'd13,  //m 6d
    8'b00010110,4'd3,4'd1 ,  //1 31
    8'b00011110,4'd3,4'd2 ,  //2 32
    8'b00100110,4'd3,4'd3 ,  //3 33
    8'b00100101,4'd3,4'd4 ,  //4 34
    8'b00101110,4'd3,4'd5 ,  //5 35
    8'b00110110,4'd3,4'd6 ,  //6 36
    8'b00111101,4'd3,4'd7 ,  //7 37
    8'b00111110,4'd3,4'd8 ,  //8 38
    8'b01000110,4'd3,4'd9 ,  //9 39
    8'b01000101,4'd3,4'd0 }) //0 30
);

always @(posedge clk) begin
	if(ready == 1) begin
		nextdata_n <= 1;
		data_reg <= data;
		$display("data: %h,data_reg: %h", data, data_reg);
	end
	else begin
		nextdata_n <= 0;
	end
end
endmodule
