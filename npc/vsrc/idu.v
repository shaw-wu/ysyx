module ysyx_25020009_idu #(XLEN = 32, NR_INST = 1, IMM_LEN = 32, RS_LEN = 5, OP_LEN = 7, TYPE_LEN = 3, NR_FUNCT3 = 1, NR_FUNCT7 = 1) (
	input clk,
	input rst,
	input [XLEN-1:0] inst,
	input [64*NR_FUNCT3] funct3_lut,
	input [64*NR_FUNCT7] funct7_lut,
	output [IMM_LEN-1:0] imm,
	output [RS_LEN-1:0] rd,
	output [RS_LEN-1:0] rs1,
	output [RS_LEN-1:0] rs2,
	output [31:0] inst_code,
	output illegal,
	output unimpl,
	input en
);

typedef enum [TYPE_LEN-1:0] {
	TYPE_R : 0,
	TYPE_I : 1,
	TYPE_S : 2,
	TYPE_B : 3,
	TYPE_U : 4,
	TYPE_J : 5
}	type_t;

wire [IMM_LEN-1:0] _imm;
wire [RS_LEN-1:0] _rd;
wire [RS_LEN-1:0] _rs1;
wire [RS_LEN-1:0] _rs2;
wire [31:0] _inst_code;
wire _illegal;
wire _unimpl;
wire [31:0] inst_code_3;
wire [31:0] inst_code_7;
type_t type;

//输出信号时钟同步(imm,rd,rs1,rs2,inst_code,illegal,unimpl)
Reg #(IMM_LEN, 32'b0) i0 (
	.clk(clk),
	.rst(rst),
	.din(_imm),
	.dout(imm),
	.wen(en)
);

Reg #(RS_LEN, 5'b0) i1 (
	.clk(clk),
	.rst(rst),
	.din(_rd),
	.dout(rd),
	.wen(en)
);

Reg #(RS_LEN, 5'b0) i2 (
	.clk(clk),
	.rst(rst),
	.din(_rs1),
	.dout(rs1),
	.wen(en)
);

Reg #(RS_LEN, 5'b0) i3 (
	.clk(clk),
	.rst(rst),
	.din(_rs2),
	.dout(rs2),
	.wen(en)
);

Reg #(32, 32'b0) i4 (
	.clk(clk),
	.rst(rst),
	.din(_inst_code),
	.dout(inst_code),
	.wen(en)
);

Reg #(1, 0) i5 (
	.clk(clk),
	.rst(rst),
	.din(_illegal),
	.dout(illegal),
	.wen(en)
);

Reg #(1, 0) i6 (
	.clk(clk),
	.rst(rst),
	.din(_unimpl),
	.dout(unimpl),
	.wen(en)
);

//识别指令,使用两种不同类型的掩码funct7和funct3对指令进行位选,然后通过funct*_lut得到指令编码inst_code
//illegal指示译码过程错误,unimpl指示指令未识别或未实现
//type信息在指令编码高三位
ysyx_25020009_MuxKeyWithDefault #(NR_FUNCT3, XLEN, 32) s0 (
	.out(inst_code_3),
	.key(inst&32'h0000707f),
	.default_out(32'b0),
	.lut(funct3_lut)
);

ysyx_25020009_MuxKeyWithDefault #(NR_FUNC7, XLEN, 32) s1 (
	.out(inst_code_7),
	.key(inst&32'hfe00707f),
	.default_out(32'b0),
	.lut(funct7_lut)
);

ysyx_25020009_muxkeyWithdefault #(1, XLEN, 1) s2 (
	.out(_illegal),
	.key(inst_code_3|inst_code_7|{32{_unimpl}}),
	.default_out(1),
	.lut({inst_code_3, 0,
				inst_code_7, 0,	})
);

ysyx_25020009_muxkeyWithdefault #(1, XLEN, 1) s3 (
	.out(_unimpl),
	.key(inst_code_3|inst_code_7),
	.default_out(0),
	.lut({32'h00000000, 1})
);

assign _inst_code = inst_code_3 | inst_code_7;
assign type = _inst_code[31:29];

//读取imm,rd,rs1.rs2数据
assign _imm = (type == TYPE_I) ? {(inst[31] ? 20'b1 : 20'b0), inst[31:20]} :
						  (type == TYPE_S) ? {(inst[31] ? 20'b1 : 20'b0), inst[31:25], inst[11:7]} :
						  (type == TYPE_B) ? {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8],1'b0} :
						  (type == TYPE_U) ? {inst[31:12], 12'b0} :
						  (type == TYPE_J) ? {inst[31], inst[19:12], inst[20], inst[30:21], 12'b0} :
							32'b0;
assign _rd = inst[11:7];
assign _rs1 = inst[19:15];
assign _rs2 = inst[24:20];

endmodule
