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
	output     [DATA_WIDTH-1:0] inst,
	output reg [ADDR_WIDTH-1:0] pc  ,
	output		 [ADDR_WIDTH-1:0] snpc,
	input      [ADDR_WIDTH-1:0] dnpc,
	//exu
  /*verilator lint_off UNUSED*/
	input									 is_RAW_control,
	input [ADDR_WIDTH-1:0] exu_dnpc
);

always @(posedge clk or posedge rst) begin
	if(rst) begin
		pc <= PC_INIT;
	end else begin
		pc <= exu_dnpc;
	end
end

assign addr = pc;

assign inst = finst;
assign dnpc = pc + 4;

endmodule
