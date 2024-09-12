module loop_counter(
	input clk,
	input switch,
	input [2:0] obj,
	output reg [2:0] res
);

reg [1:0] sync_switch;
always @(clk) begin
	sync_switch = {sync_switch[0],switch};
end
wire jdg;
assign jdg = ^sync_switch;
always @(posedge clk) begin
	if (jdg) begin
	if (obj < 7) begin
		res <= obj;
	end else begin
		res <= 0;
	end
	end
end

endmodule
