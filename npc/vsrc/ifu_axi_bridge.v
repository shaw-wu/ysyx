module ysyx_25010009_ifu_axi_bridge #(
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32
)(
    input                   aclk        ,
    input                   areset      ,
//axi-lite output
    output [ADDR_WIDTH-1:0] araddr      ,
    output [           2:0] arsize      ,
    output                  arvalid     ,
    input                   arready     ,
    input  [DATA_WIDTH-1:0] rdata       ,
    input  [           2:0] rresp       ,
    input                   rvalid      ,
    output                  rready      ,
//load/store input
    input                   cpu_rreq    ,
    input                   cpu_rready  ,
    output                  cpu_rresp   ,

	input  [ADDR_WIDTH-1:0] cpu_raddr   ,
	output [DATA_WIDTH-1:0] cpu_rdata	
);

/*   Read State Machine   */
reg [ADDR_WIDTH-1:0] reg_araddr;

localparam IDLE  = 2'b00;
localparam WAIT  = 2'b01;
reg [1:0] current_state, next_state;

always @(*) begin
    case(current_state) 
        IDLE  : begin
            if(arvalid && arready) next_state = WAIT;
            else                   next_state = IDLE;
        end
        WAIT  : begin
            if (rvalid && rready) next_state = IDLE;
            else                  next_state = WAIT;
        end
        default : next_state = IDLE;
    endcase
end

always @(posedge aclk, posedge areset) begin
    if(areset) begin
        current_state <= IDLE;
    end else begin
        if(arvalid && arready) begin
            reg_araddr <= cpu_raddr;
        end
        current_state <= next_state;
    end
end

assign arvalid = cpu_rreq && (current_state == IDLE);
assign araddr  = current_state == IDLE ? cpu_raddr : reg_araddr;
assign arsize  = 3'b010;
assign rready  = cpu_rready && (current_state == WAIT);
assign cpu_rresp = rvalid && (current_state == WAIT);
assign cpu_rdata = rdata;

endmodule
