`timescale 1ns/1ps
module testbench;
	reg [1:0] x;
	reg e;
	wire [3:0] y;

decode l(
	.x(x),
	.e(e),
	.y(y)
);

initial begin
	e = 1;
	$monitor("At time %0t: x = %b, e = %b, y = %b", $time, x, e, y);
	#20 x = 2'b00;
	#20 x = 2'b01;
	#20 e = 0;
	#20 x = 2'b10;
	#20 e = 1;
	#20 x = 2'b11;
	#20 e = 0;
	#100;
end

endmodule
