`timescale 1ns / 1ps
module keyboard_sim(hex0,hex1,hex2,hex3);
output [6:0] hex0,hex1,hex2,hex3;
parameter [31:0] clock_period = 10;

reg clk,clrn;
wire [7:0] data;
wire ready,overflow;
wire kbd_clk, kbd_data;
reg nextdata_n;

ps2_keyboard_model model(
	.ps2_clk(kbd_clk),
	.ps2_data(kbd_data)
);

ps2_keyboard inst(
	.clk(clk),
	.clrn(clrn),
	.ps2_clk(kbd_clk),
	.ps2_data(kbd_data),
	.data(data),
	.ready(ready),
	.nextdata_n(nextdata_n),
	.overflow(overflow)
);

kbd7seg seg(
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
         8'b01000101,4'd3,4'd0 }
			 ),
  .hex0(hex0),
	.hex1(hex1),
	.hex2(hex2),
	.hex3(hex3)
);

initial begin
	clk = 0;
	forever
		#(clock_period/2) clk = ~clk;
end

initial begin
	clrn = 1'b0;  #20;
	clrn = 1'b1;  #20;
	model.kbd_sendcode(8'h1C);
	#20 nextdata_n = 1'b0; #20 nextdata_n = 1'b1;
	model.kbd_sendcode(8'hF0);
	#20 nextdata_n = 1'b0; #20 nextdata_n = 1'b1;
	model.kbd_sendcode(8'h1C);
	#20 nextdata_n = 1'b0; #20 nextdata_n = 1'b1;
	model.kbd_sendcode(8'h1B);
	#20 nextdata_n = 1'b0; #20 nextdata_n = 1'b1;
	#20 model.kbd_sendcode(8'h1B);
	#20 model.kbd_sendcode(8'h1B);
	model.kbd_sendcode(8'hF0);
	model.kbd_sendcode(8'h1B);
	#20;
	//$stop;

end

endmodule
