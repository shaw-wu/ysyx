module lfsr_8b(clk,rst, s, Q);
	input clk;
	input rst;
	input s;
	output reg [7:0] Q;

	//reg g;
    wire g = Q[4] ^ Q[3] ^ Q[2] ^ Q[0];

	always @(posedge s or  posedge clk) begin
            if(rst) Q<= 1;
            else begin
                if (s) Q <= Q;
			    else begin
			      //Q <= {g, Q[7:1]};
			      Q <= {g, Q[7:1]};
			    end
            end
    end
endmodule;
