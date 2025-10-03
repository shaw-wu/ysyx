module ysyx_25010009_ifu #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 32,
	parameter PC_INIT    = 32'h8000_0000
)(
	input clk,
	input rst,
	//irom
	input  resvalid,
	output reqvalid,
	input  [DATA_WIDTH-1:0] finst,
	output [ADDR_WIDTH-1:0] addr,
	//idu
	output valid,
	output     [DATA_WIDTH-1:0] inst,
	output reg [ADDR_WIDTH-1:0] pc  ,
	output		 [ADDR_WIDTH-1:0] snpc,
	output     [ADDR_WIDTH-1:0] dnpc,
	//exu
  /*verilator lint_off UNUSED*/
	input									 is_RAW_control,
	input [ADDR_WIDTH-1:0] exu_dnpc,
	input									 speec
	//input									 wub_valid
);

wire [DATA_WIDTH-1:0] ifu_inst;
wire [ADDR_WIDTH-1:0] ifu_addr;

parameter IDLE = 2'b00;
parameter WAIT_ROM = 2'b01;
parameter WAIT_SPEEC = 2'b11;

reg [1:0] current_state, next_state;

always @(*) begin
	case(current_state)
		IDLE : begin
			next_state = WAIT_ROM; 
		end
		WAIT_ROM : begin
			if(resvalid && speec)				next_state = IDLE;
			else if(resvalid && !speec) next_state = WAIT_SPEEC;
			else				 next_state = WAIT_ROM;
		end
		WAIT_SPEEC : begin
			if(speec) next_state = IDLE;
		end
		default :
			next_state = IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= IDLE;
	end else begin
		current_state <= next_state;
	end
end

assign reqvalid = current_state == IDLE && !rst;
assign ifu_addr = pc;
assign ifu_inst = finst; 

always @(posedge clk or posedge rst) begin
	if(rst) begin
		pc <= PC_INIT;
	end else begin
		//if(wbu_valid) pc <= exu_dnpc;
		if(speec) pc <= exu_dnpc;
	end
end

assign valid = resvalid;
assign addr = ifu_addr;

assign inst = ifu_inst;
assign snpc = pc + 4;
assign dnpc = pc + 4;

endmodule
