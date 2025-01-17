`timescale 1ns / 1ps
module deal(
	input clk,
	input rstn,
	input overflow,
	input ready,
	input [7:0] data,
	output reg nextdata_n,
	output reg [6:0] hex0,
	output reg [6:0] hex1,
  output reg [6:0] hex2,
	output reg [6:0] hex3,
  output reg [6:0] hex4,
	output reg [6:0] hex5,
	output reg wshift,
	output reg wctrl
);

reg [7:0] code;
//延迟
reg delay_rstn;
wire [31:0] delay_count;
reg delay_en;
reg [31:0] delay;
//计数器
counter dl(
	.clk(clk),
	.rstn(delay_rstn),
	.en(delay_en),
	.count(delay_count)
);
assign delay = delay_count;
//主控制块,负责接收data,并在这之后置零nextdata_n一段时间
always @(posedge clk) begin
	if (~rstn) begin
		nextdata_n <= 1;
		delay_en <= 0;
	end else begin
		if (ready && ~overflow) begin
			if (nextdata_n) begin
				code <= data;
				delay_rstn <= 1;
				delay_en <= 1;
				nextdata_n <= 0;
			end
		end
		if(delay == 2) begin
			delay_rstn <= 0;
			delay_en <= 0;
			nextdata_n <= 1;
		end
	end
end

//编码译码
wire [7:0] ascii_code;
wire [6:0] seg5;
wire [6:0] seg4;
wire [6:0] seg3;
wire [6:0] seg2;
wire [6:0] seg1;
wire [6:0] seg0;
reg [7:0] ascii;
assign ascii = ascii_code;
reg [7:0] count;

//将键码编码成对应的ASCII码
encoder ec(
	.x(code),
	.wshift(wshift),
	.y(ascii_code)
);

//将ASCII码译码成七段数码管格式
decoder dc1(
	.x(ascii[7:4]),
	.y(seg1)
);

decoder dc0(
	.x(ascii[3:0]),
	.y(seg0)
);

decoder dc2(
	.x(code[7:4]),
	.y(seg2)
);

decoder dc3(
	.x(code[3:0]),
	.y(seg3)
);

decoder dc5(
	.x(count[7:4]),
	.y(seg5)
);

decoder dc4(
	.x(count[3:0]),
	.y(seg4)
);

//键码缓冲fifo,用于表示按键状态
reg [7:0] fifo_code[3:0];
always @(negedge nextdata_n) begin
	fifo_code <= {fifo_code[2], fifo_code[1], fifo_code[0], code};
end

always @(posedge clk) begin
	//{8'hf0, 8'hxx, 8'hf0, 8'hxx}, {8'hxx, k, 8'hf0, k}, {8'hxx, 8'hxx, 8'hxx, 8'hf0}
	//分别表示为:
	//松开a,松开b;松开a;松开a
	//if(((fifo_code[2] == fifo_code[0] || fifo_code[3] == 8'hf0) && fifo_code[1] == 8'hf0) || fifo_code[0] == 8'hf0) begin
	if(fifo_code[0] == 8'hf0 || fifo_code[1] == 8'hf0) begin
		hex0 <= 7'b111_1111;
		hex1 <= 7'b111_1111;
		hex2 <= 7'b111_1111;
		hex3 <= 7'b111_1111;
	end else begin
		hex0 <= seg0;
		hex1 <= seg1;
		hex2 <= seg2;
		hex3 <= seg3;
	end
end

//按键计数:敏感信号为nextdata_n,与接收键盘数据频率同步
always @(negedge nextdata_n) begin
	if(~rstn) begin
		count <= 0;
	end else if (code == 8'hf0) begin
		count <= count + 1;
	end else begin
		count <= count;
	end
end

assign hex4 = seg4;
assign hex5 = seg5;

//shift和ctrl的识别
always @(posedge clk) begin
	if ((code == 8'h12 || code == 8'h59) && fifo_code[1] != 8'hf0) begin
		//{8'hxx, 8'hxx, 8'hxx, (shift)}
		wshift <= 1;
	end else if ((code == 8'h12 || code == 8'h59) && fifo_code[1] == 8'hf0) begin
		//{8'hxx, (shift), 8'hf0, (shift)}
		wshift <= 0;
	end else begin
		wshift <= wshift;
	end
	if (code == 8'h14 && fifo_code[1] != 8'hf0) begin
		wctrl <= 1;
	end else if (code == 8'h14 && fifo_code[1] == 8'hf0) begin
		wctrl <= 0;
	end else begin
		wctrl <= wctrl;
	end
end

endmodule
