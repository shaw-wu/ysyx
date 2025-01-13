`timescale 1ns / 1ps
module handle(
	input clk, 
	input ready, 
	input rst_n,
	output reg nextdata_n
);


delayed_assignment delay (
		.clk(clk),
		.rst_n(rst_n),
		.pulse_in(ready),
		.pulse_out(nextdata_n)
	);
endmodule;
