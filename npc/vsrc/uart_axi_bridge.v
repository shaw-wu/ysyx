module ysyx_25010009_uart_axi_bridge#(
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32
)(
    input                   aclk     ,
    input                   areset   ,
//s_axi-lite output
    input  [ADDR_WIDTH-1:0] awaddr   ,
    input  [           2:0] awsize   ,
    input                   awvalid  ,
    output                  awready  ,
    input  [DATA_WIDTH-1:0] wdata    ,
    input  [           3:0] wstrb    ,
    input                   wvalid   ,
    output                  wready   ,
    output [           2:0] bresp    ,
    output                  bvalid   ,
    input                   bready   ,
    /*
    input  [ADDR_WIDTH-1:0] araddr   ,
    input  [           2:0] arsize   ,
    input                   arvalid  ,
    output                  arready  ,
    output [DATA_WIDTH-1:0] rdata    ,
    output [           2:0] rresp    ,
    output                  rvalid   ,
    input                   rready   ,
    */
//sram input
    //output                  we       ,
	output                  req      ,
	input                   resp     ,
    //output [          31:0] len      ,
	//output [DATA_WIDTH-1:0] mem_raddr,
	//input  [DATA_WIDTH-1:0] mem_rdata, 
	output [DATA_WIDTH-1:0] mem_waddr,
	output [DATA_WIDTH-1:0] mem_wdata 
);

/*   Write State Machine   */
assign bresp = 0;

localparam W_IDLE    = 2'b00;
localparam W_WAIT_W  = 2'b11;
localparam W_WAIT_AW = 2'b01;
localparam W_WAIT_B  = 2'b10;
reg [1:0] w_current_state, w_next_state;

always @(*) begin
    case(w_current_state) 
        W_IDLE    : begin
            if     (awvalid && wvalid) w_next_state = W_WAIT_B ;
            else if(awvalid          ) w_next_state = W_WAIT_W ;
            else if(           wvalid) w_next_state = W_WAIT_AW;
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
        w_current_state <= w_next_state;
    end
end

assign awready = (w_current_state == W_IDLE) || (w_current_state == W_WAIT_AW);
assign wready  = (w_current_state == W_IDLE) || (w_current_state == W_WAIT_W );
assign bvalid  = resp && (w_current_state == W_WAIT_B);

/*   Read State Machine   */
//reg [DATA_WIDTH-1:0] reg_rdata;
//localparam R_IDLE    = 2'b00;
//localparam R_WAIT_R  = 2'b01;
//reg [1:0] r_current_state, r_next_state;
//
//always @(*) begin
//    case(r_current_state) 
//        R_IDLE    : begin
//            if (arvalid) r_next_state = R_WAIT_R ;
//            else         r_next_state = R_IDLE   ;
//        end
//        R_WAIT_R  : begin
//            if (rvalid && rready) r_next_state = R_IDLE  ;
//            else                  r_next_state = R_WAIT_R;
//        end
//        default : r_next_state = R_IDLE;
//    endcase
//end
//
//always @(posedge aclk, posedge areset) begin
//    if(areset) begin
//        r_current_state <= R_IDLE;
//    end else begin
//        if(rvalid && rready) reg_rdata <= mem_rdata;
//        r_current_state <= r_next_state;
//    end
//end
//
//assign arready = (r_current_state == R_IDLE);
//assign rvalid  = resp && (r_current_state == R_WAIT_R);
//assign rdata   = rvalid && rready ? mem_rdata : reg_rdata;
//assign rresp   = 0;
//
//assign we =  (w_current_state == W_WAIT_B)              || ((w_current_state == W_IDLE  ) && awvalid && wvalid ) || 
//            ((w_current_state == W_WAIT_AW) && awvalid) || ((w_current_state == W_WAIT_W) && wvalid); 
//assign req = we || (r_current_state == R_WAIT_R) || ((r_current_state == R_IDLE) && arvalid); 
assign req =  (w_current_state == W_WAIT_B)              || ((w_current_state == W_IDLE  ) && awvalid && wvalid ) || 
             ((w_current_state == W_WAIT_AW) && awvalid) || ((w_current_state == W_WAIT_W) && wvalid); 

//wire [31:0] rlen = arsize == 3'b00 ? 32'd1 :
//				   arsize == 3'b01 ? 32'd2 :	
//				   arsize == 3'b10 ? 32'd4 :	
//				   arsize == 3'b11 ? 32'd8 : 32'd0;	
//wire [31:0] wlen = awsize == 3'b00 ? 32'd1 :
//				   awsize == 3'b01 ? 32'd2 :	
//				   awsize == 3'b10 ? 32'd4 :	
//				   awsize == 3'b11 ? 32'd8 : 32'd0;	
//assign len = we ? wlen : rlen;
assign mem_wdata = wdata & {{8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}}};
assign mem_waddr = awaddr;
//assign mem_raddr = araddr;

endmodule
