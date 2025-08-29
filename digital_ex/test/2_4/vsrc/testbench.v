`timescale 1ns /1ps
module testbench;
/* verilator lint_off UNUSED*/
reg [31:0] pc;
reg [127:0] history;
reg [31:0] history_length;
wire [31:0] hash_pc_ghr;

hash_pc_ghr h(
    .pc						 (pc						 ),
    .history			 (history			 ),
    .history_length(history_length),
		.hash_pc_ghr	 (hash_pc_ghr	 )
);

initial begin
	pc = 32'h800024ac;
	history = 128'h65aa9555556;
	history_length = 32'h20;
	#1
	pc = 32'h800024b0;
	history = 128'h65aa9555556;
	history_length = 32'h20;
	#1
	$finish;
end

endmodule

