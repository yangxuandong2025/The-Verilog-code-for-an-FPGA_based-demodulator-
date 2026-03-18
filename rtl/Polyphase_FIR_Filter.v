module Polyphase_FIR_Filter(
    input sys_clk,
    input sys_rst_n,
    
    input  signed [15:0] adc_input,
    output reg    [15:0] dac_output,
    
    output        adc_clk,
    output        dac_clk,
    
    output signed [36:0] data_out_test
);

assign data_out_test = data_out;

assign adc_clk = sys_clk;
assign dac_clk = ~pll_clk_c0;

wire signed [15:0] coe [0:31];

parameter M     = 4;  // 抽取倍率（相数）
parameter NTAPS = 32; // FIR 总抽头数
// 采样频率fs = 50MHz，截止频率fc = 20KHz
assign coe[0]  = 358;
assign coe[1]  = 272;
assign coe[2]  = 365;
assign coe[3]  = 470;
assign coe[4]  = 586;
assign coe[5]  = 711;
assign coe[6]  = 841;
assign coe[7]  = 974;
assign coe[8]  = 1105;
assign coe[9]  = 1231;
assign coe[10] = 1348;
assign coe[11] = 1453;
assign coe[12] = 1541;
assign coe[13] = 1610;
assign coe[14] = 1657;
assign coe[15] = 1681;
assign coe[16] = 1681;
assign coe[17] = 1657;
assign coe[18] = 1610;
assign coe[19] = 1541;
assign coe[20] = 1453;
assign coe[21] = 1348;
assign coe[22] = 1231;
assign coe[23] = 1105;
assign coe[24] = 974;
assign coe[25] = 841;
assign coe[26] = 711;
assign coe[27] = 586;
assign coe[28] = 470;
assign coe[29] = 365;
assign coe[30] = 272;
assign coe[31] = 358;

reg        [1:0]  M_cnt;
reg signed [15:0] data_temporary [0:3];

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        M_cnt <= 2'd0;
    else
        M_cnt <= (M_cnt == 2'd3) ? 2'd0 : M_cnt + 1'b1;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    integer i;
    if(!sys_rst_n) begin
        for(i = 0; i < 4; i = i+1) 
            data_temporary[i] = 16'd0;
    end 
    else
        data_temporary[M_cnt] <= adc_input;
end

reg [1:0] pll_cnt; 
reg       pll_clk_c0;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        pll_cnt <= 2'd0;
        pll_clk_c0 <= 1'b0;
    end        
    else if(pll_cnt == 2'd1) begin
        pll_cnt <= 2'd0;
        pll_clk_c0 <= ~pll_clk_c0;
    end
    else
        pll_cnt <= pll_cnt + 1'b1;
end

reg signed [15:0] data_in [0:3][0:7];

always @(posedge pll_clk_c0 or negedge sys_rst_n) begin
    integer i, j;
    if(!sys_rst_n) begin
        for(i = 0; i < 4; i = i+1) begin
            for(j = 0; j < 8; j = j+1)
                data_in[i][j] = 16'd0; 
        end
    end        
    else begin
        for(i = 0; i < 4; i = i+1) begin
            data_in[i][0] <= data_temporary[i];
            for(j = 1; j < 8; j = j+1)
                data_in[i][j] <= data_in[i][j-1];
        end
    end
end

// 将对称系数的输入数据相加，同时将对应的滤波器系数送入乘法器
reg signed [16:0] data_add [0:15]; // 加法寄存器

always @(posedge pll_clk_c0 or negedge sys_rst_n) begin
    integer i, j;
    if(!sys_rst_n) begin
        for(i = 0; i < 16; i = i+1)
            data_add[i] = 17'd0; 
    end
    else begin
        for(i = 0; i < 2; i = i+1) begin
            for(j = 0; j < 8; j = j+1)
                data_add[8*i+j] <= data_in[i][j] + data_in[3-i][7-j];
        end
    end
end

reg signed [32:0] data_mult [0:15]; // 乘法寄存器输出为33比特数据

always @(posedge pll_clk_c0 or negedge sys_rst_n) begin
    integer i;
    if(!sys_rst_n) begin
        for(i = 0; i < 16; i = i+1)
            data_mult[i] = 33'd0; 
    end
    else begin
        for(i = 0; i < 8; i = i+1) begin
            data_mult[i] <= coe[4*i] * data_add[i];
            data_mult[i+8] <= coe[4*i+1] * data_add[i+8];
        end
    end
end

reg signed [36:0] data_out;

always @(posedge pll_clk_c0 or negedge sys_rst_n) begin
    integer i;
    if(!sys_rst_n)
        data_out <= 37'd0;
    else begin
        data_out = 37'd0;
        for(i = 0; i < 16; i = i+1)
            data_out = data_out + data_mult[i];
        dac_output = 16'h8000 - (data_out >>> 15);
    end
end

endmodule
