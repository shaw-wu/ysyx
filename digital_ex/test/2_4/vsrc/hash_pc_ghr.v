`timescale 1ns / 1ps
module hash_pc_ghr(
    input [31:0]  pc,
    input [127:0] history,
    input [31:0]  history_length,
		output reg [31:0] hash_pc_ghr
);
reg [31:0] hash;
integer i;
always @(*) begin
    hash = pc[31:0];
		hash_pc_ghr = 0;
    for (i = 0; i < history_length; i = i + 1) begin
        if (i < 128) begin
            hash = hash ^ {31'b0, history[i]};
        end
        hash = {hash[30:0], hash[31]};
    end
    hash_pc_ghr = hash;
end
			
endmodule
