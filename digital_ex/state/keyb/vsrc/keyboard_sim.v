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
  .data(8'h1C),
  .lut({ 8'h15,4'd7,4'd1 ,
         8'h1D,4'd7,4'd7 ,  
         8'h24,4'd6,4'd5 ,  
         8'h2D,4'd7,4'd2 ,  
         8'h2C,4'd7,4'd4 ,  
         8'h35,4'd7,4'd9 ,  
         8'h3C,4'd7,4'd5 ,  
         8'h43,4'd6,4'd9 ,  
         8'h44,4'd6,4'd15,  
         8'h4D,4'd7,4'd0 ,  
         8'h1C,4'd6,4'd1 ,  
         8'h1B,4'd7,4'd3 ,  
         8'h23,4'd6,4'd4 ,  
         8'h2B,4'd6,4'd6 ,  
         8'h34,4'd6,4'd7 ,  
         8'h33,4'd6,4'd8 ,  
         8'h3B,4'd6,4'd10,  
         8'h42,4'd6,4'd11,  
         8'h4B,4'd6,4'd12,  
         8'h1A,4'd7,4'd10,  
         8'h22,4'd7,4'd8 ,  
         8'h21,4'd6,4'd3 ,  
         8'h2A,4'd7,4'd6 ,  
         8'h32,4'd6,4'd2 ,  
         8'h31,4'd6,4'd14,  
         8'h3A,4'd6,4'd13,  
         8'h16,4'd3,4'd1 ,  
         8'h1E,4'd3,4'd2 ,  
         8'h26,4'd3,4'd3 ,  
         8'h25,4'd3,4'd4 ,  
         8'h2E,4'd3,4'd5 ,  
         8'h36,4'd3,4'd6 ,  
         8'h3D,4'd3,4'd7 ,  
         8'h3E,4'd3,4'd8 ,  
         8'h46,4'd3,4'd9 ,  
         8'h45,4'd3,4'd0 }
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
