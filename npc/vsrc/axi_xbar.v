`include "soc_conf.vh"
module ysyx_2500009_axi_xbar #(
	parameter ADDR_WIDTH   = 32, 
	parameter DATA_WIDTH   = 32
)(
    input                   clk                   ,
    input                   rst                   ,
//master axi-lite input
    input  [ADDR_WIDTH-1:0] io_master_cpu_awaddr  ,
    input  [           2:0] io_master_cpu_awsize  ,
    input                   io_master_cpu_awvalid ,
    output                  io_master_cpu_awready ,
    input  [DATA_WIDTH-1:0] io_master_cpu_wdata   ,
    input  [           3:0] io_master_cpu_wstrb   ,
    input                   io_master_cpu_wvalid  ,
    output                  io_master_cpu_wready  ,
    output [           2:0] io_master_cpu_bresp   ,
    output                  io_master_cpu_bvalid  ,
    input                   io_master_cpu_bready  ,
    input  [ADDR_WIDTH-1:0] io_master_cpu_araddr  ,
    input  [           2:0] io_master_cpu_arsize  ,
    input                   io_master_cpu_arvalid ,
    output                  io_master_cpu_arready ,
    output [DATA_WIDTH-1:0] io_master_cpu_rdata   ,
    output [           2:0] io_master_cpu_rresp   ,
    output                  io_master_cpu_rvalid  ,
    input                   io_master_cpu_rready  ,
//ram axi-lite output
    output [ADDR_WIDTH-1:0] io_slaver_sram_awaddr ,
    output [           2:0] io_slaver_sram_awsize ,
    output                  io_slaver_sram_awvalid,
    input                   io_slaver_sram_awready,
    output [DATA_WIDTH-1:0] io_slaver_sram_wdata  ,
    output [           3:0] io_slaver_sram_wstrb  ,
    output                  io_slaver_sram_wvalid ,
    input                   io_slaver_sram_wready ,
    input  [           2:0] io_slaver_sram_bresp  ,
    input                   io_slaver_sram_bvalid ,
    output                  io_slaver_sram_bready ,
    output [ADDR_WIDTH-1:0] io_slaver_sram_araddr ,
    output [           2:0] io_slaver_sram_arsize ,
    output                  io_slaver_sram_arvalid,
    input                   io_slaver_sram_arready,
    input  [DATA_WIDTH-1:0] io_slaver_sram_rdata  ,
    input  [           2:0] io_slaver_sram_rresp  ,
    input                   io_slaver_sram_rvalid ,
    output                  io_slaver_sram_rready ,
//ram axi-lite output
    output [ADDR_WIDTH-1:0] io_slaver_uart_awaddr ,
    output [           2:0] io_slaver_uart_awsize ,
    output                  io_slaver_uart_awvalid,
    input                   io_slaver_uart_awready,
    output [DATA_WIDTH-1:0] io_slaver_uart_wdata  ,
    output [           3:0] io_slaver_uart_wstrb  ,
    output                  io_slaver_uart_wvalid ,
    input                   io_slaver_uart_wready ,
    input  [           2:0] io_slaver_uart_bresp  ,
    input                   io_slaver_uart_bvalid ,
    output                  io_slaver_uart_bready ,
    //output [ADDR_WIDTH-1:0] io_slaver_uart_araddr ,
    //output [           2:0] io_slaver_uart_arsize ,
    //output                  io_slaver_uart_arvalid,
    //input                   io_slaver_uart_arready,
    //input  [DATA_WIDTH-1:0] io_slaver_uart_rdata  ,
    //input  [           2:0] io_slaver_uart_rresp  ,
    //input                   io_slaver_uart_rvalid ,
    //output                  io_slaver_uart_rready ,
//clint axi-lite output
    //output [ADDR_WIDTH-1:0] io_slaver_clint_awaddr ,
    //output [           2:0] io_slaver_clint_awsize ,
    //output                  io_slaver_clint_awvalid,
    //input                   io_slaver_clint_awready,
    //output [DATA_WIDTH-1:0] io_slaver_clint_wdata  ,
    //output [           3:0] io_slaver_clint_wstrb  ,
    //output                  io_slaver_clint_wvalid ,
    //input                   io_slaver_clint_wready ,
    //input  [           2:0] io_slaver_clint_bresp  ,
    //input                   io_slaver_clint_bvalid ,
    //output                  io_slaver_clint_bready ,
    output [ADDR_WIDTH-1:0] io_slaver_clint_araddr ,
    output [           2:0] io_slaver_clint_arsize ,
    output                  io_slaver_clint_arvalid,
    input                   io_slaver_clint_arready,
    input  [DATA_WIDTH-1:0] io_slaver_clint_rdata  ,
    input  [           2:0] io_slaver_clint_rresp  ,
    input                   io_slaver_clint_rvalid ,
    output                  io_slaver_clint_rready 
);

//Signal Feedthrough 

reg [ADDR_WIDTH-1:0] master_cpu_awaddr ;
reg [           2:0] master_cpu_awsize ;
reg [DATA_WIDTH-1:0] master_cpu_wdata  ;
reg [           3:0] master_cpu_wstrb  ;
reg [ADDR_WIDTH-1:0] master_cpu_araddr ;
reg [           2:0] master_cpu_arsize ;
reg [DATA_WIDTH-1:0] slaver_sram_rdata ;
reg [DATA_WIDTH-1:0] slaver_clint_rdata;

`ifdef VERILATOR
import "DPI-C" function void use_device(int is_device);

