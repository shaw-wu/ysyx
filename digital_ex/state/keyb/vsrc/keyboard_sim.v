`timescale 1ns / 1ps
module keyboard_sim;

/* parameter */
parameter [31:0] clock_period = 10;

/* ps2_keyboard interface signals */
reg clk,clrn;
wire [7:0] data;
wire ready,overflow;
wire kbd_clk, kbd_data;
wire pro_nextdata_n;
wire [6:0] deal_hex0;
wire [6:0] deal_hex1;
wire [6:0] deal_hex2;
wire [6:0] deal_hex3;
wire [6:0] deal_hex4;
wire [6:0] deal_hex5;
reg nextdata_n;
reg [6:0] hex0;
reg [6:0] hex1;
reg [6:0] hex2;
reg [6:0] hex3;
reg [6:0] hex4;
reg [6:0] hex5;
reg wshift;
reg wctrl;

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

deal pro(
	.clk(clk),
	.rstn(clrn),
	.overflow(overflow),
	.ready(ready),
	.data(data),
	.nextdata_n(pro_nextdata_n),
	.hex0(deal_hex0),
	.hex1(deal_hex1),
	.hex2(deal_hex2),
	.hex3(deal_hex3),
	.hex4(deal_hex4),
	.hex5(deal_hex5),
	.wshift(wshift),
	.wctrl(wctrl)
);

assign hex0 = deal_hex0;
assign hex1 = deal_hex1;
assign hex2 = deal_hex2;
assign hex3 = deal_hex3;
assign hex4 = deal_hex4;
assign hex5 = deal_hex5;

assign nextdata_n = pro_nextdata_n;

initial begin /* clock driver */
    clk = 0;
    forever
        #(clock_period/2) clk = ~clk;
end

initial begin
		$monitor("data = %b, ready = %b, nextdata_n = %b, overflow = %b, \nhex0= %b, hex1 = %b, hex2 = %b, hex3 = %b, hex4 = %b, hex5 = %b, wshift = %b, wctrl = %b", data, ready, nextdata_n, overflow, hex0, hex1, hex2, hex3, hex4, hex5, wshift, wctrl);
    clrn = 1'b0;  #20;
    clrn = 1'b1;  #20;
    model.kbd_sendcode(8'h1C); // press 'A'
    //#20 nextdata_n =1'b0; #20 nextdata_n =1'b1;//read data
    model.kbd_sendcode(8'hF0); // break code
    //#20 nextdata_n =1'b0; #20 nextdata_n =1'b1; //read data
    model.kbd_sendcode(8'h1C); // release 'A'
		#100
    //#20 nextdata_n =1'b0; #20 nextdata_n =1'b1; //read data
    model.kbd_sendcode(8'h1B); // press 'S'
    //#20 model.kbd_sendcode(8'h1B); // keep pressing 'S'
    //#20 model.kbd_sendcode(8'h1B); // keep pressing 'S'
    model.kbd_sendcode(8'hF0); // break code
    model.kbd_sendcode(8'h1B); // release 'S'
    #100;
    $stop;
end

endmodule
