module handle(
	input clk, 
	input ready, 
	input sampling,
	input rst_n,
	input [7:0] data,
	output reg [7:0] dataTemp,
	output reg nextdata_n
);

always @(posedge clk) begin
	if (ready) begin
		dataTemp = data;
		//$display("dataTemp : %h, data : %h",dataTemp,data);
	end
end
delayed_assignment delay (
		.clk(clk),
		.rst_n(rst_n),
		.pulse_in(ready),
		.pulse_out(nextdata_n)
	);
endmodule;
