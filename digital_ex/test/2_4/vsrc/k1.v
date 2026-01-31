module k1 (
    input [7:0] in,
    output [7:0] out
);
/* verilator lint_off SELRANGE */
assign out[7:0] = in[0:7];
endmodule
