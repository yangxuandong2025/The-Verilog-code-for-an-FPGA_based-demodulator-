// 二阶节级联型巴特沃斯低通滤波器采用直接I型差分方程，其余类型仅需修改5个反馈系数
module iir(
    input               sys_clk,
    input               sys_rst_n,
         
    input signed [15:0] adc_input, // 16位ADC输入（无符号0-65535）
    input signed [17:0] a1, // 系数a1（Q1.16格式）
    input signed [17:0] a2, // 系数a2（Q1.16格式）
    input signed [17:0] b0, // 系数b0（Q1.16格式）
    input signed [17:0] b1, // 系数b1（Q1.16格式）
    input signed [17:0] b2, // 系数b2（Q1.16格式）
        
    output reg   [15:0] dac_output // 16位DAC输出（无符号0-65535）
);

// 寄存器声明
reg signed [15:0] x1, x2;
reg signed [15:0] y, y1, y2;
reg        [1:0]  flag;
                                                  
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        flag  <= 2'd0;
        x1    <= 16'sd0; 
        x2    <= 16'sd0; 
        y     <= 16'sd0;
        y1    <= 16'sd0; 
        y2    <= 16'sd0; 
    end
    else begin
        case(flag)
            2'd0 : begin
                y <= (b0 * adc_input + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
                + 34'sh8000) >>> 16;
                flag <= flag + 1'b1;
            end
            2'd1 : begin
                x1         <= adc_input;
                x2         <= x1;
                dac_output <= 16'h8000 - y;
                y1         <= y;
                y2         <= y1;
                flag       <= 2'd0;
            end
        endcase
    end
end

endmodule 
