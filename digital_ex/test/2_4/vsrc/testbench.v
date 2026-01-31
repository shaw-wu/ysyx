`timescale 1ns /1ps
module testbench;
/* verilator lint_off UNUSED*/

reg [7:0] in;
reg [7:0] out;

k1 h(
    .in(in),
    .out(out)
);

initial begin
	#1
    in = 8'b11000000;
	#1
    in = 8'b11001100;
	$finish;
end

endmodule

