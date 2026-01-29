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
    input  [           1:0] bresp       ,
    input                   bvalid      ,
    output                  bready      ,
    output [ADDR_WIDTH-1:0] araddr      ,
    output                  arvalid     ,
    input                   arready     ,
    input  [DATA_WIDTH-1:0] rdata       ,
    input  [           1:0] rresp       ,
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
localparam W_IDLE    = 2'b00;
localparam W_WAIT_W  = 2'b11;
localparam W_WAIT_AW = 2'b01;
localparam W_WAIT_B  = 2'b01;
reg [1:0] w_current_state, w_next_state;

always @(*) begin
    case(w_current_state) 
        W_IDLE    : begin
            if     (cpu_wreq && awready && wready) w_next_state = W_WAIT_B ;
            else if(cpu_wreq && awready          ) w_next_state = W_WAIT_W ;
            else if(cpu_wreq &&         && wready) w_next_state = W_WAIT_AW;
            else                                   w_next_state = W_IDLE   ;
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
            if (cpu_wready && bvalid) w_next_state = W_IDLE  ;
            else                      w_next_state = W_WAIT_B;
        end
        default : r_next_state = W_IDLE;
    endcase
end

always @(posedge aclk, posedge areset) begin
    if(areset) begin
        w_current_state <= W_IDLE;
    end else begin
        w_current_state <= w_next_state;
    end
end

assign awvalid = cpu_wreq && ((w_current_state == W_IDLE) || (w_current_state == W_WAIT_AW));
assign awaddr  = cpu_waddr;
assign wvalid  = cpu_wreq && ((w_current_state == W_IDLE) || (w_current_state == W_WAIT_W ));
assign wdata   = cpu_wdata;
assign bready  = cpu_wready && (w_current_state == W_WAIT_B);
assign cpu_wresp = bvalid && (w_current_state == W_WAIT_B);
assign wstrb   = cpu_ram_mask;

/*   Read State Machine   */
localparam R_IDLE    = 2'b00;
localparam R_WAIT_R  = 2'b01;
reg [1:0] r_current_state, r_next_state;

always @(*) begin
    case(r_current_state) 
        R_IDLE    : begin
            if(cpu_rreq && arready) r_next_state = R_WAIT_R;
            else                    r_next_state = R_IDLE  ;
        end
        R_WAIT_R  : begin
            if (rvalid && cpu_rready) w_next_state = R_IDLE  ;
            else                      w_next_state = R_WAIT_R;
        end
        default : r_next_state = R_IDLE;
    endcase
end

always @(posedge aclk, posedge areset) begin
    if(areset) begin
        r_current_state <= R_IDLE;
    end else begin
        r_current_state <= r_next_state;
    end
end

assign arvalid = cpu_rreq && (r_current_state == R_IDLE);
assign araddr  = cpu_raddr;
assign rready  = cpu_rready && (r_current_state == R_WAIT_R);
assign cpu_rresp = rvalid && (w_current_state == R_WAIT_R);
assign cpu_rdata = rdata;

endmodule
