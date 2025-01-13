`timescale 1ns / 1ps
module encoder(
	input [7:0] x ,
	output reg [7:0] y 
);

always @(*) begin
	case(x)
		8'h15 : y = 8'h71; //q 
		8'h1d : y = 8'h77; //w
		8'h24 : y = 8'h65; //e
		8'h2d : y = 8'h72; //r
		8'h2c : y = 8'h74; //t
		8'h35 : y = 8'h79; //y
		8'h3c : y = 8'h75; //u
		8'h43 : y = 8'h69; //i
		8'h44 : y = 8'h6f; //o
		8'h4d : y = 8'h70; //p
		8'h1c : y = 8'h61; //a
		8'h1b : y = 8'h73; //s
		8'h23 : y = 8'h64; //d
		8'h2b : y = 8'h66; //f
		8'h34 : y = 8'h67; //g
		8'h33 : y = 8'h68; //h
		8'h3b : y = 8'h6a; //j
		8'h42 : y = 8'h6b; //k
		8'h4b : y = 8'h6c; //l
		8'h1a : y = 8'h7a; //z
		8'h22 : y = 8'h78; //x
		8'h21 : y = 8'h63; //c
		8'h2a : y = 8'h76; //v
		8'h32 : y = 8'h62; //b
		8'h31 : y = 8'h6e; //n
		8'h3a : y = 8'h6d; //m
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
