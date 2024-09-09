module delayed_assignment(
	input clk,
	input rst_n,
	input pulse_in,
	output reg pulse_out
);

reg [1:0] delay_count;  // 计数器,记录延时的时钟周期数

// 状态机
typedef enum reg [1:0] {
	IDLE   = 2'b00,  // 空闲状态
	DELAY0 = 2'b01,  // 延迟状态1
	DELAY1 = 2'b10   // 延迟状态2
} state_t;

reg [1:0] state, next_state;  // 状态寄存器

// 状态机的状态转换逻辑
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		state <= IDLE;
		delay_count <= 0;
		pulse_out = 1'b0;
	end else begin
		state <= next_state;
		// 延时,一个周期计数器更新一次 
		if (next_state == DELAY0 || next_state == DELAY1) begin
			delay_count <= delay_count + 1;
		end else begin
			delay_count <= 0;
		end
	end
end

//状态机的次态逻辑
always @(*) begin
	case (state)
		IDLE : begin
			if (pulse_in) begin // ready == 1
				next_state = DELAY0;
			end else begin
				next_state = IDLE;
			end
		end

		DELAY0 : begin
			if (delay_count == 1) begin
				next_state = DELAY1;
			end else begin
				next_state = DELAY0;
			end
		end

		DELAY1 : begin
			if (delay_count == 2) begin
				next_state = IDLE;
			end else begin
				next_state = DELAY1;
			end
		end

		default : next_state = IDLE;
	endcase
end

//状态机的输出逻辑
always @(*) begin
	case (state)
		IDLE   : pulse_out = 1'b1;
		DELAY0 : pulse_out = 1'b0;
		DELAY1 : pulse_out = 1'b1;
		default: pulse_out = 1'b1;
	endcase
end

endmodule

