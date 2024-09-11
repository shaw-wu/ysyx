module handle_hex(
	input cond,
	input [6:0] hex_in,
	output reg [6:0] hex_out
);

always @(*) begin
	if (cond) begin
		hex_out = hex_in;
	$display("hex_in : %h,hex_out : %h",hex_in,hex_out);
	end else begin
		hex_out = 7'b111_1111;
	$display("hex_in : %h,hex_out : %h",hex_in,hex_out);
	end
end
endmodule
