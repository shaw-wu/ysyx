module ysyx_25010009_uart #(
    DATA_WIDTH = 32
)(
    input                   clk  ,
    input                   rst  ,
    input                   req  ,
    output                  resp ,
    /*verilator lint_off UNUSED*/
    input  [ADDR_WIDTH-1:0] waddr,
    input  [DATA_WIDTH-1:0] wdata
)

reg reg_tx_req ;
reg reg_tx_resp;
always @(posedge clk, posedge rst) begin
    if(rst) begin
        reg_tx_req  <= 0;
        reg_tx_resp <= 0;
    end else begin
        if(reg_tx_req) $write("%c", wdata[7:0]);
        reg_tx_req  <= req;
        reg_tx_resp <= reg_tx_req;
    end
end

assign resp = reg_tx_resp;

endmodule
