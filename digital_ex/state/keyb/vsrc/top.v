module top(
	input clk,
	input clrn,
	input ps2_clk,
	input ps2_data,
	output reg [6:0] hex0,
	output reg [6:0] hex1,
	output reg [6:0] hex2,
	output reg [6:0] hex3,
	output reg [6:0] hex4,
	output reg [6:0] hex5,
	output reg ready,
	output reg overflow,
	output reg nextdata_n,
	output reg sampling
);

reg [7:0] data;
reg break_code;
reg [6:0] hex0In,hex1In,hex2In,hex3In;
reg [7:0] count;


always @(posedge break_code) begin
		count <= count + 1;
		$display("count : %h",count);
end


ps2_keyboard kbd (
	.clk(clk),
	.clrn(clrn),
	.ps2_clk(ps2_clk),
	.ps2_data(ps2_data),
	.data(data),
	.ready(ready),
	.nextdata_n(nextdata_n),
	.overflow(overflow),
	.sampling(sampling),
	.break_code(break_code)
);

kbd7seg seg (
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
	.hex0(hex0In),
	.hex1(hex1In),
	.hex2(hex2In),
	.hex3(hex3In)
);

count7seg countSeg(
	.clk(clk),
	.count(count),
	.hex0(hex4),
	.hex1(hex5)
);
handle_hex hdl_h0(
  .clk(clk),
	.cond(break_code),
	.hex_in(hex0In),
	.hex_out(hex0)
);
handle_hex hdl_h1(
	.clk(clk),
	.cond(break_code),
	.hex_in(hex1In),
	.hex_out(hex1)
);
handle_hex hdl_h2(
	.clk(clk),
	.cond(break_code),
	.hex_in(hex2In),
	.hex_out(hex2)
);
handle_hex hdl_h3(
	.clk(clk),
	.cond(break_code),
	.hex_in(hex3In),
	.hex_out(hex3)
);

handle hdl (
	.clk(clk),
	.ready(ready),
	.nextdata_n(nextdata_n),
	.rst_n(clrn)
);


endmodule;
