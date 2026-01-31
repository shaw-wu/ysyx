module ysyx_25010009_ifu #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 32,
	parameter PC_INIT    = 32'h8000_0000
)(
	input                   clk           ,
	input                   rst           ,
	//irom <> ifu
    output                  rreq          ,
    output                  rdata_ready   ,
    input                   rdata_valid   ,
	output [ADDR_WIDTH-1:0] addr          ,
	input  [DATA_WIDTH-1:0] finst         ,
	//ifu <> idu
	output                  ifu_idu_valid ,
	input                   ifu_idu_ready ,
	output [DATA_WIDTH-1:0] inst          ,
	output [ADDR_WIDTH-1:0] pc            ,
	output [ADDR_WIDTH-1:0] snpc          ,
	output [ADDR_WIDTH-1:0] dnpc          ,
	//exu <> ifu
    /*verilator lint_off UNUSED*/
	input					is_RAW_control,
	input  [ADDR_WIDTH-1:0] wbu_dnpc      ,
	//wbu <> ifu
	input	                speec
);

parameter IDLE = 2'b00;
parameter WAIT = 2'b01;
parameter WORK = 2'b11;

reg [1:0] current_state, next_state;

always @(*) begin
	case(current_state) 
		IDLE : begin
			if(speec) next_state = WORK;
		end
		WAIT : begin
			if     (ifu_idu_ready &&  speec) next_state = WORK;
			else if(ifu_idu_ready && !speec) next_state = IDLE;
			else						     next_state = WAIT;
		end
		WORK : begin
			if     (rdata_valid &&  ifu_idu_ready &&  speec) next_state = WORK;
			else if(rdata_valid &&  ifu_idu_ready && !speec) next_state = IDLE;
			else if(rdata_valid && !ifu_idu_ready          ) next_state = WAIT;
			else                                             next_state = WORK;
		end
		default : next_state = IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= WORK;
	end else begin
		current_state <= next_state;
	end
end

reg [ADDR_WIDTH-1:0] reg_pc;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		reg_pc <= PC_INIT;
	end else begin
		if(speec) begin
			reg_pc <= wbu_dnpc;
		end
	end
end

assign pc = reg_pc;
assign addr = pc;
assign ifu_idu_valid = (current_state == WAIT) || ((current_state == WORK) && rdata_valid && !speec);
assign rreq        = current_state == WORK;
assign rdata_ready = current_state == WORK;

assign inst = finst;
assign snpc = pc + 4;
assign dnpc = pc + 4;

endmodule
