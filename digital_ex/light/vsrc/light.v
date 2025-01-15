`timescale 1ns / 1ps
module light(
	input clk,
	input rst,
	output reg [15:0] led
);

reg [31:0] count;

always @(posedge clk) begin
	if (rst) begin
		count <=0;
		led <= 16'h00ff;
	end else begin
		if(count == 0) led <= {led[14:0], led[15]};
		count <= (count >= 500000 ? 32'b0 : count + 1);
	end
end

endmodule
