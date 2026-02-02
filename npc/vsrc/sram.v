`include "soc_conf.vh"
`timescale 1ns / 1ps
module ysyx_25010009_sram#(
	parameter XLEN = 32
)(
	input clk,
	input rst,
    input             we       ,
	input             req      ,
	output            resp     ,
    input  [    31:0] len      ,
	input  [XLEN-1:0] mem_raddr,
	output [XLEN-1:0] mem_rdata, 
	input  [XLEN-1:0] mem_waddr,
	input  [XLEN-1:0] mem_wdata 
);

`ifdef CONFIG_USE_LFSR
reg mem_work;
wire [7:0] cnt_max;
reg [7:0] cnt;

lfsr_8b lfsr(
	.clk(clk),
    .rst(rst),
	.s(!mem_work),
	.Q(cnt_max)
);

always @(posedge clk or posedge rst) begin
	if(rst) cnt <= 0;
    else begin
        mem_work <= (cnt == cnt_max);

        if     (mem_work      ) cnt <= 0      ;
        else if(cnt == cnt_max) cnt <= cnt    ;
        else                    cnt <= cnt + 1;
    end
end

//assign mem_work = cnt >= cnt_max;

`else
wire mem_work = 1;
`endif

wire arvalid = req && !we;
wire awvalid = req &&  we;

/*--------------- state machine -----------------*/

parameter IDLE  = 3'b000;
parameter WORKR = 3'b001;
parameter WORKW = 3'b010;
parameter WAITR = 3'b011;
parameter WAITW = 3'b110;

reg [2:0] current_state, next_state;

always @(*) begin
	case(current_state)
		IDLE :
			if     (awvalid) next_state = WORKW;
			else if(arvalid) next_state = WORKR;
			else		     next_state = IDLE ;
		WORKR : 
			if(mem_work) next_state = WAITR;
			else		 next_state = WORKR;
		WAITR : 
			next_state = IDLE;
		WORKW : 
		    if(mem_work) next_state = WAITW;
			else		 next_state = WORKW;
		WAITW : 
			next_state = IDLE;
		default : next_state = IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= IDLE;
	end else begin
		current_state <= next_state;
	end
end

assign resp =  ((current_state == WAITR) || (current_state == WAITW));

`ifdef VERILATOR
/*-----------------------------------------------*/
import "DPI-C" function int unsigned dpi_vaddr_read(int unsigned addr, int len, int ren);

reg [XLEN-1:0] reg_rdata;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		reg_rdata <= 0;
	end else begin
		if(mem_work && (current_state == WORKR)) begin
			reg_rdata <= dpi_vaddr_read(mem_raddr, len, {31'b0, mem_work && (current_state == WORKR)});
		end
	end
end

assign mem_rdata = reg_rdata;

import "DPI-C" function void dpi_vaddr_write(int unsigned addr, int len, int unsigned wdata, int wen);

always @(posedge clk) begin
	if(mem_work && (current_state == WORKW)) begin
	//if(awvalid) begin
		dpi_vaddr_write(mem_waddr, len, mem_wdata, {31'b0, mem_work && (current_state == WORKW)});
	end
end
`else
//有问题的，没有处理好addr和data
reg [7:0] mem [0:1024*1024];
reg [31:0] reg_rdata;
wire raddr_word = mem_raddr>>4;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		reg_rdata <= 0;
	end else begin
		if(mem_work && (current_state == WORKR)) begin
	        reg_rdata <= {mem[raddr_word+3]}, mem[raddr_word+2]}, mem[raddr_word+1]}, mem[raddr_word]};
        end
	end
end

assign mem_rdata = reg_rdata;

wire waddr_word = mem_waddr>>4;
always @(posedge clk) begin
	if(mem_work && (current_state == WORKW)) begin
	    mem[waddr_word] <= mem_wdata;
	end
end
`endif

endmodule
