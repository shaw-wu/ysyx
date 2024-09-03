module Simreg#(parameter WIDTH)
(
	input clk,
	input [WIDTH-1:0] clrn_din,
	input [WIDTH-1:0] next_din,
	output reg [WIDTH-1:0] clrn_dout,
	output reg [WIDTH-1:0] next_dout,
	input wen
)

always @(posedge clk) begin
	if (wen) begin clrn_dout <= din; next_dout <= dout;
end
endmodule
