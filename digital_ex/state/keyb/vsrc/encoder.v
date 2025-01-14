`timescale 1ns / 1ps
module encoder(
	input [7:0] x ,
	input wshift,
	output reg [7:0] y 
);

reg [7:0] addition;

always @(*) begin
	if (wshift) begin
		addition = 8'd32;
	end else begin
		addition = 8'd0;
	end
end

always @(*) begin
	case(x)
		8'h15 : y = 8'h71 - addition; //q 
		8'h1d : y = 8'h77 - addition; //w
		8'h24 : y = 8'h65 - addition; //e
		8'h2d : y = 8'h72 - addition; //r
		8'h2c : y = 8'h74 - addition; //t
		8'h35 : y = 8'h79 - addition; //y
		8'h3c : y = 8'h75 - addition; //u
		8'h43 : y = 8'h69 - addition; //i
		8'h44 : y = 8'h6f - addition; //o
		8'h4d : y = 8'h70 - addition; //p
		8'h1c : y = 8'h61 - addition; //a
		8'h1b : y = 8'h73 - addition; //s
		8'h23 : y = 8'h64 - addition; //d
		8'h2b : y = 8'h66 - addition; //f
		8'h34 : y = 8'h67 - addition; //g
		8'h33 : y = 8'h68 - addition; //h
		8'h3b : y = 8'h6a - addition; //j
		8'h42 : y = 8'h6b - addition; //k
		8'h4b : y = 8'h6c - addition; //l
		8'h1a : y = 8'h7a - addition; //z
		8'h22 : y = 8'h78 - addition; //x
		8'h21 : y = 8'h63 - addition; //c
		8'h2a : y = 8'h76 - addition; //v
		8'h32 : y = 8'h62 - addition; //b
		8'h31 : y = 8'h6e - addition; //n
		8'h3a : y = 8'h6d - addition; //m
		8'h16 : y = 8'h31;
		8'h1e : y = 8'h32;
		8'h26 : y = 8'h33;
		8'h25 : y = 8'h34;
		8'h2e : y = 8'h35;
		8'h36 : y = 8'h36;
		8'h3d : y = 8'h37;
		8'h3e : y = 8'h38;
		8'h46 : y = 8'h39;
		8'h45 : y = 8'h30;
		8'h14 : y = 8'hfe;
		8'h12 : y = 8'hff; 
		8'h59 : y = 8'hff;
		8'hf0 : y = x;
		default : y = 8'h00;
	endcase  
end       

endmodule
