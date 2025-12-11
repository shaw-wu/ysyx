module ysyx_25010009_ifu #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 32,
	parameter PC_INIT    = 32'h8000_0000
)(
	input clk,
	input rst,
	//irom
	input  [DATA_WIDTH-1:0] finst,
	output [ADDR_WIDTH-1:0] addr,
	//idu
	output ifu_idu_valid,
	input	 ifu_idu_ready,
	output     [DATA_WIDTH-1:0] inst,
	output reg [ADDR_WIDTH-1:0] pc  ,
	output		 [ADDR_WIDTH-1:0] snpc,
	output     [ADDR_WIDTH-1:0] dnpc,
	//exu
  /*verilator lint_off UNUSED*/
	input									 is_RAW_control,
	input [ADDR_WIDTH-1:0] exu_dnpc,
	//wbu
	input	speec
);

parameter IDLE = 2'b00;
parameter WAIT = 2'b01;
parameter WORK = 2'b11;

reg [1:0] current_state, next_state;

always @(*) begin
	case(current_state) 
		IDLE : begin
			if(speec) next_state = WORK;
		end
		WAIT : begin
			if		 (ifu_idu_ready &&  speec) next_state = WORK;
			else if(ifu_idu_ready && !speec) next_state = IDLE;
			else														 next_state = WAIT;
		end
		WORK : begin
			next_state = WAIT;
		end
		default : next_state = IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= WORK;
	end else begin
		current_state <= next_state;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		pc <= PC_INIT;
	end else begin
		if(speec) begin
			pc <= exu_dnpc;
		end
	end
end

assign addr = pc;
assign ifu_idu_valid = current_state == WAIT;

assign inst = finst;
assign snpc = pc + 4;
assign dnpc = pc + 4;

endmodule
