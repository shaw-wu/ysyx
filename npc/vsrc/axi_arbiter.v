module ysyx_25010009_axi_arbiter #(
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32
)(
    input                   clk         ,
    input                   rst         ,
//cpu axi-lite input
    input  [ADDR_WIDTH-1:0] lsu_awaddr ,
    input  [           2:0] lsu_awsize ,
    input                   lsu_awvalid,
    output                  lsu_awready,
    input  [DATA_WIDTH-1:0] lsu_wdata  ,
    input  [           3:0] lsu_wstrb  ,
    input                   lsu_wvalid ,
    output                  lsu_wready ,
    output [           2:0] lsu_bresp  ,
    output                  lsu_bvalid ,
    input                   lsu_bready ,
    input  [ADDR_WIDTH-1:0] lsu_araddr ,
    input  [           2:0] lsu_arsize ,
    input                   lsu_arvalid,
    output                  lsu_arready,
    output [DATA_WIDTH-1:0] lsu_rdata  ,
    output [           2:0] lsu_rresp  ,
    output                  lsu_rvalid ,
    input                   lsu_rready ,

    input  [ADDR_WIDTH-1:0] ifu_araddr ,
    input  [           2:0] ifu_arsize ,
    input                   ifu_arvalid,
    output                  ifu_arready,
    output [DATA_WIDTH-1:0] ifu_rdata  ,
    output [           2:0] ifu_rresp  ,
    output                  ifu_rvalid ,
    input                   ifu_rready ,
//ram axi-lite output
    output [ADDR_WIDTH-1:0] ram_awaddr ,
    output [           2:0] ram_awsize ,
    output                  ram_awvalid,
    input                   ram_awready,
    output [DATA_WIDTH-1:0] ram_wdata  ,
    output [           3:0] ram_wstrb  ,
    output                  ram_wvalid ,
    input                   ram_wready ,
    input  [           2:0] ram_bresp  ,
    input                   ram_bvalid ,
    output                  ram_bready ,
    output [ADDR_WIDTH-1:0] ram_araddr ,
    output [           2:0] ram_arsize ,
    output                  ram_arvalid,
    input                   ram_arready,
    input  [DATA_WIDTH-1:0] ram_rdata  ,
    input  [           2:0] ram_rresp  ,
    input                   ram_rvalid ,
    output                  ram_rready 
);

reg lsu_aw_access;
reg lsu_w_access;
reg ram_b_access;
reg lsu_ar_access;
reg lsu_r_access;
reg ifu_ar_access;
reg ram_r_access;
/*   Read State Machine   */
localparam R_IDLE   = 2'b00;
localparam R_WAIT_1 = 2'b01;
localparam R_WAIT_2 = 2'b10;
reg [1:0] r_current_state, r_next_state;

always @(*) begin
    case(r_current_state) 
        R_IDLE   : begin
            if     (ifu_arvalid) r_next_state = R_WAIT_1;
            else if(lsu_arvalid) r_next_state = R_WAIT_2;
            else                 r_next_state = R_IDLE  ;
        end
        R_WAIT_1 : begin
            if (ram_rvalid && ifu_rready) r_next_state = R_IDLE  ;
            else                          r_next_state = R_WAIT_1;
        end
        R_WAIT_2 : begin
            if (ram_rvalid && lsu_rready) r_next_state = R_IDLE  ;
            else                          r_next_state = R_WAIT_2;
        end
        default  : r_next_state = R_IDLE;
    endcase
end

always @(posedge clk, posedge rst) begin
    if(rst) begin
        r_current_state <= R_IDLE;
    end else begin
        r_current_state <= r_next_state;
    end
end

//ar
assign ram_arvalid = ((ifu_arvalid && (r_current_state == R_IDLE)) || (r_current_state == R_WAIT_1)) ? ifu_arvalid :
                     ((lsu_arvalid && (r_current_state == R_IDLE)) || (r_current_state == R_WAIT_2)) ? lsu_arvalid : 0;
assign ifu_arready = ram_arready;
assign lsu_arready = ram_arready;
assign ram_arsize  = ((ifu_arvalid && (r_current_state == R_IDLE)) || (r_current_state == R_WAIT_1)) ? ifu_arsize  :
                     ((lsu_arvalid && (r_current_state == R_IDLE)) || (r_current_state == R_WAIT_2)) ? lsu_arsize  : 0;
assign ram_araddr  = ((ifu_arvalid && (r_current_state == R_IDLE)) || (r_current_state == R_WAIT_1)) ? ifu_araddr  :
                     ((lsu_arvalid && (r_current_state == R_IDLE)) || (r_current_state == R_WAIT_2)) ? lsu_araddr  : 0;
//r
assign ifu_rvalid = r_current_state == R_WAIT_1 ? ram_rvalid : 0;
assign lsu_rvalid = r_current_state == R_WAIT_2 ? ram_rvalid : 0;
assign ram_rready = r_current_state == R_WAIT_1 ? ifu_rready :
                    r_current_state == R_WAIT_2 ? lsu_rready : 0;
assign ifu_rdata  = r_current_state == R_WAIT_1 ? ram_rdata  : 0;
assign lsu_rdata  = r_current_state == R_WAIT_2 ? ram_rdata  : 0;
assign ifu_rresp  = r_current_state == R_WAIT_1 ? ram_rresp  : 0;
assign lsu_rresp  = r_current_state == R_WAIT_2 ? ram_rresp  : 0;


//aw
assign ram_awvalid = lsu_awvalid;
assign lsu_awready = ram_awready;
assign ram_awaddr  = lsu_awaddr ;
assign ram_awsize  = lsu_awsize ;
//w
assign ram_wvalid  = lsu_wvalid ;
assign lsu_wready  = ram_wready ;
assign ram_wdata   = lsu_wdata  ;
assign ram_wstrb   = lsu_wstrb  ;
//b
assign lsu_bvalid  = ram_bvalid ;
assign ram_bready  = lsu_bready ;
assign lsu_bresp   = ram_bresp  ;

endmodule
