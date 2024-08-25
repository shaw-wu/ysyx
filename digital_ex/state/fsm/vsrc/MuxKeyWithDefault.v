module MuxKeyWithDefault #(parameter LUT_SIZE, parameter KEY_WIDTH, parameter OUT_WIDTH)
(
	input [KEY_WIDTH-1:0] key,
	input [OUT_WIDTH-1:0] default_out,
	input [LUT_SIZE*(KEY_WIDTH+OUT_WIDTH)-1:0] lut,
	output reg [OUT_WIDTH-1:0] out
);

always @(*) begin
	integer i;
	out = default_out;
	for(i = 0; i < LUT_SIZE; i = i + 1) begin
		if(key == lut[(KEY_WIDTH+OUT_WIDTH)*i+OUT_WIDTH+:KEY_WIDTH]) begin
			out = lut[(KEY_WIDTH+OUT_WIDTH)*i+:OUT_WIDTH];
		end
	end
end

endmodule
