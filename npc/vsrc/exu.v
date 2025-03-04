module ysyx_25010009_exu #(XLEN = 32, CODE_LEN = 9, AR_LEN = 4, IMM_LEN = 32, RS_LEN = 5, OP_LEN = 7, TYPE_LEN = 3) (
	input clk,
	input rst,
	input [CODE_LEN-1:0] inst_code.
	input [IMM_LEN-1:0] imm,
	input [RS_LEN-1:0] rd,
	input [RS_LEN-1:0] rs1,
	input [RS_LEN-1:0] rs2,
	output [XLEN-1:0] dnpc,
	output [XLEN-1:0] rwdata,
	output [XLEN-1:0] rwaddr,
	input [XLEN-1:0] rrdata,
	output [XLEN-1:0] rraddr,
	output rwen,
	output rren,
	output [XLEN-1:0] dwdata,
	output [XLEN-1:0] dwaddr,
	input [XLEN-1:0] drdata,
	output [XLEN-1:0] draddr,
	output dwen,
	output dren,
	input en 
);

wire [AR_CODE-1:0] acode;
wire [XLEN-1:0] ain1;
wire [XLEN-1:0] ain2;
wire [XLEN-1:0] aout;
wire [XLEN-1:0] _dnpc;

ysyx_25010009_Reg #(XLEN,0) s0 (
	.clk(clk),
	.rst(rst),
	.din(_dnpc),
	.dout(dnpc),
	.wen(en)
);

ysyx_25010009_MuxKeyWithDefault #(2, CODE_LEN, AR_LEN) i0 (
	.out(acode),
	.key(inst_code),
	.default_out(~{AR_LEN{1'b0}}),
	.lut({9'b00000001, 4'b0000,
				9'b00000010, 4'b0000
				})	
);

ysyx_25010009_MuxKeyWithDefault #(2, CODE_LEN, XLEN) i1 (
	.out(ain1),
	.key(inst_code),
	.default_out(~{XLEN{1'b0}}),
	.lut({9'b00000001, rs1,
				9'b00000010, rs1
				})	
);

ysyx_25010009_MuxKeyWithDefault #(2, CODE_LEN, XLEN) i2 (
	.out(ain2),
	.key(inst_code),
	.default_out(~{XLEN{1'b0}}),
	.lut({9'b00000001, rs2,
				9'b00000010, imm
				})	
);

ysyx_25010009_MuxKeyWithDefault #(2, CODE_LEN, 1) i3 (
	.out(rwen),
	.key(ins_code),
	.default_out(0),
	.lut({9'b00000001, 1,
				9'b00000010, 1
				})	
);

ysyx_25010009_MuxKeyWithDefault #(0, CODE_LEN, 1) i4 (
	.out(rren),
	.key(ins_code),
	.default_out(0),
	.lut()	
);

ysyx_25010009_MuxKeyWithDefault #(2, CODE_LEN, XLEN) i5 (
	.out(rwdata),
	.key(inst_code),
	.default_out({XLEN{1'b0}}),
	.lut({9'b00000001, aout,
				9'b00000010, aout
				})	
);

ysyx_25010009_MuxKeyWithDefault #(2, CODE_LEN, XLEN) i6 (
	.out(rwaddr),
	.key(inst_code),
	.default_out({XLEN{1'b0}}),
	.lut({9'b00000001, rd,
				9'b00000010, rd
				})	
);

ysyx_25010009_MuxKeyWithDefault #(0, CODE_LEN, XLEN) i7 (
	.out(rrdata),
	.key(inst_code),
	.default_out({XLEN{1'b0}}),
	.lut()	
);

ysyx_25010009_MuxKeyWithDefault #(0, CODE_LEN, XLEN) i8 (
	.out(rraddr),
	.key(inst_code),
	.default_out({XLEN{1'b0}}),
	.lut()
);

ysyx_25010009_MuxKeyWithDefault #(0, CODE_LEN, XLEN) i9 (
	.out(dwdata),
	.key(inst_code),
	.default_out({XLEN{1'b0}}),
	.lut()	
);

ysyx_25010009_MuxKeyWithDefault #(0, CODE_LEN, XLEN) i10 (
	.out(dwaddr),
	.key(inst_code),
	.default_out({XLEN{1'b0}}),
	.lut()
);

ysyx_25010009_MuxKeyWithDefault #(0, CODE_LEN, XLEN) i11 (
	.out(drdata),
	.key(inst_code),
	.default_out({XLEN{1'b0}}),
	.lut()	
);

ysyx_25010009_MuxKeyWithDefault #(0, CODE_LEN, XLEN) i12 (
	.out(draddr),
	.key(inst_code),
	.default_out({XLEN{1'b0}}),
	.lut()
);

ysyx_25010009_MuxKeyWithDefault #(0, CODE_LEN, 1) i13 (
	.out(dwen),
	.key(inst_code),
	.default_out(0),
	.lut()	
);

ysyx_25010009_MuxKeyWithDefault #(0, CODE_LEN, 0) i14 (
	.out(dren),
	.key(inst_code),
	.default_out(0),
	.lut()	
);

ysyx_25010009_MuxKeyWithDefault #(0, CODE_LEN, XLEN) i14 (
	.out(_dnpc),
	.key(inst_code),
	.default_out(0),
	.lut()	
);

ysyx_25010009_ALU #(XLEN, AR_LEN) s0 (
	.code(acode),
	.x1(ain1),
	.x2(ain2),
	.res(aout)
);

endmodule
