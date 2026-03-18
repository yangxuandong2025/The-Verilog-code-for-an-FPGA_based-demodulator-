//module AM (
//    input        Clk,//时钟信号
//    input        Rst_n,//复位信号，低电平有效
//    input  [7:0] AD,//输入信号
//    output reg [7:0] t//输出数据
//);
//reg signed [7:0] rectified_signal; // 整流后信号
////全波整流
//always @(posedge sys_clk or negedge rst_n) begin
//    if(!rst_n)
//        rectified_signal <= 8'd0;
//    else begin
//        // 合并偏置调整与整流：先调整偏置，然后取绝对值
//        if(m_signal < 8'h80) 
//            rectified_signal <= 8'h80 - m_signal; // 当m_signal < 128时，结果为正
//        else
//            rectified_signal <= m_signal - 8'h80; // 等价于取绝对值
//    end
//end
//
//
//endmodule //AM