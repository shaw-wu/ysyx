`timescale 1ns / 1ps
module counter(
	input clk,
	input rstn,
	input en,
	output reg [31:0]count
);


always @(posedge clk or negedge rstn) begin
	if (~rstn) begin
		count <= 0;
	end else if (en)begin
		count <= count + 1;
	end
end

endmodule
