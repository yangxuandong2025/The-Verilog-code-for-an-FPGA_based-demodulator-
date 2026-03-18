module CIC_Filter_down(
    input clk_low, // 输入数据时钟
    input clk_high, // 输入数据时钟
    input sys_rst_n,   // 复位信号
    
    input signed [DATA_WIDTH-1:0] data_in, // 输入数据
    output reg   [DATA_WIDTH-1:0] data_out // 输出数据
);

parameter STAGES = 3; // 滤波器阶数
parameter DATA_WIDTH = 16; // 数据宽度
parameter INDATA_WIDTH = 25; // 中间数据宽度
    
// 积分器的寄存器
reg signed [INDATA_WIDTH-1:0] integrator [0:STAGES]; 
// 梳状器的寄存器
reg signed [INDATA_WIDTH-1:0] comb  [0:STAGES]; 
reg signed [INDATA_WIDTH-1:0] combd [0:STAGES]; 
// 插值的寄存器
reg signed [INDATA_WIDTH-1:0] interpolation = 0;
reg        [7:0] cont;
// 输出缓冲
reg signed [INDATA_WIDTH-1:0] output_buffer = 0;

// 将输出缓冲的值映射到输出端口
always @(posedge clk_high) begin
    data_out <= output_buffer[INDATA_WIDTH-1:INDATA_WIDTH-DATA_WIDTH]; // 调整以适应实际的位宽和动态范围
end

// 积分器逻辑（由输入时钟驱动）
always @(posedge clk_high or negedge sys_rst_n) begin
    integer i;
    if(!sys_rst_n) begin
        for(i = 0; i <= STAGES; i = i + 1) begin
            integrator[i] = 0;
        end
    end 
    else begin
        integrator[0] <= data_in;
        for(i = 1; i <= STAGES; i = i + 1) begin // 积分器
            integrator[i] <= integrator[i] + integrator[i-1];
        end
    end
end

// 抽取器(输出时钟驱动)
always @(posedge clk_low or negedge sys_rst_n) begin
    if(!sys_rst_n)
        interpolation <= 0;
    else
        interpolation <= integrator[STAGES];
end

// 梳状器（由输出时钟驱动）
always @(posedge clk_low or negedge sys_rst_n) begin
    integer i;
    if(!sys_rst_n) begin
        for(i = 0; i <= STAGES; i = i + 1) begin
            comb[i]  = 0;
            combd[i] = 0;
        end
    end 
    else begin
        // 梳状器操作
        comb[0] <= interpolation;// 输出数据
        for(i = 1; i <= STAGES; i = i + 1) begin
            combd[i-1] <= comb[i-1];
            comb[i]    <= comb[i-1] - combd[i-1];
        end
        combd[STAGES] <= comb[STAGES];
        output_buffer <= comb[STAGES];
    end
end

endmodule
