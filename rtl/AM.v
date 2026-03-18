module AM (
   input  wire   Clk,//时钟信号
   input  wire   clk_6M,
   input  wire   clk_6M_deg180,
   input  wire   clk_100M,
   input  wire    Rst_n,//复位信号，低电平有效
   input  wire [7:0] m_signal,//输入信号
   output wire [15:0] d_signal//输出数据
    
    // output adc_clk,
    // output dac_clk
);

parameter RCT = 500;

 
reg [8:0] abs_diff;
reg signed [15:0] rectified_signal; // 整流后信号
//全波整流
always @(posedge Clk or negedge Rst_n) begin
   if(!Rst_n)
      abs_diff <= 9'd0;
   else begin
       // 合并偏置调整与整流：先调整偏置，然后取绝对值
       if(m_signal < 8'h80) 
           abs_diff <= 8'h80 - m_signal; // 当m_signal < 128时，结果为正
       else
           abs_diff <= m_signal - 8'h80; // 等价于取绝对值
   end
end
// 扩展到16位，方便后续包络滤波
// 这里左移7位，相当于放大128倍，使得后续的滤波器处理更精细

always @(posedge Clk or negedge Rst_n) begin
    if(!Rst_n)
        rectified_signal <= 16'd0;
    else
        rectified_signal <= (abs_diff << 7);
end

//包络提取核心：峰值跟踪 + 缓慢下降
reg signed [15:0] d_signal_reg;

always @(posedge Clk or negedge Rst_n) begin
    if(!Rst_n)
        d_signal_reg <= 16'd0;
    else if(rectified_signal > d_signal_reg)
        d_signal_reg <= rectified_signal;
    else
        d_signal_reg <= d_signal_reg * RCT / (RCT + 1'b1);
end
//assign dac_clk = clk_6M_deg180;//DAC时钟

wire signed [15:0] clc_output;

CIC_Filter_down u_CIC_Filter_down(
    .clk_low   ( clk_6M ), // 输入数据时钟
    .clk_high  ( Clk ), // 输入数据时钟
    .sys_rst_n ( Rst_n ),   // 复位信号

    .data_in   ( d_signal_reg ), // 输入数据
    .data_out  ( clc_output ) // 输出数据
);

wire [15:0] fir_output;

fir u_fir(
    .sys_clk    ( clk_6M ),
    .sys_rst_n  ( Rst_n ),

    .fir_coe    (  ),
    
    .adc_input  ( clc_output ),
    .dac_output ( d_signal )
);

endmodule





  