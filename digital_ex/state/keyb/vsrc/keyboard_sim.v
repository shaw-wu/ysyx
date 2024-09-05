`timescale 1ns / 1ps
module keyboard_sim;

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
	$stop;
end

endmodule

