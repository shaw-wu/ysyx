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
	output valid,
	output     [DATA_WIDTH-1:0] inst,
	output reg [ADDR_WIDTH-1:0] pc  ,
	output		 [ADDR_WIDTH-1:0] snpc,
	output     [ADDR_WIDTH-1:0] dnpc,
	//exu
  /*verilator lint_off UNUSED*/
	input									 is_RAW_control,
	input [ADDR_WIDTH-1:0] exu_dnpc
);

wire [DATA_WIDTH-1:0] ifu_inst;
wire [ADDR_WIDTH-1:0] ifu_addr;
reg  [DATA_WIDTH-1:0] delay_inst;

parameter IDLE = 1'b0;
parameter WORK = 1'b1;

reg current_state, next_state;

always @(*) begin
	case(current_state)
		IDLE : next_state = WORK; 
		WORK : next_state = IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= IDLE;
	end else begin
		current_state <= next_state;
	end
end

assign ifu_addr = current_state == IDLE ? pc		: 0;
assign ifu_inst = current_state == WORK ? finst : 0; 

always @(posedge clk or posedge rst) begin
	if(rst) begin
		pc <= PC_INIT;
		delay_inst <= 0;
	end else begin
		if(valid) pc <= exu_dnpc;
		delay_inst <= inst;
	end
end

assign valid = current_state == WORK;
assign addr = ifu_addr;

assign inst = ifu_inst;
assign snpc = pc + 4;
assign dnpc = pc + 4;

endmodule
