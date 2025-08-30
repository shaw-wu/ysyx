module ysyx_25010009_SHIFT (
	input [31:0] a    ,
	input [4 :0] shamt,
	input	[1 :0] sel	,
	output [31:0] out
);

wire [31:0]  l_shift1,  l_shift2,  l_shift3,  l_shift4,  l_shift5;
wire [31:0] ru_shift1, ru_shift2, ru_shift3, ru_shift4, ru_shift5;
wire [31:0] rs_shift1, rs_shift2, rs_shift3, rs_shift4, rs_shift5;

assign l_shift1 = shamt[0] ? {       a[30:0],  1'b0} : a       ;
assign l_shift2 = shamt[1] ? {l_shift1[29:0],  2'b0} : l_shift1;
assign l_shift3 = shamt[2] ? {l_shift2[27:0],  4'b0} : l_shift2;
assign l_shift4 = shamt[3] ? {l_shift3[23:0],  8'b0} : l_shift3;
assign l_shift5 = shamt[4] ? {l_shift4[15:0], 16'b0} : l_shift3;

assign ru_shift1 = shamt[0] ? { 1'b0,         a[31: 1]} : a       ;
assign ru_shift2 = shamt[1] ? { 2'b0, ru_shift1[31: 2]} : ru_shift1;
assign ru_shift3 = shamt[2] ? { 4'b0, ru_shift2[31: 4]} : ru_shift2;
assign ru_shift4 = shamt[3] ? { 8'b0, ru_shift3[31: 8]} : ru_shift3;
assign ru_shift5 = shamt[4] ? {16'b0, ru_shift4[31:16]} : ru_shift3;

assign rs_shift1 = shamt[0] ? {{ 1{a[31]}},         a[31: 1]} : a       ;
assign rs_shift2 = shamt[1] ? {{ 2{a[31]}}, rs_shift1[31: 2]} : rs_shift1;
assign rs_shift3 = shamt[2] ? {{ 4{a[31]}}, rs_shift2[31: 4]} : rs_shift2;
assign rs_shift4 = shamt[3] ? {{ 8{a[31]}}, rs_shift3[31: 8]} : rs_shift3;
assign rs_shift5 = shamt[4] ? {{16{a[31]}}, rs_shift4[31:16]} : rs_shift3;

assign out = (sel == 2'b01) ?  l_shift5 : 
						 (sel == 2'b10) ? ru_shift5 :
						 (sel == 2'b11) ? rs_shift5 :
						 a;

endmodule
