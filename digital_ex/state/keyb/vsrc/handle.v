`timescale 1ns / 1ps
module handle
(
	//input ps2_clk, ps2_data,
	output [6:0] hex0,hex1,hex2,hex3
);
parameter [31:0] clk_period = 10;
wire ps2_clk, ps2_data;
reg clk;

initial begin
	clk = 0;
	forever
		#(clk_period/2) clk = ~clk;
end

reg clrn,nextdata_n,ready,overflow;
reg [7:0] data;
initial begin
	overflow = 1;
	ready = 1;
end

ps2_keyboard i1(clk, clrn, ps2_clk, ps2_data, data, ready, nextdata_n, overflow);
ps2_keyboard_model model(ps2_clk,ps2_data);
kbd7seg i2(data,hex0,hex1,hex2,hex3);

always @(posedge clk) begin
	#100
	clrn = ~overflow;
	nextdata_n <= ~(clrn & ready);
end

initial begin
	model.kbd_sendcode(8'h1C);
	model.kbd_sendcode(8'h1B);
end

endmodule
