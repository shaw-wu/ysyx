module handle_hex(
	input cond,
	input [6:0] hex_in,
	output reg [6:0] hex_out
);

always @(*) begin
	//$display("hex_in : %h,hex_out : %h",hex_in,hex_out);
	if (cond) begin
		hex_out = hex_in;
	end else begin
		hex_out = 7'b111_1111;
	end
end
endmodule
