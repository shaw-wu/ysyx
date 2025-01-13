`timescale 1ns / 1ps
module ps2_keyboard(
	input clk,
	input clrn,
	input ps2_clk,
	input ps2_data,
	input nextdata_n,
	output [7:0] data,
	output reg ready,
	output reg overflow,
	output reg sampling,
	output reg break_code
);

	reg [9:0] buffer;
	reg [7:0] fifo[7:0];
	reg [2:0] w_ptr,r_ptr;
	reg [3:0] count;

	reg [2:0] ps2_clk_sync;
	//高频同步时钟clk与低频异步时钟ps2_clk对齐
	always @(posedge clk) begin
		ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk}; 
	end

	//检测时钟下降沿
	assign sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

	always @(posedge clk) begin
		//reset
		if (clrn == 0) begin
			count <= 0;
			w_ptr <= 0; r_ptr <= 0;
		  overflow <= 0;
			ready <= 0;
			break_code <= 0;
		end
		else begin
			if (r_ptr != (w_ptr + 3'b1)) begin
				overflow <= 0;
			end
			if (ready&&(!nextdata_n)) begin //队列中有数据(ready用读写指针判断并赋值)
					r_ptr <= r_ptr + 3'b1;
			    if ((w_ptr == r_ptr + 1) || (w_ptr == 0 && r_ptr == 7)) begin 
						ready <= 1'b0;
					end
					$display("fifo : %h %h %h %h %h %h %h %h",fifo[7],fifo[6],fifo[5],fifo[4],fifo[3],fifo[2],fifo[1],fifo[0]);
			end
			if (sampling) begin //读取数据
				if (count == 4'd10) begin //缓冲区buffer已满  
					if((buffer[0] == 0) && ps2_data && (^buffer[9:1])) begin //start==0,stop==1,odd(奇校验) 
							fifo[w_ptr] <= buffer[8:1];
							w_ptr <= w_ptr + 3'b1;
							ready <= 1'b1;
							overflow <= overflow | (r_ptr == (w_ptr + 3'b1));// 溢出 读指针在写指针后
					end
					count <= 0;
				end
				else begin //缓冲区未满
					buffer[count] <= ps2_data;
					count <= count + 4'b1;
				end
			end
		end
		if (fifo[r_ptr-2] == 8'hF0 || fifo[r_ptr-1] == 8'hF0) begin
			break_code <= 1;
		end else begin
			break_code <= 0;
		end
	end
	assign data = fifo[r_ptr-1];
endmodule
