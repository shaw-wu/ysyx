module SimReg #(parameter WIDTH, parameter INIT)
(
	input clk, reset,
	input [WIDTH-1:0] din,
	output reg [WIDTH-1:0] dout,
	input wen
);

always @(posedge clk or posedge reset) begin
	if (reset)
		dout <= INIT;
	else if (wen)
		dout <= din;
end

endmodule