always @(posedge clk) begin
    if(io_master_cpu_awvalid && io_master_cpu_awready) use_device({31'b0, aw_uart_access});
    if(io_master_cpu_arvalid && io_master_cpu_arready) use_device({31'b0,           1'b0});
end
`endif

wire aw_sram_access  = io_master_cpu_awvalid && (io_master_cpu_awaddr >= `CONFIG_MBASE) && (io_master_cpu_awaddr < (`CONFIG_MBASE + `CONFIG_MSIZE));
wire ar_sram_access  = io_master_cpu_arvalid && (io_master_cpu_araddr >= `CONFIG_MBASE) && (io_master_cpu_araddr < (`CONFIG_MBASE + `CONFIG_MSIZE));
wire aw_uart_access  = io_master_cpu_awvalid && (io_master_cpu_awaddr >= `CONFIG_SERIAL_MMIO) && (io_master_cpu_awaddr < `CONFIG_SERIAL_MMIO + 8);
wire ar_clint_access = io_master_cpu_arvalid && (io_master_cpu_araddr >= `CONFIG_RTC_MMIO) && (io_master_cpu_araddr < (`CONFIG_RTC_MMIO + 8));

wire w_sram_access  = (master_cpu_awaddr >= `CONFIG_MBASE) && (master_cpu_awaddr < (`CONFIG_MBASE + `CONFIG_MSIZE));
wire r_sram_access  = (master_cpu_araddr >= `CONFIG_MBASE) && (master_cpu_araddr < (`CONFIG_MBASE + `CONFIG_MSIZE));
wire w_uart_access  = (master_cpu_awaddr >= `CONFIG_SERIAL_MMIO) && (master_cpu_awaddr < `CONFIG_SERIAL_MMIO + 8);
wire r_clint_access = (master_cpu_araddr >= `CONFIG_RTC_MMIO) && (master_cpu_araddr < (`CONFIG_RTC_MMIO + 8));

always @(posedge clk, posedge rst) begin
    if(rst) master_cpu_araddr <= 0;
    else begin
        if(io_master_cpu_arvalid && io_master_cpu_arready)
            master_cpu_araddr <= io_master_cpu_araddr;
    end
end

parameter AW_IDLE   = 2'b00; 
parameter AW_WAIT_W = 2'b01; 
parameter AW_WAIT   = 2'b11; 
parameter AW_ERR    = 2'b10; 

reg [1:0] aw_current_state, aw_next_state;

always @(*) begin
    case(aw_current_state) 
        AW_IDLE   : begin
            if      (io_master_cpu_awvalid && io_master_cpu_awready && io_master_cpu_wvalid && (aw_sram_access || aw_uart_access)) aw_next_state = AW_WAIT  ;
            else if (io_master_cpu_awvalid && io_master_cpu_awready                         && (aw_sram_access || aw_uart_access)) aw_next_state = AW_WAIT_W;
            else if (io_master_cpu_awvalid && io_master_cpu_awready                                                              ) aw_next_state = AW_ERR   ;
            else                                                                                                                   aw_next_state = AW_IDLE  ;
        end
        AW_WAIT_W : begin
            if      (io_master_cpu_wvalid && io_master_cpu_wready && (w_sram_access || w_uart_access)) aw_next_state = AW_WAIT  ;
            else if (io_master_cpu_wvalid && io_master_cpu_wready                                    ) aw_next_state = AW_ERR   ;
            else                                                                                       aw_next_state = AW_WAIT_W;
        end
        AW_WAIT   : begin
            if (io_master_cpu_bvalid && io_master_cpu_bready) aw_next_state = AW_IDLE;
            else                                              aw_next_state = AW_WAIT;
        end
        AW_ERR    : begin
            if (io_master_cpu_bvalid && io_master_cpu_bready) aw_next_state = AW_IDLE;
            else                                              aw_next_state = AW_ERR ;
        end
        default : aw_next_state = AW_IDLE;
    endcase
end

always @(posedge clk, posedge rst) begin
    if(rst) begin
        aw_current_state <= AW_IDLE;
    end else begin
        if(io_master_cpu_awvalid && io_master_cpu_awready) begin
            master_cpu_awaddr <= io_master_cpu_awaddr;
            master_cpu_awsize <= io_master_cpu_awsize;
        end
        if(io_master_cpu_wvalid && io_master_cpu_wready) begin
            master_cpu_wdata  <= io_master_cpu_wdata ;
            master_cpu_wstrb  <= io_master_cpu_wstrb ;
        end
        aw_current_state <= aw_next_state;
    end
end

parameter AR_IDLE   = 2'b00; 
parameter AR_WAIT   = 2'b01; 
parameter AR_ERR    = 2'b10; 

reg [1:0] ar_current_state, ar_next_state;

always @(*) begin
    case(ar_current_state) 
        AR_IDLE   : begin
            if      (io_master_cpu_arvalid && io_master_cpu_arready && io_master_cpu_rvalid && (ar_sram_access || ar_clint_access)) ar_next_state = AR_WAIT;
            else if (io_master_cpu_arvalid && io_master_cpu_arready                                                               ) ar_next_state = AR_ERR ;
            else                                                                                                                    ar_next_state = AR_IDLE;
        end
        AR_WAIT   : begin
            if (io_master_cpu_rvalid && io_master_cpu_rready) ar_next_state = AR_IDLE;
            else                                              ar_next_state = AR_WAIT;
        end
        AR_ERR    : begin
            if (io_master_cpu_rvalid && io_master_cpu_rready) ar_next_state = AR_IDLE;
            else                                              ar_next_state = AR_ERR ;
        end
        default : ar_next_state = AR_IDLE;
    endcase
end

always @(posedge clk, posedge rst) begin
    if(rst) begin
        ar_current_state <= AR_IDLE;
    end else begin
        if(io_master_cpu_arvalid && io_master_cpu_arready) begin
            master_cpu_araddr <= io_master_cpu_araddr;
            master_cpu_arsize <= io_master_cpu_arsize;
        end
        if(io_slaver_sram_rvalid && io_slaver_sram_rready) begin
            slaver_sram_rdata  <= io_slaver_sram_rdata;
        end
        if(io_slaver_clint_rvalid && io_slaver_clint_rready) begin
            slaver_clint_rdata  <= io_slaver_clint_rdata;
        end
        ar_current_state <= ar_next_state;
    end
end

//AW
assign io_master_cpu_awready  = ((aw_current_state == AW_IDLE) && aw_sram_access && io_slaver_sram_awready) ||
                                ((aw_current_state == AW_IDLE) && aw_uart_access && io_slaver_uart_awready)    ;

assign io_slaver_sram_awvalid = ((aw_current_state == AW_IDLE) && aw_sram_access && io_slaver_sram_awready)    ;
assign io_slaver_sram_awaddr  =   aw_current_state == AW_IDLE ? io_master_cpu_awaddr : master_cpu_awaddr       ;
assign io_slaver_sram_awsize  =   aw_current_state == AW_IDLE ? io_master_cpu_awsize : master_cpu_awsize       ;

assign io_slaver_uart_awvalid = ((aw_current_state == AW_IDLE) && aw_uart_access && io_slaver_uart_awready)    ;
assign io_slaver_uart_awaddr  =   aw_current_state == AW_IDLE ? io_master_cpu_awaddr : master_cpu_awaddr       ;
assign io_slaver_uart_awsize  =   aw_current_state == AW_IDLE ? io_master_cpu_awsize : master_cpu_awsize       ;

//W
assign io_master_cpu_wready   = ((aw_current_state == AW_IDLE  ) && aw_sram_access && io_slaver_sram_wready) ||
                                ((aw_current_state == AW_IDLE  ) && aw_uart_access && io_slaver_uart_wready) ||  
                                ((aw_current_state == AW_WAIT_W) &&  w_sram_access && io_slaver_sram_wready) ||  
                                ((aw_current_state == AW_WAIT_W) &&  w_uart_access && io_slaver_uart_wready)   ;

assign io_slaver_sram_wvalid  = ((aw_current_state == AW_IDLE  ) && aw_sram_access && io_master_cpu_wvalid) ||
                                ((aw_current_state == AW_WAIT_W) &&  w_sram_access && io_master_cpu_wvalid)   ;
assign io_slaver_sram_wdata   = ((aw_current_state == AW_IDLE) && io_master_cpu_wvalid) || (aw_current_state == AW_WAIT_W) ? io_master_cpu_wdata : master_cpu_wdata;
assign io_slaver_sram_wstrb   = ((aw_current_state == AW_IDLE) && io_master_cpu_wvalid) || (aw_current_state == AW_WAIT_W) ? io_master_cpu_wstrb : master_cpu_wstrb;

assign io_slaver_uart_wvalid  = ((aw_current_state == AW_IDLE  ) && aw_uart_access && io_master_cpu_wvalid) ||  
                                ((aw_current_state == AW_WAIT_W) &&  w_uart_access && io_master_cpu_wvalid)   ;
assign io_slaver_uart_wdata   = ((aw_current_state == AW_IDLE) && io_master_cpu_wvalid) || (aw_current_state == AW_WAIT_W) ? io_master_cpu_wdata : master_cpu_wdata;
assign io_slaver_uart_wstrb   = ((aw_current_state == AW_IDLE) && io_master_cpu_wvalid) || (aw_current_state == AW_WAIT_W) ? io_master_cpu_wstrb : master_cpu_wstrb;

//B
assign io_master_cpu_bvalid = (((aw_current_state == AW_WAIT) || (aw_current_state == AW_ERR)) && w_sram_access && io_slaver_sram_bvalid) ||
                              (((aw_current_state == AW_WAIT) || (aw_current_state == AW_ERR)) && w_uart_access && io_slaver_uart_bvalid)   ;
assign io_master_cpu_bresp  = (aw_current_state == AW_ERR) ? 3'b011 : 3'b00;

assign io_slaver_sram_bready = ((aw_current_state == AW_WAIT) || (aw_current_state == AW_ERR)) && w_sram_access && io_master_cpu_bready     ;
assign io_slaver_uart_bready = ((aw_current_state == AW_WAIT) || (aw_current_state == AW_ERR)) && w_uart_access && io_master_cpu_bready     ;

//AR
assign io_master_cpu_arready  = ((ar_current_state == AR_IDLE) && ar_sram_access  && io_slaver_sram_awready ) ||
                                ((ar_current_state == AR_IDLE) && ar_clint_access && io_slaver_clint_awready)    ;

assign io_slaver_sram_awvalid = ((aw_current_state == AW_IDLE) && aw_sram_access && io_slaver_sram_awready)    ;
assign io_slaver_sram_awaddr  =   aw_current_state == AW_IDLE ? io_master_cpu_awaddr : master_cpu_awaddr       ;
assign io_slaver_sram_awsize  =   aw_current_state == AW_IDLE ? io_master_cpu_awsize : master_cpu_awsize       ;

assign io_slaver_uart_awvalid = ((aw_current_state == AW_IDLE) && aw_uart_access && io_slaver_uart_awready)    ;
assign io_slaver_uart_awaddr  =   aw_current_state == AW_IDLE ? io_master_cpu_awaddr : master_cpu_awaddr       ;
assign io_slaver_uart_awsize  =   aw_current_state == AW_IDLE ? io_master_cpu_awsize : master_cpu_awsize       ;
assign io_master_cpu_arready  = io_slaver_sram_arready;
assign io_slaver_sram_arvalid = io_master_cpu_arvalid ;
assign io_slaver_sram_araddr  = io_master_cpu_araddr  ;
assign io_slaver_sram_arsize  = io_master_cpu_arsize  ;

//R
assign io_master_cpu_rvalid   = io_slaver_sram_rvalid ;
assign io_slaver_sram_rready  = io_master_cpu_rready  ;
assign io_master_cpu_rdata    = io_slaver_sram_rdata  ;
assign io_master_cpu_rresp    = r_sram_access ? 3'b000 : 3'b011;

endmodule
