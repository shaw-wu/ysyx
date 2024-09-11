module handle_hex(
	input cond,
	input [6:0] hex_in,
	output reg [6:0] hex_out
);

always @(*) begin
	if (cond) begin
		hex_out = hex_in;
	end else begin
		hex_out = 7'b111_1111;
	end
end
endmodule
