`timescale 1ns / 1ps
module top(
	input clk,
	input rstn,
	input ps2_clk,
	input ps2_data,
	output wire ready,
	output wire overflow,
	output wire nextdata_n,
	output reg [6:0] hex0,
	output reg [6:0] hex1,
	output reg [6:0] hex2,
	output reg [6:0] hex3,
	output reg [6:0] hex4,
	output reg [6:0] hex5,
	output reg wshift,
	output reg wctrl
);

wire [7:0] kbd_data;
wire [6:0] deal_hex0;
wire [6:0] deal_hex1;
wire [6:0] deal_hex2;
wire [6:0] deal_hex3;
wire [6:0] deal_hex4;
wire [6:0] deal_hex5;
reg [7:0] data;

assign hex0 = deal_hex0; 
assign hex1 = deal_hex1; 
assign hex2 = deal_hex3; 
assign hex3 = deal_hex2; 
assign hex4 = deal_hex4; 
assign hex5 = deal_hex5; 
assign data = kbd_data; 

ps2_keyboard inst(
    .clk(clk),
    .clrn(rstn),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .data(kbd_data),
    .ready(ready),
    .nextdata_n(nextdata_n),
    .overflow(overflow)
);

deal pro(
	.clk(clk),
	.rstn(rstn),
	.overflow(overflow),
	.ready(ready),
	.data(data),
	.nextdata_n(nextdata_n),
	.hex0(deal_hex0),
	.hex1(deal_hex1),
	.hex2(deal_hex2),
	.hex3(deal_hex3),
	.hex4(deal_hex4),
	.hex5(deal_hex5),
	.wshift(wshift),
	.wctrl(wctrl)
);

endmodule
