module ebreak(
	input clk   ,
	input ebreak
);

import "DPI-C" function void is_ebreak(int ebreak);

always @(posedge clk)
	is_ebreak({31'b0, ebreak});

endmodule
