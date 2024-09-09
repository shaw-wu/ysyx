`timescale 1ns / 1ps
module top(clrn,ps2_clk,ps2_data,hex0,hex1,hex2,hex3,ready,overflow,nextdata_n);
input clrn;
input ps2_clk,ps2_data;
output [6:0] hex0,hex1,hex2,hex3;
output reg ready,overflow,nextdata_n;

parameter [31:0] clk_period = 20;
reg clk = 1'b1;

initial begin
	clk = 0;
	forever begin
		#(clk_period/2) clk = ~clk;
		$display("clk : %h",clk);
	end
end

reg [7:0] data;

ps2_keyboard s1 (
	.clk(clk),
	.clrn(clrn),
	.ps2_clk(ps2_clk),
	.ps2_data(ps2_data),
	.data(data),
	.ready(ready),
	.nextdata_n(nextdata_n),
	.overflow(overflow)
);

kbd7seg s2 (
	.clk(clk),
	.data(data),
	.lut({ 8'b00010101,4'd7,4'd1 ,
         8'b00011101,4'd7,4'd7 ,  
         8'b00100100,4'd6,4'd5 ,  
         8'b00101101,4'd7,4'd2 ,  
         8'b00101100,4'd7,4'd4 ,  
         8'b00110101,4'd7,4'd9 ,  
         8'b00111100,4'd7,4'd5 ,  
         8'b01000011,4'd6,4'd9 ,  
         8'b01000100,4'd6,4'd15,  
         8'b01001101,4'd7,4'd0 ,  
         8'b00011100,4'd6,4'd1 ,  
         8'b00011011,4'd7,4'd3 ,  
         8'b00100011,4'd6,4'd4 ,  
         8'b00101011,4'd6,4'd6 ,  
         8'b00110100,4'd6,4'd7 ,  
         8'b00110011,4'd6,4'd8 ,  
         8'b00111011,4'd6,4'd10,  
         8'b01000010,4'd6,4'd11,  
         8'b01001011,4'd6,4'd12,  
         8'b00011010,4'd7,4'd10,  
         8'b00100010,4'd7,4'd8 ,  
         8'b00100001,4'd6,4'd3 ,  
         8'b00101010,4'd7,4'd6 ,  
         8'b00110010,4'd6,4'd2 ,  
         8'b00110001,4'd6,4'd14,  
         8'b00111010,4'd6,4'd13,  
         8'b00010110,4'd3,4'd1 ,  
         8'b00011110,4'd3,4'd2 ,  
         8'b00100110,4'd3,4'd3 ,  
         8'b00100101,4'd3,4'd4 ,  
         8'b00101110,4'd3,4'd5 ,  
         8'b00110110,4'd3,4'd6 ,  
         8'b00111101,4'd3,4'd7 ,  
         8'b00111110,4'd3,4'd8 ,  
         8'b01000110,4'd3,4'd9 ,  
         8'b01000101,4'd3,4'd0 }), 
	.hex0(hex0),
	.hex1(hex1),
	.hex2(hex2),
	.hex3(hex3)
);

handle s3 (
	.clk(clk),
	.ready(ready),
	.nextdata_n(nextdata_n),
	.rst_n(clrn)
);

endmodule;
