module ysyx_25010009_lsu_axi_bridge #(
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32
)(
    input                   aclk        ,
    input                   areset      ,
//axi-lite output
    output [ADDR_WIDTH-1:0] awaddr      ,
    output [           2:0] awsize      ,
    output                  awvalid     ,
    input                   awready     ,
    output [DATA_WIDTH-1:0] wdata       ,
    output [           3:0] wstrb       ,
    output                  wvalid      ,
    input                   wready      ,
    input  [           2:0] bresp       ,
    input                   bvalid      ,
    output                  bready      ,
    output [ADDR_WIDTH-1:0] araddr      ,
    output [           2:0] arsize      ,
    output                  arvalid     ,
    input                   arready     ,
    input  [DATA_WIDTH-1:0] rdata       ,
    input  [           2:0] rresp       ,
    input                   rvalid      ,
    output                  rready      ,
//load/store input
    input                   cpu_wreq    ,
    input                   cpu_wready  ,
    output                  cpu_wresp   ,
    
    input                   cpu_rreq    ,
    input                   cpu_rready  ,
    output                  cpu_rresp   ,

	input  [DATA_WIDTH-1:0] cpu_waddr   ,
	input  [DATA_WIDTH-1:0] cpu_wdata	,
	input  [ADDR_WIDTH-1:0] cpu_raddr   ,
	output [DATA_WIDTH-1:0] cpu_rdata	,
	input  [           3:0] cpu_ram_mask,
	input  [           1:0] cpu_ram_size
);

/*   Write State Machine   */
reg [ADDR_WIDTH-1:0] reg_awaddr;
reg [           2:0] reg_awsize;
reg [DATA_WIDTH-1:0] reg_wdata ;
reg [           3:0] reg_wstrb ;

localparam W_IDLE    = 2'b00;
localparam W_WAIT_W  = 2'b11;
localparam W_WAIT_AW = 2'b01;
localparam W_WAIT_B  = 2'b10;
reg [1:0] w_current_state, w_next_state;

always @(*) begin
    case(w_current_state) 
        W_IDLE    : begin
            if     (awvalid && awready && wready) w_next_state = W_WAIT_B ;
            else if(awvalid && awready          ) w_next_state = W_WAIT_W ;
            else if(awvalid            && wready) w_next_state = W_WAIT_AW;
            else                                  w_next_state = W_IDLE   ;
        end
        W_WAIT_W  : begin
            if (wready) w_next_state = W_WAIT_B;
            else        w_next_state = W_WAIT_W;
        end
        W_WAIT_AW : begin
            if (awready) w_next_state = W_WAIT_B ;
            else         w_next_state = W_WAIT_AW;
        end
        W_WAIT_B  : begin
            if (bready && bvalid) w_next_state = W_IDLE  ;
            else                  w_next_state = W_WAIT_B;
        end
        default : w_next_state = W_IDLE;
    endcase
end

always @(posedge aclk, posedge areset) begin
    if(areset) begin
        w_current_state <= W_IDLE;
    end else begin
        if(awvalid && awready) begin
            reg_awaddr <= cpu_waddr           ;
            reg_awsize <= {1'b0, cpu_ram_size};
        end
        if( wvalid &&  wready) begin
            reg_wdata  <= cpu_wdata   ;
            reg_wstrb  <= cpu_ram_mask;
        end
        w_current_state <= w_next_state;
    end
end

assign awvalid = cpu_wreq && ((w_current_state == W_IDLE) || (w_current_state == W_WAIT_AW));
assign awaddr  = (w_current_state == W_IDLE) || (w_current_state == W_WAIT_AW) ? cpu_waddr            : reg_awaddr;
assign awsize  = (w_current_state == W_IDLE) || (w_current_state == W_WAIT_AW) ? {1'b0, cpu_ram_size} : reg_awsize;
assign wvalid  = cpu_wreq && ((w_current_state == W_IDLE) || (w_current_state == W_WAIT_W ));
assign wdata   = (w_current_state == W_IDLE) || (w_current_state == W_WAIT_W ) ? cpu_wdata : reg_wdata ;
assign bready  = cpu_wready && (w_current_state == W_WAIT_B);
assign cpu_wresp = bvalid && (w_current_state == W_WAIT_B);
assign wstrb   = (w_current_state == W_IDLE) || (w_current_state == W_WAIT_W ) ? cpu_ram_mask : reg_wstrb;

/*   Read State Machine   */
reg [ADDR_WIDTH-1:0] reg_araddr;
reg [           2:0] reg_arsize;

localparam R_IDLE    = 2'b00;
localparam R_WAIT_R  = 2'b01;
reg [1:0] r_current_state, r_next_state;

always @(*) begin
    case(r_current_state) 
        R_IDLE    : begin
            if(arvalid && arready) r_next_state = R_WAIT_R;
            else                   r_next_state = R_IDLE  ;
        end
        R_WAIT_R  : begin
            if (rvalid && rready) r_next_state = R_IDLE  ;
            else                  r_next_state = R_WAIT_R;
        end
        default : r_next_state = R_IDLE;
    endcase
end

always @(posedge aclk, posedge areset) begin
    if(areset) begin
        r_current_state <= R_IDLE;
    end else begin
        if(arvalid && arready) begin
            reg_araddr <= cpu_raddr           ;
            reg_arsize <= {1'b0, cpu_ram_size};
        end
        r_current_state <= r_next_state;
    end
end

assign arvalid = cpu_rreq && (r_current_state == R_IDLE);
assign araddr  = r_current_state == R_IDLE ? cpu_raddr            : reg_araddr;
assign arsize  = r_current_state == R_IDLE ? {1'b0, cpu_ram_size} : reg_arsize;
assign rready  = cpu_rready && (r_current_state == R_WAIT_R);
assign cpu_rresp = rvalid && (r_current_state == R_WAIT_R);
assign cpu_rdata = rdata;

endmodule
