module handle_hex(
	input clk,
	input ps2_clk,
	input [6:0] hex_in,
	output reg [6:0] hex_out
);

reg [2:0] sync_ps2_clk;
always @(posedge clk) begin
	sync_ps2_clk = {sync_ps2_clk[1:0],ps2_clk};
end
reg cond = ^sync_ps2_clk;

always @(posedge clk) begin
	if (cond) begin
		hex_out <= hex_in;
	end else begin
		hex_out <= 7'b111_1111;
	end
end
endmodule
