`timescale 1ns / 1ps
module ysyx_25010009_ALU #(
	parameter DATA_WIDTH  = 32, 
	parameter OPSEL_WIDTH = 4
)(
	input  [OPSEL_WIDTH-1:0] sel,
	input  [DATA_WIDTH -1:0] ina,
	input  [DATA_WIDTH -1:0] inb,
	output [DATA_WIDTH -1:0] out
);

wire [DATA_WIDTH-1:0] and_;
wire [DATA_WIDTH-1:0] or_ ;
wire [DATA_WIDTH-1:0] xor_;
wire [DATA_WIDTH-1:0] eq  ;
wire [DATA_WIDTH-1:0] ne  ;
wire [DATA_WIDTH-1:0] lt  ;
wire [DATA_WIDTH-1:0] ge  ;
wire [DATA_WIDTH-1:0] ltu ;
wire [DATA_WIDTH-1:0] geu ;
wire [DATA_WIDTH-1:0] cla_out  ;
wire [DATA_WIDTH-1:0] shift_out;

//shift
wire [1:0] shift_sel;
assign shift_sel = (sel == 4'b0110) ? 2'b01 :
									 (sel == 4'b0111) ? 2'b10 :
								   (sel == 4'b1000) ? 2'b11 :
									 2'b00;	 
ysyx_25010009_SHIFT shift_0(
	.a    (ina      ),
	.shamt(inb[4:0] ),
	.sel  (shift_sel),
	.out	(shift_out)
);

//cla
wire [DATA_WIDTH-1:0] cla_a, cla_b;
wire                  cla_cout;
//wire									overflow;
wire							    is_sub;
wire								  cin;
assign cla_a  = ina; 
assign cla_b  = {DATA_WIDTH{is_sub}} ^ inb; 
assign is_sub = (sel == 4'b0010) || (sel == 4'b1011) || (sel == 4'b1100) ; 
assign cin    = is_sub;
//assign overflow = (ina[DATA_WIDTH-1] == cla_b[DATA_WIDTH-1]) && (cla_out[DATA_WIDTH-1] != ina[DATA_WIDTH-1]);
ysyx_25010009_CLA cla_0(
	.a   (cla_a   ),
	.b   (cla_b   ),
	.cin (cin     ),
	.sum (cla_out ),
	.cout(cla_cout)
);

assign and_ = ina & inb;
assign or_  = ina | inb;
assign xor_ = ina ^ inb;
assign eq   = {{(DATA_WIDTH-1){1'b0}}, ina == inb}; 
assign ne   = {{(DATA_WIDTH-1){1'b0}}, ina != inb};
assign lt   =	{{(DATA_WIDTH-1){1'b0}},  cla_out[DATA_WIDTH-1]}; 
assign ge   = {{(DATA_WIDTH-1){1'b0}}, !cla_out[DATA_WIDTH-1]}; 
assign ltu  = {{(DATA_WIDTH-1){1'b0}}, ina <  inb}; 
assign geu  = {{(DATA_WIDTH-1){1'b0}}, ina >= inb}; 

reg [DATA_WIDTH-1:0] result;
always @(*) begin
	case(sel)
		4'b0001, 4'b0010: result = cla_out;
		4'b0011         : result = and_		;	
		4'b0100         : result = or_		;	
		4'b0101         : result = xor_   ;	
		4'b0110, 4'b0111, 4'b1000: result = shift_out;	
		4'b1001         : result = eq     ;	
		4'b1010         : result = ne     ;	
		4'b1011         : result = lt     ;	
		4'b1100         : result = ge     ;	
		4'b1101         : result = ltu    ;	
		4'b1110         : result = geu    ;	
		default: result = {DATA_WIDTH{1'b0}};
	endcase
end
assign out = result;

endmodule
