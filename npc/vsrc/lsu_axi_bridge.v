module ysyx_25010009_lsu_axi_bridge #(
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32
)(
    input                   aclk        ,
    input                   areset      ,
//axi-lite output
    output [ADDR_WIDTH-1:0] awaddr      ,
    output                  awvalid     ,
    input                   awready     ,
    output [DATA_WIDTH-1:0] wdata       ,
    output [           3:0] wstrb       ,
    output                  wvalid      ,
    input                   wready      ,
    output [           1:0] bresp       ,
    output                  bvalid      ,
    input                   bready      ,
    output [ADDR_WIDTH-1:0] araddr      ,
    output                  arvalid     ,
    input                   arready     ,
    input  [DATA_WIDTH-1:0] rdata       ,
    input  [           1:0] rresp       ,
    input                   rvalid      ,
    output                  rready      ,
//load/store input
    input                   wreq        ,
    input                   wready      ,
    output                  wresp       ,
    
    input                   rreq        ,
    input                   rready      ,
    output                  rresp       ,

	input  [DATA_WIDTH-1:0] waddr       ,
	input  [DATA_WIDTH-1:0] wdata	    ,
	input  [ADDR_WIDTH-1:0] raddr       ,
	output [DATA_WIDTH-1:0] rdata	    ,
	input  [           3:0] ram_mask    ,
	input  [           1:0] ram_size
);

localparam W_IDLE    = 2'b00;
localparam W_WAIT_W  = 2'b11;
localparam W_WAIT_AW = 2'b01;
localparam W_WAIT_B  = 2'b01;
reg [1:0] w_current_state, w_next_state;

always @(*) begin
    case(w_current_state) 
        W_IDLE    : begin
            if     (wreq && awready && wready) w_next_state = W_WAIT_B ;
            else if(wreq && awready          ) w_next_state = W_WAIT_W ;
            else if(wreq &&         && wready) w_next_state = W_WAIT_AW;
        end
        W_WAIT_W  : begin
        end
        W_WAIT_AW : begin
        end
        W_WAIT_B  : begin
        end
        default : r_next_state = W_IDLE;
    endcase
end

always @(posedge aclk, posedge areset) begin
    if(areset) begin
        w_current_state <= W_IDLE;
    end else begin
        w_current_state <= r_next_state;
    end
end

endmodule
