`include "soc_conf.vh"
module ysyx_25010009_clint #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input                   clk  ,
    input                   rst  ,
    input                   req  ,
    output                  resp ,
    /*verilator lint_off UNUSED*/
    input  [ADDR_WIDTH-1:0] raddr,
    output [DATA_WIDTH-1:0] rdata
);

reg reg_resp;

reg [63:0] mtime;

always @(posedge clk, posedge rst) begin
    if(rst) begin
        mtime <= 64'b0;
        reg_resp <= 0;
    end else begin
        reg_resp <= req;
        mtime <= mtime + 1;
    end
end

assign rdata = (raddr == `CONFIG_RTC_MMIO) ? mtime[31:0 ] :
               (raddr == `CONFIG_RTC_MMIO) ? mtime[63:32] : 0;
assign resp = reg_resp;

endmodule
